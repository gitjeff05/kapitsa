#!/bin/bash

#  Copyright 2020-present Jeff Laiosa
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# -------------------------------------------------
# find_in_notebook_source.sh - Searches directory recursively and returns
# cells where source matches input.
# -------------------------------------------------

# Define a few colors for output
# https://misc.flogisoft.com/bash/tip_colors_and_formatting#terminals_compatibility
CL_DEF="\033[39m\033[49m"
CL_YEL="\033[33m\033[49m"

find_in_notebook_source() {
  local SEARCH_DIRECTORY
  local CURRENT_DIRECTORY

  # default to the current directory
  CURRENT_DIRECTORY="$PWD"
  SEARCH_DIRECTORY="${1:-$CURRENT_DIRECTORY}"

  SEARCH_STRING="$2"
  ALL_CELLS="${3:-false}"
  # cell_type_filter: "code" (default), "markdown", or "" (all cells)
  CELL_TYPE_FILTER="${4:-code}"

  # if --all-cells was set, override the filter
  if [[ "$ALL_CELLS" == "true" ]]; then
    CELL_TYPE_FILTER=""
  fi

  # if function is called directly, ensure the search string is supplied
  if [[ -z "$SEARCH_STRING" ]]; then
    echo "You must supply a path as the first argument and a string to search as the second. For example:"
    echo "find_in_notebook_source . \"DataFrame\""
    echo "find_in_notebook_source . \"(pandas|numpy)\""
    echo "find_in_notebook_source . \"pandas+numpy\"    # AND: cells containing both terms"
    echo "find_in_notebook_source . \"read_csv+parse_dates\""
    return 1
  fi

  # Convert "term1+term2+term3" AND syntax into PCRE lookaheads
  # e.g. "pandas+numpy" -> "(?=.*pandas)(?=.*numpy)"
  local JQ_PATTERN
  if [[ "$SEARCH_STRING" == *"+"* ]]; then
    JQ_PATTERN=""
    IFS='+' read -ra terms <<< "$SEARCH_STRING"
    for term in "${terms[@]}"; do
      JQ_PATTERN="${JQ_PATTERN}(?=.*${term})"
    done
  else
    JQ_PATTERN="$SEARCH_STRING"
  fi

  # Check if valid directory
  if [[ -d "$SEARCH_DIRECTORY" ]]; then

    local cells_matching_on_search
    local num_cells_matching_search

    # Get a list of all the files to iterate over
    local array
    array=()

    # Build an array of files to search.
    while IFS= read -r -d $'\0'; do
      array+=("$REPLY")
    done < <(find "$SEARCH_DIRECTORY" -name '*.ipynb' \! -path "*ipynb_checkpoints*" -prune -print0)

    # iterate over array of files
    for i in "${array[@]}"; do

      # Build the jq cell-type filter clause.
      # ""  -> all cell types
      # "code" or "markdown" -> restrict to that type only
      if [[ -z "$CELL_TYPE_FILTER" ]]; then
        cells_matching_on_search="$(jq -r --arg foo "$JQ_PATTERN" '.cells
          | map(
            select( .source | join(" ") | gsub("\n";" ") | test($foo, "imx") )
          ) | [ .[] | { cell_type: .cell_type, source: .source } ]' <"$i")"
      else
        cells_matching_on_search="$(jq -r --arg foo "$JQ_PATTERN" --arg ctype "$CELL_TYPE_FILTER" '.cells
          | map(
            select( (.cell_type == $ctype) and
                    ( .source | join(" ") | gsub("\n";" ") | test($foo, "imx") ) )
          ) | [ .[] | { cell_type: .cell_type, source: .source } ]' <"$i")"
      fi

      # number of cells matching
      num_cells_matching_search="$(printf "%s" "$cells_matching_on_search" | jq '. | length')"

      # if found cells, print them out along with filename.
      if [[ "$num_cells_matching_search" -gt 0 ]]; then
        echo -e "Found ${CL_YEL}$num_cells_matching_search${CL_DEF} matching cells in ${CL_YEL}$i${CL_DEF}"
        printf "%s" "$cells_matching_on_search" | jq .
      fi

    done

  else
    echo "Directory ${SEARCH_DIRECTORY} is not valid." >&2
    return 1
  fi
}
