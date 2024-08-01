import os
import sys

import numpy as np
from PIL import Image
from skimage.color import rgb2hsv
from sklearn.cluster import KMeans
from sklearn.utils import shuffle


def get_vibrant_color(image_path, n_clusters=5):
    """Extract the most vibrant color from an image."""
    try:
        # Open the image and convert to RGB
        image = Image.open(image_path).convert("RGB")

        # Resize image to reduce the number of pixels and improve performance
        image = image.resize((100, 100))  # Slightly larger resize for better accuracy

        # Convert image to numpy array and normalize pixel values
        pixels = np.array(image).reshape(-1, 3).astype(np.float64) / 255.0

        # Reduce the number of pixels for faster clustering
        pixels = shuffle(pixels, random_state=42, n_samples=10000)

        # Apply KMeans clustering
        kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10).fit(pixels)
        cluster_centers = kmeans.cluster_centers_ * 255.0  # Convert back to 0-255 range

        # Find the most vibrant color based on HSV saturation and value
        max_saturation = -1
        vibrant_color = None

        for color in cluster_centers:
            hsv_color = rgb2hsv(color[np.newaxis, np.newaxis, :]).reshape(-1, 3)
            saturation, value = hsv_color[0, 1], hsv_color[0, 2]
            if saturation > max_saturation and value > 0.5:
                max_saturation = saturation
                vibrant_color = color.astype(int)

        if vibrant_color is None:
            raise ValueError("No vibrant color found.")

        return vibrant_color

    except Exception as e:
        print(f"Error processing image: {e}")
        sys.exit(1)


def main(image_path):
    """Main function to update the CSS file with the vibrant color."""
    css_file_path = os.path.expanduser("~/.cache/wal/colors-waybar.css")

    # Ensure the CSS file exists
    if not os.path.isfile(css_file_path):
        print(f"CSS file does not exist: {css_file_path}")
        sys.exit(1)

    # Find the most vibrant color
    vibrant_color = get_vibrant_color(image_path)
    vibrant_color_hex = "#{:02x}{:02x}{:02x}".format(*vibrant_color)

    # Write the color to the CSS file
    css_line = f"@define-color accent {vibrant_color_hex};\n"
    with open(css_file_path, "a") as file:
        file.write(css_line)

    print(f"Appended the line to {css_file_path}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <image_path>")
        sys.exit(1)

    image_path = sys.argv[1]
    if not os.path.isfile(image_path):
        print(f"Image file does not exist: {image_path}")
        sys.exit(1)

    main(image_path)
