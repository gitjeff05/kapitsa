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
# find_in_notebook_tags.sh - Searches directories recursively and returns cell source of
# notebook (.ipynb) files where tags match input
# -------------------------------------------------

# Define a few colors for output
# https://misc.flogisoft.com/bash/tip_colors_and_formatting#terminals_compatibility
CL_DEF="\033[39m\033[49m"
CL_YEL="\033[33m\033[49m"

find_in_notebook_tags() {

  local SEARCH_DIRECTORY
  local SEARCH_STRING

  SEARCH_DIRECTORY="${1}"
  SEARCH_STRING="${2}"

  local code_cells_with_tags
  local num_code_cells_with_tags
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

    # all cells of cell_type 'code' and that have a tags array.
    code_cells_with_tags="$(jq -r '.cells |
      try map(
        select( (.cell_type == "code") and
                (.metadata.tags | type == "array") )
      ) | [ .[] | { source: .source, tags: .metadata.tags } ]' <"${i}")"

    # number of code cells with tags
    num_code_cells_with_tags=$(printf "%s" "$code_cells_with_tags" | jq '. | length')

    # If there was a match, print the results
    if [[ "${num_code_cells_with_tags}" -gt 0 ]]; then

      # find the match
      cells_matching_on_search=$(printf "%s" "$code_cells_with_tags" | jq -r --arg foo "$SEARCH_STRING" '. | map(select( .tags | join(" ") | test($foo, "imx") )) | [ .[] | { source, tags: .tags | join(" ") } ]')

      # number of cells found that match on search string
      num_cells_matching_search="$(printf "%s" "$cells_matching_on_search" | jq '. | length')"

      # If found matching cells, print out results.
      if [[ "$num_cells_matching_search" -gt 0 ]]; then
        echo "${i}"
        echo "Found ${CL_YEL}$num_cells_matching_search${CL_DEF} matches on ${CL_YEL}$SEARCH_STRING${CL_DEF}"
        printf "%s" "$cells_matching_on_search" | jq '.'
      fi

    fi

  done

}
