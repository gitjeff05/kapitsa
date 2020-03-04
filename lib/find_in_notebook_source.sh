#!/bin/bash
#
# Search directory recursively and return matching cell source of
# notebook (.ipynb) files.

find_in_notebook_source() {
  local SEARCH_DIRECTORY
  local CURRENT_DIRECTORY

  # default to the current directory
  CURRENT_DIRECTORY="$PWD"
  SEARCH_DIRECTORY="${1:-$CURRENT_DIRECTORY}"

  SEARCH_STRING="$2"

  # if function is called directly, ensure the search string is supplied
  if [[ -z "$SEARCH_STRING" ]]; then
    echo "You must supply a path as the first argument and a string to search as the second. For example:"
    echo "find_in_notebook_source . \"DataFrame\""
    echo "find_in_notebook_source . \"(pandas|numpy)\""
    echo "find_in_notebook_source . \"(?=.*read_csv)(?=.*parse_dates)\""
    return 1
  fi;

  # Check if valid directory
  if [[ -d "$SEARCH_DIRECTORY" ]]; then

    # find .ipynb files and ignore checkpoints directory
    # return all paths that contain .ipynb files.

    # disable SC2016 because '$foo' is a variable passed to jq
    # not a shell variable
    # shellcheck disable=SC2016
    find "$SEARCH_DIRECTORY" -name "*.ipynb" \
      \! -path "*ipynb_checkpoints*" \
      -print0 | xargs -0 \
      jq -r --arg foo "$SEARCH_STRING" '.cells[]
        | select( .cell_type == "code" )
        | select( .source | join(" ") | test($foo, "imx") )
        | { source: .source, file: input_filename }'

  else
    echo "Directory ${SEARCH_DIRECTORY} is not valid." >&2
    return 1
  fi
}
