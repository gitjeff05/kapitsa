#!/bin/bash
#
# Search directory recursively and return paths containing
# notebook files (.ipynb)

find_notebook_directories() {

  # default to the current directory
  local CURRENT_DIRECTORY="$PWD"
  local SEARCH_DIRECTORY="${1:-$CURRENT_DIRECTORY}"

  # run find if valid directory
  if [[ -d "$SEARCH_DIRECTORY" ]]; then

    dir="${SEARCH_DIRECTORY%/}"
    # find .ipynb files and ignore checkpoints directory
    # return all paths that contain .ipynb files.
    find "$dir" -name "*.ipynb" \
      \! -path "*ipynb_checkpoints*" \
        | grep -o "\(.*\)/" \
        | sort -u

  else
    echo "Directory ${SEARCH_DIRECTORY} is not valid." >&2
    return 1
  fi
}
