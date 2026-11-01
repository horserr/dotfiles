#!/usr/bin/env python3
"""Minimal QR Code encoder — byte mode, versions 1-10, ECC level L/M.

Standard library only, so `ntfy-approvals` can show a scannable QR without
`qrencode`, Pillow, or an online service (the topic is a secret and must not
leave the machine).

Implements ISO/IEC 18004: mode/count/padding, Reed-Solomon EC over GF(256),
block interleaving, function patterns, format/version information, data
placement, all eight masks with penalty scoring.
"""

from __future__ import annotations

# (ec_codewords_per_block, blocks_g1, data_codewords_g1, blocks_g2, data_codewords_g2)
_ECC = {
    (1, "L"): (7, 1, 19, 0, 0),
    (1, "M"): (10, 1, 16, 0, 0),
    (2, "L"): (10, 1, 34, 0, 0),
    (2, "M"): (16, 1, 28, 0, 0),
    (3, "L"): (15, 1, 55, 0, 0),
    (3, "M"): (26, 1, 44, 0, 0),
    (4, "L"): (20, 1, 80, 0, 0),
    (4, "M"): (18, 2, 32, 0, 0),
    (5, "L"): (26, 1, 108, 0, 0),
    (5, "M"): (24, 2, 43, 0, 0),
    (6, "L"): (18, 2, 68, 0, 0),
    (6, "M"): (16, 4, 27, 0, 0),
    (7, "L"): (20, 2, 78, 0, 0),
    (7, "M"): (18, 4, 31, 0, 0),
    (8, "L"): (24, 2, 97, 0, 0),
    (8, "M"): (22, 2, 38, 2, 39),
    (9, "L"): (30, 2, 116, 0, 0),
    (9, "M"): (22, 3, 36, 2, 37),
    (10, "L"): (18, 2, 68, 2, 69),
    (10, "M"): (26, 4, 43, 1, 44),
}

_ALIGN = {
    1: (),
    2: (6, 18),
    3: (6, 22),
    4: (6, 26),
    5: (6, 30),
    6: (6, 34),
    7: (6, 22, 38),
    8: (6, 24, 42),
    9: (6, 26, 46),
    10: (6, 28, 50),
}

_ECL_BITS = {"L": 0b01, "M": 0b00, "Q": 0b11, "H": 0b10}

_DATA_BITS_MODE_BYTE = 0b0100


# ---------------------------------------------------------------------------
# GF(256) arithmetic
# ---------------------------------------------------------------------------


def _gf_mul(a: int, b: int) -> int:
    result = 0
    while b:
        if b & 1:
            result ^= a
        a <<= 1
        if a & 0x100:
            a ^= 0x11D
        b >>= 1
    return result


def _poly_mul(left: list[int], right: list[int]) -> list[int]:
    out = [0] * (len(left) + len(right) - 1)
    for i, a in enumerate(left):
        if not a:
            continue
        for j, b in enumerate(right):
            out[i + j] ^= _gf_mul(a, b)
    return out


def _rs_generator(degree: int) -> list[int]:
    poly = [1]
    root = 1
    for _ in range(degree):
        poly = _poly_mul(poly, [1, root])
        root = _gf_mul(root, 2)
    return poly


def _rs_remainder(data: bytes, degree: int) -> bytes:
    generator = _rs_generator(degree)
    remainder = list(data) + [0] * degree
    for i in range(len(data)):
        factor = remainder[i]
        if factor:
            for j, coefficient in enumerate(generator):
                remainder[i + j] ^= _gf_mul(coefficient, factor)
    return bytes(remainder[len(data) :])


# ---------------------------------------------------------------------------
# data encoding
# ---------------------------------------------------------------------------


def _data_capacity(version: int, level: str) -> int:
    ec, b1, d1, b2, d2 = _ECC[(version, level)]
    return b1 * d1 + b2 * d2


def _char_count_bits(version: int) -> int:
    return 8 if version <= 9 else 16


