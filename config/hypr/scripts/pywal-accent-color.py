import colorsys
import hashlib
import json
import os
import sys

import numpy as np
from PIL import Image
from sklearn.cluster import KMeans
from sklearn.utils import shuffle

# Constants for configuration
IMAGE_RESIZE_DIM = (200, 200)  # Resize dimensions for image processing
PIXEL_SAMPLE_SIZE = (
    10000  # Number of pixels to sample for clustering to speed up processing
)
DEFAULT_N_CLUSTERS = 5  # Default number of clusters for KMeans algorithm
MIN_BRIGHTNESS = 64  # Minimum brightness level for the color to be considered valid
MAX_BRIGHTNESS = 168  # Maximum brightness level for the color to be considered valid
CSS_FILE_PATH = os.path.expanduser(
    "~/.cache/wal/colors-waybar.css"
)  # Path to the CSS file to be updated
CACHE_FILE_PATH = os.path.expanduser(
    "~/.cache/wal/colors-cache.json"
)  # Path to the cache file


def adjust_brightness(color, factor):
    """Adjust the brightness of a given RGB color by a specified factor.

    Args:
        color (tuple): The RGB color as a tuple of integers (R, G, B).
        factor (float): The factor by which to adjust the brightness (e.g., 1.1 to lighten, 0.9 to darken).

    Returns:
        tuple: The adjusted RGB color as a tuple of integers.
    """
    # Adjust each color component (R, G, B) by the factor, ensuring values stay within 0-255
    return tuple(int(min(255, max(0, c * factor))) for c in color)


def is_brightness_in_range(color, min_brightness, max_brightness):
    """Check if the color's brightness is within the desired range.

    Args:
        color (tuple): The RGB color as a tuple of integers (R, G, B).
        min_brightness (float): Minimum acceptable brightness value.
        max_brightness (float): Maximum acceptable brightness value.

    Returns:
        bool: True if the color's brightness is within the specified range, False otherwise.
    """
    r, g, b = color
    # Calculate brightness using the luminance formula
    brightness = 0.2126 * r + 0.7152 * g + 0.0722 * b
    return min_brightness <= brightness <= max_brightness


def compute_image_hash(image_path):
    """Compute a hash for the image file.

    Args:
        image_path (str): Path to the image file.

    Returns:
        str: The SHA-256 hash of the image file contents.
    """
    hash_sha256 = hashlib.sha256()
    with open(image_path, "rb") as f:
        while chunk := f.read(8192):
            hash_sha256.update(chunk)
    return hash_sha256.hexdigest()


def load_cache(cache_file_path):
    """Load the cache from the cache file.

    Args:
        cache_file_path (str): Path to the cache file.

    Returns:
        dict: The cache as a dictionary.
    """
    if os.path.isfile(cache_file_path):
        with open(cache_file_path, encoding="utf-8") as f:
            return json.load(f)
    return {}


def save_cache(cache_file_path, cache):
    """Save the cache to the cache file.

    Args:
        cache_file_path (str): Path to the cache file.
        cache (dict): The cache to save.
    """
    with open(cache_file_path, "w", encoding="utf-8") as f:
        json.dump(cache, f, indent=4)


def get_representative_color(
    image_path,
    n_clusters=DEFAULT_N_CLUSTERS,
    min_brightness=MIN_BRIGHTNESS,
    max_brightness=MAX_BRIGHTNESS,
):
    """Extract a representative color from the image that stands out within the given brightness range.

    Args:
        image_path (str): Path to the image file.
        n_clusters (int): Number of clusters for KMeans clustering.
        min_brightness (float): Minimum brightness for the color to be considered valid.
        max_brightness (float): Maximum brightness for the color to be considered valid.

    Returns:
        tuple: The representative RGB color as a tuple of integers.
    """
    try:
        # Open and preprocess the image
        with Image.open(image_path).convert("RGB") as img:
            img = img.resize(
                IMAGE_RESIZE_DIM
            )  # Resize image to reduce computation time
            # Flatten the image into a list of RGB tuples and normalize pixel values
            pixels = np.array(img).reshape(-1, 3).astype(np.float64) / 255.0

        # Sample a subset of pixels for clustering to improve performance
        pixels = shuffle(pixels, random_state=42, n_samples=PIXEL_SAMPLE_SIZE)

        # Perform KMeans clustering to find dominant colors
        kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
        kmeans.fit(pixels)
        # Convert cluster centers from normalized (0-1) to standard (0-255) RGB values
        cluster_centers = kmeans.cluster_centers_ * 255.0

        # Convert RGB cluster centers to HSV color space for better color representation
        hsv_cluster_centers = np.array([
            colorsys.rgb_to_hsv(*(center / 255.0)) for center in cluster_centers
        ])

        # Calculate saturation and brightness (value) for each cluster center
        saturation_brightness = hsv_cluster_centers[:, 1] * hsv_cluster_centers[:, 2]
        # Choose the cluster center with the highest saturation * brightness product
        representative_color = cluster_centers[np.argmax(saturation_brightness)].astype(
            int
        )

        # Adjust the color's brightness until it fits within the specified range
        factor = 1.0
        while not is_brightness_in_range(
            representative_color, min_brightness, max_brightness
        ):
            if sum(representative_color) < min_brightness * 3:
                factor *= 1.1  # Increase brightness
            else:
                factor *= 0.9  # Decrease brightness
            # Update the color with the new brightness factor
            representative_color = adjust_brightness(representative_color, factor)

        return representative_color

    except Exception as e:
        # Handle any errors that occur during image processing
        print(f"Error processing image: {e}")
        sys.exit(1)


def update_css_file(css_file_path, color_hex):
    """Append the representative color to the CSS file.

    Args:
        css_file_path (str): Path to the CSS file.
        color_hex (str): The representative color in hex format.
    """
    css_line = f"@define-color accent {color_hex};\n"
    # Append the color definition to the CSS file
    with open(css_file_path, "a", encoding="utf-8") as file:
        file.write(css_line)
    print(f"Appended the line to {css_file_path}")


def main(image_path):
    """Main function to find the representative color and update the CSS file."""
    if not os.path.isfile(CSS_FILE_PATH):
        print(f"CSS file does not exist: {CSS_FILE_PATH}")
        sys.exit(1)

    image_hash = compute_image_hash(image_path)
    cache = load_cache(CACHE_FILE_PATH)

    if image_hash in cache:
        representative_color_hex = cache[image_hash]
        print(f"Using cached color: {representative_color_hex}")
    else:
        representative_color = get_representative_color(image_path)
        representative_color_hex = "#{:02x}{:02x}{:02x}".format(*representative_color)
        cache[image_hash] = representative_color_hex
        save_cache(CACHE_FILE_PATH, cache)

    update_css_file(CSS_FILE_PATH, representative_color_hex)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <image_path>")
        sys.exit(1)

    image_path = sys.argv[1]
    if not os.path.isfile(image_path):
        print(f"Image file does not exist: {image_path}")
        sys.exit(1)

    main(image_path)
