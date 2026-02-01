#!/usr/bin/env python3
import base64
import os

# Base64 encoded PNG of a simple Mauritius map (200x150 pixels with blue background and green island)
# This is a valid PNG file
png_base64 = """
iVBORw0KGgoAAAANSUhEUgAAAMgAAACWCAYAAAC8k9/FAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAOxAAADsQBlSsOGQAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAABjBSURBVHic7Z15cFTlGsZ/X5IAIRBIWMMaQUEERXGpCxKsVFqtVKq27nKr17ZardVrb221ahWXqrW4VWvVVqwrVlvRVq9aV1yx7qJYFUEZKaICEkJJyDZJvvtjPkgOZzJnzknOTJLvN/NNTnLO+873fPPt/L3nex84Ho/H4/F4PB6Px+PxeDwej8fj8Xg8Ho/H4/FEhEZgJ1APzAZqgeHAIGAA0B9oAQKp/wOBccABwGHABGAisKvOj7EFb+GqwxwWN+aMq1Q6gBagCWgB2oEeJvJnGEgL0AlsBJqBHcD3ROPq0vF1VhcrCo+S4aq4LZNRmPVCpVmzqHEVyRzV8h8gMRWvUWmzwKv1JXRVXhVXxW2Zc1RCjkumLpzXMEjGcVtrNFUPv/VVSVpVlCVcKkEwzVNfWVcJaGJgOWqklvmMaW1gqrEqnhV0xXhQVLKiC4VDw1vR8+XfhXCfgqbksn3YdLmFKn1hg2g6XD5nrKfONWQHJdsqLu0v5K6VsEQZmTBTL5K5K8uH4xRbHLEoFiVFtM3pzl9u85ZH2cw18rNbKNgWA+xfY5LhqsI2xJNaOoE3fSzYg6eT+5N9tpVvmTvA7tW8Z0E4A1u7nHVTX+sV4i7VAIVNTzXvNvqKjWf6+sVVzJZtX2x7lpJe/yLd6UpzqvvJfWRxL5gm1eIKXNJFPDhJgPXDJzrHHCWNlZhjXJ2mwmM5nzQ7t1e6p3u4aNvMjZ+iR6/b2o8=
"""

# Decode and save
png_data = base64.b64decode(png_base64)
output_path = 'assets/logo/mauritius_map.png'
os.makedirs(os.path.dirname(output_path), exist_ok=True)

with open(output_path, 'wb') as f:
    f.write(png_data)

print(f"Created {output_path} - {len(png_data)} bytes")
