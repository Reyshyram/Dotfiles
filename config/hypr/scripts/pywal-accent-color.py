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
IMAGE_RESIZE_DIM = (200, 200)  # Dimensions to resize images for processing
PIXEL_SAMPLE_SIZE = 10000  # Number of pixels to randomly sample for clustering
DEFAULT_N_CLUSTERS = 8  # Default number of clusters to use in KMeans clustering
MIN_BRIGHTNESS = 96  # Minimum brightness level for considering a color valid
MAX_BRIGHTNESS = 164  # Maximum brightness level for considering a color valid
CSS_FILE_PATH = (
    Path.home() / ".cache" / "wal" / "colors-waybar.css"
)  # Path to the CSS file to update
CACHE_FILE_PATH = (
    Path.home() / ".cache" / "wal" / "colors-cache.json"
)  # Path to the cache file

# Set up logging configuration
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


def adjust_brightness(color, factor):
    """
    Adjust the brightness of an RGB color by a specified factor.

    Args:
        color (tuple): The RGB color to adjust, represented as (R, G, B).
        factor (float): The factor by which to adjust the brightness (e.g., 0.5 for darker, 2 for lighter).

    Returns:
        tuple: The adjusted RGB color.
    """
    return tuple(int(min(255, max(0, c * factor))) for c in color)


def is_brightness_in_range(color, min_brightness, max_brightness):
    """
    Check if the brightness of an RGB color falls within a specified range.

    Args:
        color (tuple): The RGB color to check, represented as (R, G, B).
        min_brightness (float): Minimum acceptable brightness value.
        max_brightness (float): Maximum acceptable brightness value.

    Returns:
        bool: True if the color's brightness is within the range; otherwise, False.
    """
    r, g, b = color
    brightness = 0.2126 * r + 0.7152 * g + 0.0722 * b
    return min_brightness <= brightness <= max_brightness


def compute_image_hash(image_path):
    """
    Compute a SHA-256 hash for an image file, which can be used to detect changes in the image.

    Args:
        image_path (str): Path to the image file.

    Returns:
        str: The SHA-256 hash of the image file.
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
    Load cached color data from a JSON file.

    Args:
        cache_file_path (Path): Path to the cache file.

    Returns:
        dict: Loaded cache data or an empty dictionary if the file cannot be read.
    """
    if cache_file_path.is_file():
        try:
            with cache_file_path.open(encoding="utf-8") as f:
                return json.load(f)
        except (OSError, json.JSONDecodeError) as e:
            logging.error(f"Error loading cache file: {e}")
    return {}


def save_cache(cache_file_path, cache):
    """
    Save color data to the cache file in JSON format.

    Args:
        cache_file_path (Path): Path to the cache file.
        cache (dict): Data to be saved in the cache file.
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
    Extract a representative color from an image within a specified brightness range using KMeans clustering.

    Args:
        image_path (str): Path to the image file.
        n_clusters (int): Number of clusters to form with KMeans.
        min_brightness (float): Minimum acceptable brightness for the color.
        max_brightness (float): Maximum acceptable brightness for the color.

    Returns:
        tuple: The representative RGB color that is within the specified brightness range.
    """
    try:
        # Open and preprocess the image
        with Image.open(image_path).convert("RGB") as img:
            img = img.resize(IMAGE_RESIZE_DIM)  # Resize image to reduce processing time
            pixels = (
                np.array(img).reshape(-1, 3).astype(np.float64) / 255.0
            )  # Normalize pixel values
            pixels = shuffle(
                pixels, random_state=42, n_samples=PIXEL_SAMPLE_SIZE
            )  # Sample pixels for clustering

            # Perform KMeans clustering
            kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
            kmeans.fit(pixels)

            cluster_centers = (
                kmeans.cluster_centers_ * 255.0
            )  # Denormalize cluster centers
            hsv_cluster_centers = np.array([
                colorsys.rgb_to_hsv(*(center / 255.0)) for center in cluster_centers
            ])  # Convert RGB to HSV for colorfulness measurement

            # Compute colorfulness metric and sort cluster centers by colorfulness
            colorfulness_metric = hsv_cluster_centers[:, 1] * hsv_cluster_centers[:, 2]
            sorted_indices = np.argsort(colorfulness_metric)[::-1]

            # Select the most colorfully representative color within brightness range
            for index in sorted_indices:
                candidate_color = cluster_centers[index].astype(int)
                if is_brightness_in_range(
                    candidate_color, min_brightness, max_brightness
                ):
                    return candidate_color

            # Fallback: Adjust brightness of the most colorfully representative color
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
    Append the representative color to a CSS file for use in theming.

    Args:
        css_file_path (Path): Path to the CSS file to update.
        representative_color (tuple): The RGB color to add to the CSS file.
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
        image_path (str): Path to the image file to process.
    """
    if not CSS_FILE_PATH.is_file():
        logging.error(f"CSS file does not exist: {CSS_FILE_PATH}")
        sys.exit(1)

    # Compute the hash of the image to check if it has been processed before
    image_hash = compute_image_hash(image_path)
    cache = load_cache(CACHE_FILE_PATH)

    # Use cached color if available
    if image_hash in cache:
        representative_color = tuple(cache[image_hash])
        logging.info(f"Using cached color: {representative_color}")
    else:
        representative_color = get_representative_color(image_path)
        logging.info(f"The representative color is {representative_color}")
        cache[image_hash] = [int(c) for c in representative_color]
        save_cache(CACHE_FILE_PATH, cache)

    # Update the CSS file with the new representative color
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
