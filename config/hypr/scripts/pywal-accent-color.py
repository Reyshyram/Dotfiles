import colorsys
import hashlib
import json
import logging
import sys
from pathlib import Path

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
CSS_FILE_PATH = (
    Path.home() / ".cache" / "wal" / "colors-waybar.css"
)  # Path to the CSS file to be updated
CACHE_FILE_PATH = (
    Path.home() / ".cache" / "wal" / "colors-cache.json"
)  # Path to the cache file

# Set up logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


def adjust_brightness(color, factor):
    """
    Adjust the brightness of an RGB color by a specified factor.

    Args:
        color (tuple): The RGB color to adjust.
        factor (float): The factor by which to adjust the brightness.

    Returns:
        tuple: The adjusted RGB color.
    """
    return tuple(int(min(255, max(0, c * factor))) for c in color)


def is_brightness_in_range(color, min_brightness, max_brightness):
    """
    Check if the color's brightness is within the desired range.

    Args:
        color (tuple): The RGB color to check.
        min_brightness (float): Minimum brightness level.
        max_brightness (float): Maximum brightness level.

    Returns:
        bool: True if the color's brightness is within the range, otherwise False.
    """
    r, g, b = color
    brightness = 0.2126 * r + 0.7152 * g + 0.0722 * b
    return min_brightness <= brightness <= max_brightness


def compute_image_hash(image_path):
    """
    Compute a SHA-256 hash for the image file.

    Args:
        image_path (str): Path to the image file.

    Returns:
        str: SHA-256 hash of the image file.
    """
    hash_sha256 = hashlib.sha256()
    try:
        with open(image_path, "rb") as f:
            while chunk := f.read(8192):
                hash_sha256.update(chunk)
    except OSError as e:
        logging.error(f"Error reading image file: {e}")
        sys.exit(1)
    return hash_sha256.hexdigest()


def load_cache(cache_file_path):
    """
    Load the cache from the cache file.

    Args:
        cache_file_path (Path): Path to the cache file.

    Returns:
        dict: The loaded cache.
    """
    if cache_file_path.is_file():
        try:
            with cache_file_path.open(encoding="utf-8") as f:
                return json.load(f)
        except (OSError, json.JSONDecodeError) as e:
            logging.error(f"Error loading cache file: {e}")
            return {}
    return {}


def save_cache(cache_file_path, cache):
    """
    Save the cache to the cache file.

    Args:
        cache_file_path (Path): Path to the cache file.
        cache (dict): The cache to save.
    """
    try:
        with cache_file_path.open("w", encoding="utf-8") as f:
            json.dump(cache, f, indent=4)
    except OSError as e:
        logging.error(f"Error saving cache file: {e}")
        sys.exit(1)


def get_representative_color(
    image_path,
    n_clusters=DEFAULT_N_CLUSTERS,
    min_brightness=MIN_BRIGHTNESS,
    max_brightness=MAX_BRIGHTNESS,
):
    """
    Extract a representative color from the image within the given brightness range.

    Args:
        image_path (str): Path to the image file.
        n_clusters (int): Number of clusters for KMeans.
        min_brightness (float): Minimum brightness level.
        max_brightness (float): Maximum brightness level.

    Returns:
        tuple: The representative RGB color.
    """
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

            # Fallback: Adjust the color's brightness
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
    """
    Append the representative color to the CSS file.

    Args:
        css_file_path (Path): Path to the CSS file.
        representative_color (tuple): The representative RGB color.
    """
    hex_color = f"#{representative_color[0]:02x}{representative_color[1]:02x}{representative_color[2]:02x}"
    css_line = f"@define-color accent {hex_color};\n"

    try:
        with css_file_path.open("a", encoding="utf-8") as file:
            file.write(css_line)
        logging.info(f"Appended the line to {css_file_path}")
    except OSError as e:
        logging.error(f"Error updating CSS file: {e}")
        sys.exit(1)


def main(image_path):
    """
    Main function to process the image and update the CSS file with the representative color.

    Args:
        image_path (str): Path to the image file.
    """
    if not CSS_FILE_PATH.is_file():
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

    image_path = Path(sys.argv[1])
    if not image_path.is_file():
        logging.error(f"Image file does not exist: {image_path}")
        sys.exit(1)

    main(image_path)
