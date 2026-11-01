#!/usr/bin/env python3
"""Dev-only: prove the generated symbols are actually scannable.

Renders each matrix to a bitmap and decodes it with OpenCV (an independent
decoder). This covers the padding paths that tests/crosscheck_segno.py cannot
compare against segno.

    uv run --with opencv-python-headless --with pillow python3 tests/decode_check.py

OpenCV's detector occasionally misses a symbol at small scales, so each payload
is retried at a few sizes before it counts as a failure.
"""

from __future__ import annotations

import sys
from pathlib import Path

import cv2  # type: ignore[import-not-found]
import numpy as np  # type: ignore[import-not-found]
from PIL import Image  # type: ignore[import-not-found]

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

import qrgen

QUIET = 4


def to_image(matrix: list[list[int]], scale: int) -> np.ndarray:
    size = len(matrix)
    side = (size + 2 * QUIET) * scale
    image = Image.new("L", (side, side), 255)
    pixels = image.load()
    for row, cells in enumerate(matrix):
        for col, dark in enumerate(cells):
            if not dark:
                continue
            top = (row + QUIET) * scale
            left = (col + QUIET) * scale
            for y in range(top, top + scale):
                for x in range(left, left + scale):
                    pixels[x, y] = 0
    return np.array(image)


def decode(payload: str) -> tuple[bool, str]:
    matrix = qrgen.make(payload)
    detector = cv2.QRCodeDetector()
    last = ""
    for scale in (6, 8, 10, 14):
        text, _points, _ = detector.detectAndDecode(to_image(matrix, scale))
        last = text
        if text == payload:
            return True, payload
    return False, last


def main() -> int:
    cases = [
        "ab",
        "shot-link",
        "ntfy://ntfy.sh/claude-asuscosmos-e4e1bfb6676ca4b8",
        "https://ntfy.example.com/topic",
        "a" * 40,
        "a" * 80,
        "a" * 120,
        "a" * 200,
        "ntfy://internal.example:8443/" + "z" * 60,
    ]
    failures = 0
    for payload in cases:
        ok, got = decode(payload)
        version = (len(qrgen.make(payload)) - 17) // 4
        print(
            f"{'ok  ' if ok else 'FAIL'} {len(payload):3d} bytes  v{version:<2d}  {got[:48]!r}"
        )
        failures += 0 if ok else 1
    print(f"\n{len(cases) - failures}/{len(cases)} symbols decoded")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
