#!/bin/bash

if [ -z "$REPOS_DIR" ]; then
  echo "Please set the REPOS_DIR environment variable to the path of your local GitHub repositories."
  exit 1
fi

cd "$REPOS_DIR"

select_option() {
  PS3="Choose an option: "
  options=("Update all repositories" "Select repositories to update" "Quit")
  select opt in "${options[@]}"; do
    case $REPLY in
      1) update_all; break ;;
      2) select_repos; break ;;
      3) exit 0 ;;
      *) echo "Invalid option";;
    esac
  done
}

update_all() {
  for repo in *; do
    if [ -d "$repo" ]; then
      sync_repo "$repo"
    fi
  done
}

select_repos() {
  for repo in *; do
    if [ -d "$repo" ]; then
      read -p "Sync $repo? (y/n): " answer
      if [ "$answer" = "y" ]; then
        sync_repo "$repo"
      fi
    fi
  done
}

sync_repo() {
  local repo="$1"
  echo "Syncing $repo..."
  cd "$repo"
  git fetch --all
  git merge --ff-only @{u}
  cd ..
}

select_option

echo "Repositories have been synced."

