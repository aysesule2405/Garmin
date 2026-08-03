from pathlib import Path

from PIL import Image


FACE_DIR = Path(__file__).resolve().parents[1]
SOURCE = FACE_DIR / "resources" / "drawables" / "harvest_reference_source.png"
OUTPUT = FACE_DIR / "resources" / "drawables" / "harvest_reference.png"


def main() -> None:
    image = Image.open(SOURCE).convert("RGB")

    # Bounds of the selected newest reference artwork inside the image tool's
    # larger black canvas. Scale uniformly with nearest-neighbor sampling so the
    # complete portrait fits inside a round 454 px simulator display.
    artwork = image.crop((248, 227, 806, 1118))
    # Generic Connect IQ bitmap resources use the 280 px reference density.
    # The 454 px target scales these dimensions to approximately 216 x 360.
    artwork = artwork.resize((133, 222), Image.Resampling.NEAREST)
    artwork.save(OUTPUT, optimize=True)
    print(OUTPUT)


if __name__ == "__main__":
    main()
