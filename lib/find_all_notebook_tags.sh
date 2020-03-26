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
# find_all_notebook_tags.sh - Find all tags used.
# -------------------------------------------------
find_all_notebook_tags() {

  local SEARCH_DIRECTORY

  SEARCH_DIRECTORY="${1}"

  local code_cells_with_tags

  # Get a list of all the files to iterate over
  local array
  array=()

  local tag_collection='[]'

  # Build an array of files to search.
  while IFS= read -r -d $'\0'; do
    array+=("$REPLY")
  done < <(find "$SEARCH_DIRECTORY" -name '*.ipynb' \! -path "*ipynb_checkpoints*" -prune -print0)

  # iterate over array of files
  for i in "${array[@]}"; do

    # all cells of cell_type 'code' and that have a tags array.
    code_cells_with_tags="$(jq -r '.cells |
      map(
        select( (.cell_type == "code") and
                (.metadata.tags | type == "array") )
      ) | [ .[] | .metadata.tags ] | flatten' <"${i}")"

    # append array to entire tag collection
    tag_collection="$(echo "${tag_collection}" | jq -r --argjson foo "$code_cells_with_tags" '. + $foo')"

  done

  # return flattened array.
  echo "$tag_collection"
}
