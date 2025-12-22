#!/bin/bash
# install.sh - Install devops-toolkit scripts globally

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}DevOps Toolkit - Global Installation${NC}"
echo ""

# Track installation directory
DEVOPS_TOOLKIT_FILE="${HOME}/.devops_toolkit"

if [ -f "${DEVOPS_TOOLKIT_FILE}" ]; then
  SCRIPTS_DIR="$(cat "${DEVOPS_TOOLKIT_FILE}")"
  echo "Found existing installation: $SCRIPTS_DIR"
else
  SCRIPTS_DIR="$(pwd)"
  echo "${SCRIPTS_DIR}" >"${DEVOPS_TOOLKIT_FILE}"
  echo "Recording installation directory: $SCRIPTS_DIR"
fi

TARGET_DIR="/usr/local/bin"

# Only include folders with executable scripts
# Note: secrets/ is excluded as those scripts are meant to be sourced, not executed
FOLDERS=("automation" "project_management")

FILE_EXTENSIONS=("sh" "py")

install_count=0

function install_script() {
  local script="$1"
  local target_dir="$2"
  local ext="$3"

  # Make script executable
  chmod +x "$script"

  script_name=$(basename "$script")
  script_alias="${script_name%.*}"

  if [[ "$ext" == "py" ]]; then
    # Create a wrapper script for Python files
    wrapper="${target_dir}/${script_alias}"
    echo "#!/bin/bash" >"${wrapper}"
    echo "python3 \"${script}\" \"\$@\"" >>"${wrapper}"
    chmod +x "${wrapper}"
    echo -e "  ${GREEN}✓${NC} Installed: ${script_alias} (Python wrapper)"
  else
    # Create symlink for shell scripts
    ln -sf "$script" "${target_dir}/${script_alias}"
    echo -e "  ${GREEN}✓${NC} Installed: ${script_alias}"
  fi

  ((install_count++))
}

echo ""
echo "Installing scripts to ${TARGET_DIR}..."
echo ""

for folder in "${FOLDERS[@]}"; do
  if [ -d "${SCRIPTS_DIR}/${folder}" ]; then
    echo "Processing ${folder}/..."
    for ext in "${FILE_EXTENSIONS[@]}"; do
      for script in "${SCRIPTS_DIR}/${folder}"/*.${ext} 2>/dev/null; do
        if [[ -f "$script" ]]; then
          install_script "$script" "${TARGET_DIR}" "${ext}"
        fi
      done
    done
  else
    echo -e "${YELLOW}⚠${NC} Warning: ${folder}/ not found, skipping..."
  fi
done

echo ""
if [ $install_count -eq 0 ]; then
  echo -e "${YELLOW}No scripts were installed.${NC}"
  echo "Make sure you're running this from the devops-toolkit directory."
  exit 1
else
  echo -e "${GREEN}✓ Successfully installed $install_count script(s)!${NC}"
  echo ""
  echo "Installed scripts can now be run from anywhere:"
  echo "  • remote_connect"
  echo "  • auto_sync_repos"
  echo "  • create_pr"
  echo ""
  echo -e "${YELLOW}Note:${NC} Secrets management scripts are not installed globally."
  echo "They should be sourced in your shell config:"
  echo "  source ~/Projects/devops-toolkit/secrets/secrets_manager.sh"
  echo ""
  echo "See README.md for configuration instructions."
fi
