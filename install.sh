#!/bin/bash

DEVOPS_TOOLKIT_FILE="${HOME}/.devops_toolkit"

if [ -f "${DEVOPS_TOOLKIT_FILE}" ]; then
  SCRIPTS_DIR="$(cat "${DEVOPS_TOOLKIT_FILE}")"
else
  SCRIPTS_DIR="$(pwd)"
  echo "${SCRIPTS_DIR}" >"${DEVOPS_TOOLKIT_FILE}"
fi

TARGET_DIR="/usr/local/bin"

FOLDERS=("automation" "deployment" "monitoring" "project_management" "misc")

FILE_EXTENSIONS=("sh" "py")

function install_script() {
  local script="$1"
  local target_dir="$2"
  local ext="$3"

  chmod +x "$script"
  script_name=$(basename "$script")
  script_alias="${script_name%.*}"

  if [[ "$ext" == "py" ]]; then
    # Create a wrapper script for Python files
    wrapper="${target_dir}/${script_alias}"
    echo "#!/bin/bash" >"${wrapper}"
    echo "python3 \"${script}\" \"\$@\"" >>"${wrapper}"
    chmod +x "${wrapper}"
  else
    ln -sf "$script" "${target_dir}/${script_alias}"
  fi
}

for folder in "${FOLDERS[@]}"; do
  if [ -d "${SCRIPTS_DIR}/${folder}" ]; then
    for ext in "${FILE_EXTENSIONS[@]}"; do
      for script in "${SCRIPTS_DIR}/${folder}"/*.${ext}; do
        if [[ -f "$script" ]]; then
          install_script "$script" "${TARGET_DIR}" "${ext}"
        fi
      done
    done
  fi
done

echo "Scripts have been installed and can be run from anywhere by their name."
