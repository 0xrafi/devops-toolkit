#!/bin/bash

DEVOPS_TOOLKIT_FILE="${HOME}/.devops_toolkit"

if [ -f "${DEVOPS_TOOLKIT_FILE}" ]; then
  SCRIPTS_DIR="$(cat "${DEVOPS_TOOLKIT_FILE}")"
else
  SCRIPTS_DIR="$(pwd)"
  echo "${SCRIPTS_DIR}" > "${DEVOPS_TOOLKIT_FILE}"
fi

TARGET_DIR="/usr/local/bin"

FOLDERS=("automation" "deployment" "monitoring" "project_management" "misc")

for folder in "${FOLDERS[@]}"; do
  if [ -d "${SCRIPTS_DIR}/${folder}" ]; then
    for script in "${SCRIPTS_DIR}/${folder}"/*.sh; do
      if [[ ! -d "$script" ]]; then
        chmod +x "$script"
        script_name=$(basename "$script")
        script_alias="${script_name%.*}"
        ln -sf "$script" "${TARGET_DIR}/${script_alias}"
      fi
    done
  fi
done

echo "Scripts have been installed and can be run from anywhere by their name."

