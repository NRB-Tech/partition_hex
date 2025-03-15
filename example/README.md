# Partition Hex Example

This directory contains example files showing how to use the Partition Hex module.

## Files

- `generate_hex.py`: A Python script that demonstrates how to generate an Intel HEX file from JSON data
- `sample_data.json`: An example JSON file containing sample provisioning data

## Usage

To use this example, you would typically:

1. Define a partition in your application's partition manager configuration
2. Configure the Partition Hex module in your application's `prj.conf` or `sysbuild.conf`
3. Run your build, which will invoke the script to generate the hex file

### Example Command Line

```bash
# Manual execution example (normally called by CMake)
python generate_hex.py \
  --address 0x80000 \
  --output provision_data.hex \
  --max-size 4096 \
  --json-file sample_data.json \
  --magic 0x57FA57FA \
  --prepend-length
```

### Example Configuration

```
CONFIG_PARTITION_HEX=y
CONFIG_PARTITION_HEX_PARTITIONS="app_provision"
CONFIG_PARTITION_HEX_COMMANDS="${PYTHON_EXECUTABLE} ${APP_DIR}/modules/partition_hex/example/generate_hex.py --json-file ${APPLICATION_CONFIG_DIR}/provisioning_data.json --magic 0x57FA57FA --prepend-length"
CONFIG_PARTITION_HEX_DEPENDENCIES="${APPLICATION_CONFIG_DIR}/provisioning_data.json"
```

## Requirements

- Python 3.6 or later
- IntelHex Python package (`pip install intelhex`) 