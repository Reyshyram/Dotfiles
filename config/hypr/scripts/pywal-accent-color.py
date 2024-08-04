import colorsys
import hashlib
import json
import logging
import os
import sys

import numpy as np
from PIL import Image
from sklearn.cluster import KMeans
from sklearn.utils import shuffle

# Constants for configuration
IMAGE_RESIZE_DIM = (200, 200)  # Resize dimensions for image processing
PIXEL_SAMPLE_SIZE = 10000  # Number of pixels to sample for clustering
DEFAULT_N_CLUSTERS = 8  # Default number of clusters for KMeans algorithm
MIN_BRIGHTNESS = 96  # Minimum brightness level for the color to be considered valid
MAX_BRIGHTNESS = 164  # Maximum brightness level for the color to be considered valid
CSS_FILE_PATH = os.path.expanduser(
    "~/.cache/wal/colors-waybar.css"
)  # Path to the CSS file to be updated
CACHE_FILE_PATH = os.path.expanduser(
    "~/.cache/wal/colors-cache.json"
)  # Path to the cache file

# Set up logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


def adjust_brightness(color, factor):
    """Adjust the brightness of an RGB color by a specified factor."""
    return tuple(int(min(255, max(0, c * factor))) for c in color)


def is_brightness_in_range(color, min_brightness, max_brightness):
    """Check if the color's brightness is within the desired range."""
    r, g, b = color
    brightness = 0.2126 * r + 0.7152 * g + 0.0722 * b
    return min_brightness <= brightness <= max_brightness


def compute_image_hash(image_path):
    """Compute a SHA-256 hash for the image file."""
    hash_sha256 = hashlib.sha256()
    with open(image_path, "rb") as f:
        while chunk := f.read(8192):
            hash_sha256.update(chunk)
    return hash_sha256.hexdigest()


def load_cache(cache_file_path):
    """Load the cache from the cache file."""
    if os.path.isfile(cache_file_path):
        with open(cache_file_path, encoding="utf-8") as f:
            return json.load(f)
    return {}


def save_cache(cache_file_path, cache):
    """Save the cache to the cache file."""
    with open(cache_file_path, "w", encoding="utf-8") as f:
        json.dump(cache, f, indent=4)


def get_representative_color(
    image_path,
    n_clusters=DEFAULT_N_CLUSTERS,
    min_brightness=MIN_BRIGHTNESS,
    max_brightness=MAX_BRIGHTNESS,
):
    """Extract a representative color from the image within the given brightness range."""
    try:
        with Image.open(image_path).convert("RGB") as img:
            img = img.resize(IMAGE_RESIZE_DIM)
            pixels = np.array(img).reshape(-1, 3).astype(np.float64) / 255.0
            pixels = shuffle(pixels, random_state=42, n_samples=PIXEL_SAMPLE_SIZE)
            kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
            kmeans.fit(pixels)

            cluster_centers = kmeans.cluster_centers_ * 255.0
            hsv_cluster_centers = np.array([
                colorsys.rgb_to_hsv(*(center / 255.0)) for center in cluster_centers
            ])

            colorfulness_metric = hsv_cluster_centers[:, 1] * hsv_cluster_centers[:, 2]
            sorted_indices = np.argsort(colorfulness_metric)[::-1]

            for index in sorted_indices:
                candidate_color = cluster_centers[index].astype(int)
                if is_brightness_in_range(
                    candidate_color, min_brightness, max_brightness
                ):
                    return candidate_color

            factor = 1.0
            adjustment_step = 0.05
            representative_color = cluster_centers[
                np.argmax(colorfulness_metric)
            ].astype(int)

            while not is_brightness_in_range(
                representative_color, min_brightness, max_brightness
            ):
                factor += (
                    adjustment_step
                    if sum(representative_color) < min_brightness * 3
                    else -adjustment_step
                )
                representative_color = adjust_brightness(representative_color, factor)
                if factor <= 0.1 or factor >= 2.0:
                    break

            return representative_color

    except Exception as e:
        logging.error(f"Error processing image: {e}")
        sys.exit(1)


def update_css_file(css_file_path, representative_color):
    """Append the representative color to the CSS file."""
    hex_color = f"#{representative_color[0]:02x}{representative_color[1]:02x}{representative_color[2]:02x}"
    css_line = f"@define-color accent {hex_color};\n"

    with open(css_file_path, "a", encoding="utf-8") as file:
        file.write(css_line)
    logging.info(f"Appended the line to {css_file_path}")


def main(image_path):
    if not os.path.isfile(CSS_FILE_PATH):
        logging.error(f"CSS file does not exist: {CSS_FILE_PATH}")
        sys.exit(1)

    image_hash = compute_image_hash(image_path)
    cache = load_cache(CACHE_FILE_PATH)

    if image_hash in cache:
        representative_color = tuple(cache[image_hash])
        logging.info(f"Using cached color: {representative_color}")
    else:
        representative_color = get_representative_color(image_path)
        logging.info(f"The representative color is {representative_color}")
        cache[image_hash] = [int(c) for c in representative_color]
        save_cache(CACHE_FILE_PATH, cache)

    update_css_file(CSS_FILE_PATH, representative_color)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        logging.error("Usage: python script.py <image_path>")
        sys.exit(1)

    image_path = sys.argv[1]
    if not os.path.isfile(image_path):
        logging.error(f"Image file does not exist: {image_path}")
        sys.exit(1)

    main(image_path)
