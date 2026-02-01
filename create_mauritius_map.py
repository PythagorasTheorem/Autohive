#!/usr/bin/env python3
"""Create a Mauritius map PNG using PIL"""
from PIL import Image, ImageDraw, ImageFont
import os

# Create a new image with light blue background (representing water)
width, height = 400, 300
img = Image.new('RGB', (width, height), color=(173, 216, 230))  # Light blue

draw = ImageDraw.Draw(img)

# Draw Mauritius main island shape (simplified polygon)
# Approximate coordinates for the main island
island_coords = [
    (120, 80),    # top-left
    (180, 60),    # top
    (220, 80),    # top-right
    (240, 120),   # right
    (235, 170),   # bottom-right
    (200, 190),   # bottom
    (150, 200),   # bottom-left
    (100, 170),   # left
    (95, 120),    # top-left
]

# Draw the main island
draw.polygon(island_coords, fill=(144, 238, 144), outline=(0, 100, 0))  # Green with dark green outline

# Draw Port Louis (capital) marker
draw.ellipse([(110, 100), (125, 115)], fill=(255, 0, 0))  # Red dot

# Add text labels
try:
    # Try to draw text
    draw.text((130, 105), "Port Louis", fill=(255, 0, 0))
    draw.text((100, 220), "MAURITIUS", fill=(0, 0, 0))
except:
    pass

# Save the image
output_path = os.path.join(os.path.dirname(__file__), 'assets', 'logo', 'mauritius_map.png')
os.makedirs(os.path.dirname(output_path), exist_ok=True)
img.save(output_path, 'PNG')

print(f"Created Mauritius map at {output_path}")
print(f"File size: {os.path.getsize(output_path)} bytes")
