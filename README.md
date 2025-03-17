# Partition Hex

A Zephyr module for nRF Connect SDK's Partition Manager that simplifies creating and including partition hex files in the build process, typically used for device provisioning data and other partition-specific content.

## Overview

This module provides functionality to:
- Generate hex files for specific partitions defined in the partition manager
- Execute custom commands to populate partitions with data
- Integrate with the Zephyr build system to include these partitions in the final firmware

It's particularly useful for provisioning data that needs to be generated during the build process, such as converting JSON configuration to binary formats, embedding protocol buffer data, or including other device-specific information.

## Installation

1. Add this repository as a module in your NCS application:

```bash
# Add to your west.yml
west:
  projects:
    - name: partition_hex
      url: https://github.com/nrb-tech/partition_hex
      path: modules/partition_hex
      revision: main
```

Now run `west update`. The module will be installed and used automatically during build.

## Configuration

### Kconfig

The module can be configured through Kconfig options:

| Option | Description |
|--------|-------------|
| `PARTITION_HEX` | Enable partition hex file generation |
| `PARTITION_HEX_PARTITIONS` | Semicolon-separated list of partitions to generate hex files for |
| `PARTITION_HEX_COMMANDS` | Semicolon-separated list of commands to generate the hex files |
| `PARTITION_HEX_DEPENDENCIES` | Optional semicolon-separated list of dependencies for the generation commands |

Each command will be provided with these arguments:
- `--address <address>` - The partition address from the partition manager
- `--output <output file>` - The output file path
- `--max-size <max size>` - The maximum size of the partition

For example, in your project's `prj.conf` or `sysbuild.conf` (if using sysbuild; prefix configs below with SB_):

```kconfig
CONFIG_PARTITION_HEX=y
CONFIG_PARTITION_HEX_PARTITIONS="app_provision"
CONFIG_PARTITION_HEX_COMMANDS="\${PYTHON_EXECUTABLE} \${APP_DIR}/scripts/generate_hex.py --json-file \${APPLICATION_CONFIG_DIR}/provision_data.json --prepend-length"
CONFIG_PARTITION_HEX_DEPENDENCIES="\${APPLICATION_CONFIG_DIR}/provision_data.json"
```

### Partition manager

In your pm_static.yml file, add a partition with the same name you configured, for example:

```yaml
app:
  address: 0x0
  region: flash_primary
  size: 0x7d000
app_provision:
  address: 0x7d000
  region: flash_primary
  size: 0x1000
settings_storage:
  address: 0x7e000
  region: flash_primary
  size: 0x2000
```

## Requirements

- Zephyr RTOS (tested with Zephyr version 3.7 and later)
- CMake 3.20 or newer
- Partition Manager enabled in your Zephyr application
- Only tested with sysbuild, but should also work without

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 