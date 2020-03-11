#!/bin/bash

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

    # If the second argument is unset, then
    # assume script is called from command line:
    # (e.g., find_notebook_directories "path")
    if [[ -z "$2" ]]; then

      find "$dir" -name "*.ipynb" \
        \! -path "*ipynb_checkpoints*" |
        grep -o "\(.*\)/" |
        sort -u
      # If second argument was set, we assume
    # the parent script will do the sorting.
    # This is because it may make multiple calls if
    # user has kapitsa configured to search
    # multiple directories and sorting should then be done
    # all at once in parent script
    else
      find "$dir" -name "*.ipynb" \
        \! -path "*ipynb_checkpoints*"
    fi

  else
    echo "Directory ${SEARCH_DIRECTORY} is not valid." >&2
    return 1
  fi
}
