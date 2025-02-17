import colorsys
import hashlib
import json
import logging
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from sklearn.cluster import KMeans
from sklearn.utils import shuffle

# Configuration Constants
IMAGE_RESIZE_DIM = (200, 200)
PIXEL_SAMPLE_SIZE = 10000
DEFAULT_N_CLUSTERS = 8
MIN_BRIGHTNESS = 96
MAX_BRIGHTNESS = 164
CACHE_FILE_PATH = Path.home() / ".cache" / "wal" / "colors-cache.json"

# Logging Configuration
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")


def adjust_brightness(color, factor):
    """Adjusts brightness of an RGB color by a factor."""
    return tuple(int(min(255, max(0, c * factor))) for c in color)


def calculate_brightness(color):
    """Calculates brightness using the luminance formula."""
    r, g, b = color
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def is_brightness_in_range(color, min_brightness, max_brightness):
    """Checks if color brightness is within the defined range."""
    brightness = calculate_brightness(color)
    return min_brightness <= brightness <= max_brightness


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


def preprocess_image(image_path):
    """Preprocesses the image for clustering by resizing and sampling pixels."""
    with Image.open(image_path).convert("RGB") as img:
        resized_img = img.resize(IMAGE_RESIZE_DIM)
        pixels = np.array(resized_img).reshape(-1, 3).astype(np.float64) / 255.0
    return shuffle(pixels, random_state=42, n_samples=PIXEL_SAMPLE_SIZE)


def cluster_colors(pixels, n_clusters):
    """Clusters image pixels using KMeans and returns cluster centers."""
    kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
    kmeans.fit(pixels)
    return kmeans.cluster_centers_ * 255.0  # Convert to RGB range


def find_most_representative_color(cluster_centers, min_brightness, max_brightness):
    """Finds the most representative color within brightness constraints."""
    hsv_cluster_centers = np.array([colorsys.rgb_to_hsv(*(center / 255.0)) for center in cluster_centers])

    colorfulness_metric = hsv_cluster_centers[:, 1] * hsv_cluster_centers[:, 2]
    sorted_indices = np.argsort(colorfulness_metric)[::-1]

    for index in sorted_indices:
        candidate_color = cluster_centers[index].astype(int)
        if is_brightness_in_range(candidate_color, min_brightness, max_brightness):
            return candidate_color

    # Fallback: Adjust brightness if no valid color is found
    return adjust_color_brightness(cluster_centers, colorfulness_metric, min_brightness, max_brightness)


def adjust_color_brightness(cluster_centers, colorfulness_metric, min_brightness, max_brightness):
    """Adjusts the brightness of the most colorful color until it's in range."""
    factor = 1.0
    adjustment_step = 0.05
    representative_color = cluster_centers[np.argmax(colorfulness_metric)].astype(int)

    while not is_brightness_in_range(representative_color, min_brightness, max_brightness):
        factor += (
            adjustment_step
            if calculate_brightness(representative_color) < min_brightness
            else -adjustment_step
        )
        representative_color = adjust_brightness(representative_color, factor)

        if factor <= 0.1 or factor >= 3.0:  # Prevent infinite loop
            break

    return representative_color


def get_representative_color(image_path):
    """Gets the most representative color from the image."""
    pixels = preprocess_image(image_path)
    cluster_centers = cluster_colors(pixels, n_clusters=DEFAULT_N_CLUSTERS)
    return find_most_representative_color(cluster_centers, MIN_BRIGHTNESS, MAX_BRIGHTNESS)


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
