from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


SIZE = 480
GRID = 48
CELL = SIZE // GRID

ROOT = Path(__file__).resolve().parents[2]
FACE_DIR = Path(__file__).resolve().parents[1]
FONT_PATH = ROOT / "advanced-pixel-7" / "advanced_pixel-7.ttf"
OUTPUT_PATH = FACE_DIR / "resources" / "previews" / "harvest-pixels-preview.png"


def rgb(value: int) -> tuple[int, int, int]:
    return ((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)


def main() -> None:
    output = Image.new("RGB", (SIZE, SIZE), rgb(0x000000))
    face = Image.new("RGB", (SIZE, SIZE), rgb(0x000000))
    draw = ImageDraw.Draw(face)

    def px(
        col: int,
        row: int,
        width: int,
        height: int,
        color: int,
    ) -> None:
        draw.rectangle(
            (
                col * CELL,
                row * CELL,
                (col + width) * CELL - 1,
                (row + height) * CELL - 1,
            ),
            fill=rgb(color),
        )

    outline = 0x4B1D18
    shadow = 0x8F3908
    wood = 0xD76806
    gold = 0xF59A08
    highlight = 0xFFC02A
    paper = 0xFFD27A
    paper_light = 0xFFE09A
    sky = 0xA8ECF3
    sky_shade = 0x78C9E6
    sun = 0xFFF06A
    tile_blue = 0x66E5F1
    tile_pink = 0xFF70C8
    leaf = 0x55C56A

    def wood_panel(
        col: int,
        row: int,
        width: int,
        height: int,
        fill: int,
        fill_light: int,
    ) -> None:
        px(col, row, width, height, outline)
        px(col + 1, row + 1, width - 2, height - 2, gold)
        px(col + 2, row + 2, width - 4, height - 4, fill)
        px(col + 2, row + 2, width - 4, 1, fill_light)

    # Narrow arched sky window.
    px(21, 4, 6, 1, outline)
    px(18, 5, 12, 1, outline)
    px(16, 6, 16, 2, outline)
    px(15, 8, 18, 9, outline)
    px(21, 4, 6, 1, wood)
    px(18, 5, 12, 1, wood)
    px(17, 6, 14, 2, wood)
    px(16, 8, 16, 9, wood)
    px(18, 6, 12, 1, sky)
    px(17, 7, 14, 9, sky)
    px(17, 12, 14, 4, sky_shade)

    # Sun, moon, and clock hand.
    px(19, 9, 3, 3, sun)
    px(18, 10, 5, 1, sun)
    px(27, 9, 3, 3, 0xF4F2E7)
    px(26, 10, 5, 1, 0xF4F2E7)
    px(30, 12, 1, 1, 0xD8E7ED)
    px(31, 14, 1, 1, 0xD8E7ED)
    px(23, 7, 3, 1, outline)
    px(22, 8, 5, 1, outline)
    px(23, 6, 3, 1, gold)
    px(24, 5, 1, 1, highlight)
    px(24, 8, 1, 7, outline)
    px(25, 8, 1, 7, highlight)
    px(23, 15, 4, 1, outline)
    px(22, 16, 6, 1, shadow)

    # Cabinet and its two text boards.
    px(12, 16, 24, 20, outline)
    px(11, 18, 26, 17, outline)
    px(13, 16, 22, 20, wood)
    px(12, 18, 24, 17, wood)
    px(13, 17, 22, 1, highlight)
    px(13, 35, 22, 1, shadow)
    wood_panel(13, 18, 22, 6, paper, paper_light)

    # Decorative middle tiles.
    wood_panel(14, 24, 7, 6, tile_blue, sky)
    wood_panel(21, 24, 6, 6, 0xE87905, 0xF4A20B)
    wood_panel(27, 24, 7, 6, tile_pink, 0xEE8CD0)
    px(16, 26, 3, 2, sun)
    px(17, 25, 1, 4, sun)
    px(15, 25, 1, 1, 0xFFF8A0)
    px(19, 28, 1, 1, 0xFFF8A0)
    px(29, 26, 3, 2, 0xFFFFFF)
    px(30, 25, 1, 4, 0xFFFFFF)
    px(30, 27, 1, 1, 0xFFD54A)
    px(28, 28, 2, 1, leaf)
    px(31, 28, 2, 1, leaf)
    wood_panel(13, 30, 22, 6, paper, paper_light)

    # Legs and seven-cell data counter.
    px(16, 36, 2, 3, outline)
    px(17, 36, 1, 3, wood)
    px(31, 36, 2, 3, outline)
    px(31, 36, 1, 3, wood)
    px(12, 38, 24, 5, outline)
    px(11, 39, 26, 3, outline)
    px(13, 38, 22, 5, wood)
    px(12, 39, 24, 3, gold)
    for index in range(7):
        cell_x = 14 + index * 3
        px(cell_x, 38, 3, 5, outline)
        px(cell_x + 1, 39, 2, 4, paper)
        px(cell_x + 1, 39, 2, 1, paper_light)

    large = ImageFont.truetype(str(FONT_PATH), 28)
    small = ImageFont.truetype(str(FONT_PATH), 14)
    ink = rgb(0x6A2A12)

    def centered_text(col: float, row: float, text: str, font: ImageFont.FreeTypeFont) -> None:
        draw.text(
            (col * CELL, row * CELL),
            text,
            fill=ink,
            font=font,
            anchor="mm",
        )

    centered_text(24, 21.0, "MONDAY", large)
    centered_text(24, 27.0, "STP", small)
    centered_text(24, 33.0, "10:09", large)
    counter_value = "8462"
    first_cell = 7 - len(counter_value)
    for index, character in enumerate(counter_value):
        centered_text(15.5 + (first_cell + index) * 3, 40.5, character, large)

    circle_mask = Image.new("L", (SIZE, SIZE), 0)
    ImageDraw.Draw(circle_mask).ellipse((0, 0, SIZE - 1, SIZE - 1), fill=255)
    output.paste(face, mask=circle_mask)

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    output.save(OUTPUT_PATH, optimize=True)
    print(OUTPUT_PATH)


if __name__ == "__main__":
    main()
