#!/usr/bin/env python3
"""Generate a simple PNG placeholder for Mauritius map"""
import struct

def create_simple_png():
    """Create a minimal valid PNG image (light blue rectangle)"""
    # PNG signature
    png_sig = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk (image header) - 13x13 blue image  
    ihdr_data = struct.pack('>IIBBBBB', 256, 128, 8, 2, 0, 0, 0)  # width, height, bit_depth, color_type, etc
    ihdr_crc = 0x9c4e3f55  # Pre-calculated CRC
    ihdr = b'IHDR' + ihdr_data
    
    # IDAT chunk (image data) - simple compressed blue rectangle
    idat_data = b'\x08\x1d\x01\x02\x00\xfd\xff\x00\x00\xff\xff\x00\x00\xff\xff' * 10
    idat_crc = 0x12345678  # Placeholder
    idat = b'IDAT' + idat_data
    
    # IEND chunk (image end)
    iend = b'IEND\xae\x42\x60\x82'
    
    # Simple valid minimal PNG
    png = png_sig
    
    # Use a very basic approach: create smallest valid PNG (1x1 transparent)
    # PNG signature
    png = b'\x89PNG\r\n\x1a\n'
    # IHDR: 1x1 image, 8-bit grayscale
    ihdr_chunk = b'\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x00\x00\x00\x00:~\x9bU'
    # IDAT: single gray pixel
    idat_chunk = b'\x00\x00\x00\x0cIDAT\x08\x99c\x00\x00\x00\x02\x00\x01\x00\x00\x01\x18\xdd\x8d\xb4'
    # IEND
    iend_chunk = b'\x00\x00\x00\x00IEND\xaeB`\x82'
    
    return png + ihdr_chunk + idat_chunk + iend_chunk

if __name__ == '__main__':
    with open('assets/logo/mauritius_map.png', 'wb') as f:
        f.write(create_simple_png())
    print('Created placeholder mauritius_map.png')
