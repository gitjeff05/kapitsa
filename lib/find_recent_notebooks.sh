#!/bin/bash
#
# Search directory recursively and return paths containing
# notebook files (.ipynb)

find_recent_notebooks() {

  # default to the current directory
  local CURRENT_DIRECTORY="$PWD"
  local SEARCH_DIRECTORY="${1:-$CURRENT_DIRECTORY}"

  declare -a flags
  flags=(-f "%Sm %N" -t "%FT%T %a, %d %b %Y %T %z")

  # run find if valid directory
  if [[ -d "$SEARCH_DIRECTORY" ]]; then

    # remove trailing slash
    dir="${SEARCH_DIRECTORY%/}"

    # Both statements below recursively find .ipynb files
    # and ignore checkpoints directory. They are different
    # depending on whether the script was called from the
    # command line or another script.

    # If the second argument is unset, then
    # assume script is called from command line:
    # (e.g., find_recent_notebooks "path")
    if [[ -z "$2" ]]; then
      find "${dir}" -name "*.ipynb" \
        \! -path "*ipynb_checkpoints*" -mtime -60d \
        -print0 | xargs -0 stat "${flags[@]}" |
        sort -k1,19 -r |
        cut -c 21-
    # If second argument was set, we assume
    # the parent script will do the sorting.
    # This is because it may make multiple calls if
    # user has kapitsa configured to search
    # multiple directories and sorting should then be done
    # all at once in parent script
    else
      find "${dir}" -name "*.ipynb" \
        \! -path "*ipynb_checkpoints*" -mtime -60d \
        -print0 | xargs -0 stat "${flags[@]}"
    fi

  else
    echo "Directory ${SEARCH_DIRECTORY} is not valid." >&2
    return 1
  fi
}
