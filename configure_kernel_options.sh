#!/bin/bash

# Kernel configuration file
CONFIG_FILE="kernel/config/config"

# Options with their values to set
# Format: "option=value"
OPTIONS_WITH_VALUES=(
  "CONFIG_DEBUG_INFO=n"
  "CONFIG_GDB_SCRIPTS=n"
  "CONFIG_SOMETHING_USEFUL=y"
  "CONFIG_ANOTHER_OPTION=m"
)

# Function to add or modify an option in the configuration file
modify_config() {
  local option_value=$1
  local option=${option_value%%=*}
  local value=${option_value#*=}

  if grep -q "^${option}=" "$CONFIG_FILE"; then
    # Option already exists, update its value
    sed -i "s/^${option}=.*/${option}=${value}/" "$CONFIG_FILE"
    echo "Changed ${option} to ${option}=${value}"
  else
    # Option does not exist, add it with the specified value
    echo "${option}=${value}" >> "$CONFIG_FILE"
    echo "Added ${option}=${value}"
  fi
}

# Check if the configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: configuration file $CONFIG_FILE does not exist."
  exit 1
fi

# Modify or add the options with specified values
for option_value in "${OPTIONS_WITH_VALUES[@]}"; do
  modify_config "$option_value"
done

echo "Operation completed."
