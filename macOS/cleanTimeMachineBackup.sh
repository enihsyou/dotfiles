#!/usr/bin/env bash

function sure() {
  read -r -p "Will delete $1? [y/N] " response
  case "$response" in
      [yY][eE][sS]|[yY])
          return 0
          ;;
      *)
          return 1
          ;;
  esac
}

TM_PATH="/Volumes/Gloway/Backups.backupdb/九条涼果的MacBook Pro/"

for folder in $(exa -1 -s name "${TM_PATH}") ; do
  full_path="${TM_PATH}$folder"
  ([[ ! -d "$full_path" ]] || [[ -h "$full_path" ]] ) && continue
  if sure "$full_path"; then
    sudo tmutil delete "$full_path"
  fi
done
