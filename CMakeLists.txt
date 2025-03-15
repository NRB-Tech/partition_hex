# Copyright (c) 2025 NRB Tech Ltd.
#
# SPDX-License-Identifier: MIT

macro(get_sb_or_app_config_var varname required)
  if (DEFINED SB_CONFIG_${varname})
    set(${varname} ${SB_CONFIG_${varname}})
  elseif (DEFINED CONFIG_${varname})
    set(${varname} ${CONFIG_${varname}})
  elseif(COMMAND sysbuild_get)
    sysbuild_get(${varname} IMAGE ${DEFAULT_IMAGE} VAR CONFIG_${varname} CACHE)
  endif()
  if (${required} AND NOT DEFINED ${varname})
    message(FATAL_ERROR "Required variable ${varname} is not defined")
  endif()
endmacro()

get_sb_or_app_config_var(PARTITION_HEX FALSE)

if(NOT DEFINED PARTITION_HEX OR PARTITION_HEX STREQUAL "" OR PARTITION_HEX STREQUAL "n")
  message(STATUS "PARTITION_HEX is not enabled")
  return()
endif()

# Get paths and variables from the application image
get_sb_or_app_config_var(PARTITION_HEX_PARTITIONS TRUE)
get_sb_or_app_config_var(PARTITION_HEX_COMMANDS TRUE)
get_sb_or_app_config_var(PARTITION_HEX_DEPENDENCIES FALSE)

message(STATUS "Configuring partition hex")
message(STATUS "PARTITION_HEX_PARTITIONS: ${PARTITION_HEX_PARTITIONS}")
message(STATUS "PARTITION_HEX_COMMANDS: ${PARTITION_HEX_COMMANDS}")
message(STATUS "PARTITION_HEX_DEPENDENCIES: ${PARTITION_HEX_DEPENDENCIES}")

# Split the commands into a list
string(REPLACE ";" ";" PARTITION_HEX_COMMANDS "${PARTITION_HEX_COMMANDS}")

# split the partitions into a list
string(REPLACE ";" ";" PARTITION_HEX_PARTITIONS "${PARTITION_HEX_PARTITIONS}")

# split the dependencies into a list
string(REPLACE ";" ";" PARTITION_HEX_DEPENDENCIES "${PARTITION_HEX_DEPENDENCIES}")

list(LENGTH PARTITION_HEX_PARTITIONS num_partitions)
list(LENGTH PARTITION_HEX_COMMANDS num_commands)

if(NOT num_partitions EQUAL num_commands)
  message(FATAL_ERROR "The number of commands and partitions must be the same. Partitions: ${num_partitions}, Commands: ${num_commands}")
endif()

# create the partition hex files

include(${CMAKE_CURRENT_LIST_DIR}/partition_hex.cmake)
math(EXPR last_index "${num_partitions}-1")
foreach(index RANGE 0 ${last_index})
  list(GET PARTITION_HEX_PARTITIONS ${index} PARTITION)
  list(GET PARTITION_HEX_COMMANDS ${index} COMMAND)
  if (DEFINED PARTITION_HEX_DEPENDENCIES AND NOT PARTITION_HEX_DEPENDENCIES STREQUAL "")
    list(GET PARTITION_HEX_DEPENDENCIES ${index} DEPENDENCIES)
  else()
    set(DEPENDENCIES "")
  endif()
  
  # configure the command string to replace variables
  string(CONFIGURE "${COMMAND}" CONFIGURED_COMMAND)
  string(CONFIGURE "${DEPENDENCIES}" CONFIGURED_DEPENDENCIES)
  
  create_partition_hex(
    ${PARTITION}
    ${CONFIGURED_COMMAND}
    ${CONFIGURED_DEPENDENCIES}
  )
endforeach()
