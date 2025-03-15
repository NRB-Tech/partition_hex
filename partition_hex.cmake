# Copyright (c) 2025 NRB Tech Ltd.
#
# SPDX-License-Identifier: MIT

# This CMakeLists.txt provides functionality for generating and including
# partition hex files in the build process.

set_ifndef(partition_manager_target partition_manager)

function(create_partition_hex partition_name generate_command)
  # Make depends optional by checking if a third argument was provided
  if(${ARGC} GREATER 2)
    set(depends ${ARGV2})
    set(has_depends TRUE)
  else()
    set(has_depends FALSE)
  endif()

  if (NCS_SYSBUILD_PARTITION_MANAGER)
    # Get the main app of the domain that secure boot should handle.
    get_property(main_app GLOBAL PROPERTY DOMAIN_APP_${SB_CONFIG_SECURE_BOOT_DOMAIN})
    ExternalProject_Get_Property(${main_app} BINARY_DIR)
    import_kconfig(CONFIG_ ${BINARY_DIR}/zephyr/.config)
    sysbuild_get(APPLICATION_CONFIG_DIR IMAGE ${main_app} VAR APPLICATION_CONFIG_DIR CACHE)
  endif()

  if (CONFIG_NCS_IS_VARIANT_IMAGE)
    # When building the variant of an image, skip this processing
    return()
  endif()

  # Build and include hex file containing provisioned data for the bootloader.
  set(PARTITION_HEX_NAME     ${partition_name}.hex)
  set(PARTITION_HEX          ${PROJECT_BINARY_DIR}/${PARTITION_HEX_NAME})
  string(TOUPPER "${partition_name}" UPPER_PARTITION_NAME)

  string(REPLACE " " ";" COMMAND_LIST "${generate_command}")

  # Create the add_custom_command with or without depends
  if(has_depends)
    add_custom_command(
      OUTPUT
      ${PARTITION_HEX}
      COMMAND
      ${COMMAND_LIST}
      --address $<TARGET_PROPERTY:${partition_manager_target},PM_${UPPER_PARTITION_NAME}_ADDRESS>
      --output ${PARTITION_HEX}
      --max-size $<TARGET_PROPERTY:${partition_manager_target},PM_${UPPER_PARTITION_NAME}_SIZE>
      DEPENDS
      ${depends}
      WORKING_DIRECTORY
      ${PROJECT_BINARY_DIR}
      COMMENT
      "Creating data to be stored in ${partition_name}, storing to ${PARTITION_HEX_NAME}"
      USES_TERMINAL
      )
  else()
    add_custom_command(
      OUTPUT
      ${PARTITION_HEX}
      COMMAND
      ${COMMAND_LIST}
      --address $<TARGET_PROPERTY:${partition_manager_target},PM_${UPPER_PARTITION_NAME}_ADDRESS>
      --output ${PARTITION_HEX}
      --max-size $<TARGET_PROPERTY:${partition_manager_target},PM_${UPPER_PARTITION_NAME}_SIZE>
      WORKING_DIRECTORY
      ${PROJECT_BINARY_DIR}
      COMMENT
      "Creating data to be stored in ${partition_name}, storing to ${PARTITION_HEX_NAME}"
      USES_TERMINAL
      )
  endif()

  add_custom_target(
    ${partition_name}_target
    DEPENDS
    ${PARTITION_HEX}
    )

  get_property(
    ${partition_name}_set
    GLOBAL PROPERTY ${partition_name}_PM_HEX_FILE SET
    )

  if(NOT ${partition_name}_set)
    # Set hex file and target for the partition placeholder
    set_property(
      GLOBAL PROPERTY
      ${partition_name}_PM_HEX_FILE
      ${PARTITION_HEX}
      )

    set_property(
      GLOBAL PROPERTY
      ${partition_name}_PM_TARGET
      ${partition_name}_target
      )

    if(NCS_SYSBUILD_PARTITION_MANAGER)
      # When using sysbuild, ensure the hex file is included in final build
      sysbuild_add_hex_file(${PARTITION_HEX} ${partition_name}_target)
    endif()
  endif()
endfunction() 