def choose_version(payload: bytes, level: str = "M") -> tuple[int, str]:
    """Smallest version that fits, falling back from M to L."""
    for candidate in (level, "L"):
        if candidate not in _ECL_BITS:
            continue
        for version in range(1, 11):
            needed = 4 + _char_count_bits(version) + 8 * len(payload)
            if needed <= _data_capacity(version, candidate) * 8:
                return version, candidate
    raise ValueError(f"payload too long for QR versions 1-10 ({len(payload)} bytes)")


def _encode_codewords(payload: bytes, version: int, level: str) -> bytes:
    bits: list[int] = []

    def put(value: int, length: int) -> None:
        for shift in range(length - 1, -1, -1):
            bits.append((value >> shift) & 1)

    put(_DATA_BITS_MODE_BYTE, 4)
    put(len(payload), _char_count_bits(version))
    for byte in payload:
        put(byte, 8)

    capacity_bits = _data_capacity(version, level) * 8
    put(0, min(4, capacity_bits - len(bits)))
    while len(bits) % 8:
        bits.append(0)

    codewords = bytearray()
    for i in range(0, len(bits), 8):
        value = 0
        for bit in bits[i : i + 8]:
            value = (value << 1) | bit
        codewords.append(value)

    pad = (0xEC, 0x11)
    index = 0
    while len(codewords) < capacity_bits // 8:
        codewords.append(pad[index % 2])
        index += 1
    return bytes(codewords)


def _add_error_correction(data: bytes, version: int, level: str) -> bytes:
    ec_len, b1, d1, b2, d2 = _ECC[(version, level)]
    blocks: list[bytes] = []
    position = 0
    for _ in range(b1):
        blocks.append(data[position : position + d1])
        position += d1
    for _ in range(b2):
        blocks.append(data[position : position + d2])
        position += d2

    ec_blocks = [_rs_remainder(block, ec_len) for block in blocks]
    out = bytearray()
    for i in range(max(len(block) for block in blocks)):
        for block in blocks:
            if i < len(block):
                out.append(block[i])
    for i in range(ec_len):
        for ec_block in ec_blocks:
            out.append(ec_block[i])
    return bytes(out)


# ---------------------------------------------------------------------------
# matrix construction
# ---------------------------------------------------------------------------


def _new_matrix(version: int) -> list[list[int | None]]:
    size = 17 + 4 * version
    return [[None] * size for _ in range(size)]


def _draw_function_patterns(matrix: list[list[int | None]], version: int) -> None:
    size = len(matrix)

    def finder(top: int, left: int) -> None:
        for dr in range(-1, 8):
            for dc in range(-1, 8):
                row, col = top + dr, left + dc
                if not (0 <= row < size and 0 <= col < size):
                    continue
                in_ring = 0 <= dr <= 6 and 0 <= dc <= 6
                dark = in_ring and (
                    dr in (0, 6) or dc in (0, 6) or (2 <= dr <= 4 and 2 <= dc <= 4)
                )
                matrix[row][col] = 1 if dark else 0

    finder(0, 0)
    finder(0, size - 7)
    finder(size - 7, 0)

    for i in range(size):
        if matrix[6][i] is None:
            matrix[6][i] = 1 if i % 2 == 0 else 0
        if matrix[i][6] is None:
            matrix[i][6] = 1 if i % 2 == 0 else 0

    positions = _ALIGN[version]
    for row in positions:
        for col in positions:
            if (
                (row <= 8 and col <= 8)
                or (row <= 8 and col >= size - 9)
                or (row >= size - 9 and col <= 8)
            ):
                continue
            for dr in range(-2, 3):
                for dc in range(-2, 3):
                    matrix[row + dr][col + dc] = 0 if max(abs(dr), abs(dc)) == 1 else 1

    matrix[size - 8][8] = 1  # dark module


def _reserve_format_areas(matrix: list[list[int | None]], version: int) -> None:
    size = len(matrix)
    reserved = [(i, 8) for i in range(9)] + [(8, i) for i in range(9)]
    reserved += [(size - 7 + i, 8) for i in range(7)]
    reserved += [(8, size - 8 + i) for i in range(8)]
    if version >= 7:
        reserved += [(i, size - 11 + j) for i in range(6) for j in range(3)]
        reserved += [(size - 11 + j, i) for i in range(6) for j in range(3)]
    for row, col in reserved:
        if matrix[row][col] is None:
            matrix[row][col] = 0


