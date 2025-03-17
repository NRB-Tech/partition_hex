#!/usr/bin/env python3
# Copyright (c) 2025 NRB Tech Ltd.
#
# SPDX-License-Identifier: MIT

"""Example script for generating a hex file for use with the partition_hex module.

This script demonstrates the expected argument format and produces a valid hex file.
"""

import argparse
import json
import struct
import sys
from typing import Any, Dict
from intelhex import IntelHex


def main() -> None:
    """Generate a hex file from JSON data.

    Reads a JSON file, converts its content to a binary format, adds optional
    headers (magic number and length), and writes the result to an Intel HEX file.

    Args:
        None: Arguments are parsed from command line

    Returns:
        None
    """
    parser = argparse.ArgumentParser(description="Generate a hex file from JSON data")
    parser.add_argument("--address", type=int, required=True, help="Base address for the hex file")
    parser.add_argument("--output", type=str, required=True, help="Output file path")
    parser.add_argument("--max-size", type=int, required=True, help="Maximum size of the output data")
    parser.add_argument("--json-file", type=str, required=True, help="JSON file to convert")
    parser.add_argument("--magic", type=str, default="0x12345678", help="Magic number to prepend (hex format)")
    parser.add_argument("--prepend-length", action="store_true", help="Prepend 4-byte length to data")
    args = parser.parse_args()

    # Read JSON file
    try:
        with open(args.json_file, 'r') as f:
            data: Dict[str, Any] = json.load(f)
    except Exception as e:
        print(f"Error reading JSON file: {e}")
        sys.exit(1)

    # Convert to binary
    try:
        # This is just an example - in a real implementation,
        # you would serialize the data using e.g. protobuf or
        # some other serialization format.
        serialized: bytes = json.dumps(data).encode('utf-8')
    except Exception as e:
        print(f"Error serializing data: {e}")
        sys.exit(1)

    # Check size
    magic_size: int = 4 if args.magic else 0
    length_size: int = 4 if args.prepend_length else 0
    header_size: int = magic_size + length_size
    data_size: int = len(serialized)
    total_size: int = header_size + data_size

    if total_size > args.max_size:
        print(f"Error: Data size ({total_size} bytes) exceeds maximum size ({args.max_size} bytes)")
        sys.exit(1)

    # Create binary buffer
    buffer: bytearray = bytearray()

    # Add magic number if specified
    if args.magic:
        magic_value: int = int(args.magic, 0)  # Parse hex or decimal string
        buffer.extend(struct.pack("<I", magic_value))

    # Add length if requested
    if args.prepend_length:
        buffer.extend(struct.pack("<I", data_size))

    # Add serialized data
    buffer.extend(serialized)

    # Create Intel HEX file
    ih = IntelHex()
    for i, b in enumerate(buffer):
        ih[args.address + i] = b

    # Write output file
    try:
        ih.write_hex_file(args.output)
        print(f"Successfully wrote {total_size} bytes to {args.output}")
    except Exception as e:
        print(f"Error writing hex file: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
