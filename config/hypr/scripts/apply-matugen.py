import hashlib
import json
import logging
import subprocess
import sys
from pathlib import Path

from materialyoucolor.hct import Hct
from materialyoucolor.quantize import ImageQuantizeCelebi
from materialyoucolor.score.score import Score

# Configuration Constants
CACHE_FILE_PATH = Path.home() / ".cache" / "wal" / "colors-cache.json"

# Logging Configuration
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")


def compute_image_hash(image_path):
    """Generates a SHA-256 hash for an image to detect changes."""
    hash_sha256 = hashlib.sha256()
    try:
        with open(image_path, "rb") as f:
            while chunk := f.read(8192):
                hash_sha256.update(chunk)
    except OSError as e:
        logging.exception(f"Error reading image file: {e}")
        sys.exit(1)
    return hash_sha256.hexdigest()


def load_cache(cache_file_path):
    """Loads cached color data from a JSON file."""
    if cache_file_path.is_file():
        try:
            with cache_file_path.open(encoding="utf-8") as f:
                return json.load(f)
        except (OSError, json.JSONDecodeError) as e:
            logging.warning(f"Could not load cache: {e}")
    return {}


def save_cache(cache_file_path, cache):
    """Saves color data to the cache file in JSON format."""
    try:
        with cache_file_path.open("w", encoding="utf-8") as f:
            json.dump(cache, f, indent=4)
    except OSError as e:
        logging.exception(f"Error saving cache file: {e}")
        sys.exit(1)


def get_representative_color(image_path: Path):
    """Extracts the most suitable color using materialyoucolor-python."""
    quality = 2
    result = ImageQuantizeCelebi(str(image_path), quality, 128)
    color = Score.score(result)[0]
    rgba = Hct(color).to_rgba()
    return rgba[:-1]


def main(image_path):
    """Main function to process the image and update the color scheme."""
    image_hash = compute_image_hash(image_path)
    cache = load_cache(CACHE_FILE_PATH)

    if image_hash in cache:
        representative_color = tuple(cache[image_hash])
        logging.info(f"Using cached color: {representative_color}")
    else:
        representative_color = get_representative_color(image_path)
        logging.info(f"Computed representative color: {representative_color}")
        cache[image_hash] = [int(c) for c in representative_color]
        save_cache(CACHE_FILE_PATH, cache)

    hex_color = "#{:02x}{:02x}{:02x}".format(*representative_color)
    command = ["matugen", "color", "hex", hex_color, "-m", "dark"]
    subprocess.run(command, check=False)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        logging.error("Usage: python script.py <image_path>")
        sys.exit(1)

    image_path = Path(sys.argv[1])
    if not image_path.is_file():
        logging.error(f"Image file does not exist: {image_path}")
        sys.exit(1)

    main(image_path)