def _place_data(
    matrix: list[list[int | None]], data: bytes, version: int
) -> list[list[bool]]:
    size = len(matrix)
    bits = [(byte >> shift) & 1 for byte in data for shift in range(7, -1, -1)]
    is_data = [[False] * size for _ in range(size)]
    index = 0
    upward = True
    col = size - 1
    while col > 0:
        if col == 6:
            col -= 1
        rows = range(size - 1, -1, -1) if upward else range(size)
        for row in rows:
            for c in (col, col - 1):
                if matrix[row][c] is None:
                    matrix[row][c] = bits[index] if index < len(bits) else 0
                    is_data[row][c] = True
                    index += 1
        col -= 2
        upward = not upward
    return is_data


_MASKS = (
    lambda r, c: (r + c) % 2 == 0,
    lambda r, c: r % 2 == 0,
    lambda r, c: c % 3 == 0,
    lambda r, c: (r + c) % 3 == 0,
    lambda r, c: (r // 2 + c // 3) % 2 == 0,
    lambda r, c: (r * c) % 2 + (r * c) % 3 == 0,
    lambda r, c: ((r * c) % 2 + (r * c) % 3) % 2 == 0,
    lambda r, c: ((r + c) % 2 + (r * c) % 3) % 2 == 0,
)


def _apply_mask(matrix, is_data, mask: int) -> None:
    rule = _MASKS[mask]
    size = len(matrix)
    for row in range(size):
        for col in range(size):
            if is_data[row][col] and rule(row, col):
                matrix[row][col] ^= 1


def _format_bits(level: str, mask: int) -> list[int]:
    data = (_ECL_BITS[level] << 3) | mask
    remainder = data
    for _ in range(10):
        remainder = (remainder << 1) ^ ((remainder >> 9) * 0x537)
    value = ((data << 10) | (remainder & 0x3FF)) ^ 0x5412
    # bit 0 is the least significant bit, as placed below
    return [(value >> shift) & 1 for shift in range(15)]


def _version_bits(version: int) -> list[int]:
    remainder = version
    for _ in range(12):
        remainder = (remainder << 1) ^ ((remainder >> 11) * 0x1F25)
    value = (version << 12) | (remainder & 0xFFF)
    return [(value >> shift) & 1 for shift in range(18)]


def _draw_format(matrix, level: str, mask: int, version: int) -> None:
    size = len(matrix)
    bits = _format_bits(level, mask)

    # first copy: vertical strip down the left of the top-left finder
    for i in range(6):
        matrix[i][8] = bits[i]
    matrix[7][8] = bits[6]
    matrix[8][8] = bits[7]
    for i in range(8, 15):
        matrix[size - 15 + i][8] = bits[i]

    # second copy: horizontal strip under the top-right finder
    for i in range(8):
        matrix[8][size - 1 - i] = bits[i]
    matrix[8][7] = bits[8]
    for i in range(9, 15):
        matrix[8][14 - i] = bits[i]

    matrix[size - 8][8] = 1  # dark module

    if version >= 7:
        vbits = _version_bits(version)
        for i in range(18):
            bit = vbits[i]
            matrix[i // 3][size - 11 + i % 3] = bit
            matrix[size - 11 + i % 3][i // 3] = bit


def _penalty(matrix: list[list[int]]) -> int:
    size = len(matrix)
    score = 0

    for line in list(matrix) + [list(col) for col in zip(*matrix)]:
        run_color = line[0]
        run = 1
        for value in line[1:]:
            if value == run_color:
                run += 1
            else:
                if run >= 5:
                    score += 3 + (run - 5)
                run_color, run = value, 1
        if run >= 5:
            score += 3 + (run - 5)

    for row in range(size - 1):
        for col in range(size - 1):
            block = matrix[row][col]
            if (
                matrix[row][col + 1] == block
                and matrix[row + 1][col] == block
                and matrix[row + 1][col + 1] == block
            ):
                score += 3

    patterns = (
        [1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1],
    )
    for line in list(matrix) + [list(col) for col in zip(*matrix)]:
        for start in range(size - 10):
            window = list(line[start : start + 11])
            if window in patterns:
                score += 40

    dark = sum(sum(row) for row in matrix)
    total = size * size
    percent = dark * 100 // total
    score += 10 * (abs(percent - 50) // 5)
    return score


def make(
    payload: str | bytes, level: str = "M", mask: int | None = None
) -> list[list[int]]:
    """Return the QR matrix (0 = light, 1 = dark)."""
    if isinstance(payload, str):
        payload = payload.encode("utf-8")
    version, used_level = choose_version(payload, level)
    codewords = _add_error_correction(
        _encode_codewords(payload, version, used_level), version, used_level
    )

    if mask is None:
        best_matrix = None
        best_score = None
        for candidate in range(8):
            matrix = _build(codewords, version, used_level, candidate)
            score = _penalty(matrix)
            if best_score is None or score < best_score:
                best_matrix, best_score = matrix, score
        assert best_matrix is not None
        return best_matrix
    return _build(codewords, version, used_level, mask)


def _build(codewords: bytes, version: int, level: str, mask: int) -> list[list[int]]:
    matrix = _new_matrix(version)
    _draw_function_patterns(matrix, version)
    _reserve_format_areas(matrix, version)
    is_data = _place_data(matrix, codewords, version)
    _apply_mask(matrix, is_data, mask)
    _draw_format(matrix, level, mask, version)
    return [[int(cell) for cell in row] for row in matrix]


# ---------------------------------------------------------------------------
# terminal rendering
# ---------------------------------------------------------------------------

_DARK_ON_LIGHT = "\x1b[30;107m"  # top dark, bottom light
_LIGHT_ON_DARK = "\x1b[97;40m"  # top light, bottom dark
_DARK_DARK = "\x1b[40;40m"  # both dark
_LIGHT_LIGHT = "\x1b[107;107m"  # both light
_RESET = "\x1b[0m"

# Shapes also encode the contrast, so the code stays readable when a consumer
# strips ANSI (chat transcripts, logs): dark modules are drawn, light modules
# are left as background.
_SHAPES = {
    (1, 0): "▀",
    (0, 1): "▄",
    (1, 1): "█",
    (0, 0): " ",
}

_COLORS = {
    (1, 0): _DARK_ON_LIGHT,
    (0, 1): _LIGHT_ON_DARK,
    (1, 1): _DARK_DARK,
    (0, 0): _LIGHT_LIGHT,
}


def render(matrix: list[list[int]], quiet: int = 2, color: bool = True) -> str:
    """Render with half blocks: a white background with black modules.

    With ``color=True`` the modules are black on white (best for scanning);
    without it the shapes alone carry the pattern (inverted, still readable by
    most phone scanners). A color escape is only emitted when the pair of
    modules changes, keeping the output roughly three times smaller.
    """
    size = len(matrix)
    width = size + quiet * 2
    blank = [0] * width

    rows: list[list[int]] = [blank[:] for _ in range(quiet)]
    for row in matrix:
        rows.append([0] * quiet + list(row) + [0] * quiet)
    rows.extend([blank[:] for _ in range(quiet)])
    if len(rows) % 2:
        rows.append(blank[:])

    out = []
    for index in range(0, len(rows), 2):
        top, bottom = rows[index], rows[index + 1]
        chunks = []
        current = None
        for upper, lower in zip(top, bottom):
            state = (upper, lower)
            if color and state != current:
                chunks.append(_COLORS[state])
                current = state
            chunks.append(_SHAPES[state])
        out.append("".join(chunks) + (_RESET if color else ""))
    return "\n".join(out)


def as_text(payload: str, level: str = "M", color: bool = True) -> str:
    return render(make(payload, level), color=color)
