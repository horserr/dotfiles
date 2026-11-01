#!/usr/bin/env python3
"""Dev-only cross-check of qrgen against an independent encoder (segno).

Not part of the plugin runtime and not run by tests/smoke.py. It verifies that
our matrices are byte-identical to segno's for every supported version, both
supported ECC levels and all eight masks:

    uv run --with segno python3 tests/crosscheck_segno.py

`boost_error=False` keeps segno from silently upgrading the ECC level, and the
payload is lowercase so both encoders pick byte mode.

Payloads are sized to fill the symbol exactly: segno's `write_padding_bits`
appends a full 8 zero bits when the stream already ends on a codeword boundary
(it uses `8 - length % 8`), so padded symbols legitimately differ from ours.
Matrix equality is therefore only meaningful without padding; end-to-end
scannability of padded symbols is covered by tests/decode_check.py.
"""

from __future__ import annotations

import sys
from pathlib import Path

import segno  # type: ignore[import-not-found]

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

import qrgen


def payload_for(version: int, level: str) -> bytes:
    bits = (
        qrgen._data_capacity(version, level) * 8 - 4 - qrgen._char_count_bits(version)
    )
    return b"a" * (bits // 8)


def our_matrix(payload: bytes, version: int, level: str, mask: int) -> list[list[int]]:
    codewords = qrgen._add_error_correction(
        qrgen._encode_codewords(payload, version, level), version, level
    )
    return qrgen._build(codewords, version, level, mask)


def main() -> int:
    failures = 0
    checks = 0
    for version in range(1, 11):
        for level in ("L", "M"):
            payload = payload_for(version, level)
            for mask in range(8):
                expected = segno.make(
                    payload.decode(),
                    version=version,
                    error=level.lower(),
                    mask=mask,
                    boost_error=False,
                ).matrix
                expected_rows = [[int(cell) for cell in row] for row in expected]
                actual = our_matrix(payload, version, level, mask)
                checks += 1
                if actual != expected_rows:
                    failures += 1
                    diff = [
                        (r, c, actual[r][c], expected_rows[r][c])
                        for r in range(len(actual))
                        for c in range(len(actual))
                        if actual[r][c] != expected_rows[r][c]
                    ]
                    print(
                        f"MISMATCH v{version}-{level} mask{mask}: "
                        f"{len(diff)} cells, first {diff[:4]}"
                    )
                    if failures > 6:
                        print("too many failures, stopping")
                        return 1
    print(f"{checks - failures}/{checks} matrices match")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
