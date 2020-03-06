#!/bin/bash
#
# Search directory recursively and return cell source of
# notebook (.ipynb) files where tags match search

find_in_notebook_tags() {

  echo "This is a work in progress and not yet complete"
  exit 1

  # Get a list of all the files to iterate over
  files_list=$(find "$directory" -type f -name '*.ipynb' \! -path "*ipynb_checkpoints*" \! -path "*reddit*" -prune -print)
  echo "files"
  echo "$files_list"
  # For every notebook file found in this directory perform the search
  while IFS= read -r notebook_file; do

    # Find any cells that are code blocks and that contain the metadata attribute kapitsa
    kapitsa_cells=$( (jq -r '.cells[] | select( (.cell_type == "code") and (.metadata.tags | type == "array") ) | { tags: .metadata.tags, source }') <"$notebook_file")

    # If there was a match, print the results
    if [ ${#kapitsa_cells} -ge 1 ]; then

      # If program was run with just `kapitsa` then return everything
      if [ -z "${search_string}" ]; then
        out=$(echo "$kapitsa_cells" | jq -c '. | { source, tags: .tags | join(" ") }')
        total_len=$(echo "$out" | jq -s '. | length')
        echo -e "\nFound ${CL_YEL}$total_len${CL_DEF} tagged cells in ${CL_CYA}$notebook_file${CL_DEF}\n"
        echo "$out" | jq '.'
        break
      fi

      cells_with_key=$(echo "$kapitsa_cells" | jq --arg foo "$search_string" '. | select( .tags | join(" ") | test($foo, "ig") ) | { source, tags: .tags | join(" ") }')
      total_len=$(echo "$cells_with_key" | jq -s '. | length')
      echo -e "\nFound ${CL_YEL}$total_len${CL_DEF} tagged cells matching pattern $search_string in ${CL_CYA}$notebook_file${CL_DEF}\n"
      echo "$cells_with_key" | jq .

    fi

  done < <(echo "$files_list")
}
