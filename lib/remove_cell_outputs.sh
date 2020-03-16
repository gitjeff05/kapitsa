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
# remove_cell_outputs.sh - Remove cell output from a file
# This is intended to clear out clutter that makes file
# sizes larger and makes diffing more complex.
# -------------------------------------------------

# Define a few colors for output
# https://misc.flogisoft.com/bash/tip_colors_and_formatting#terminals_compatibility
CL_DEF="\033[39m\033[49m"
CL_YEL="\033[33m\033[49m"
CL_RED="\033[31m"

remove_cell_outputs() {
  local FILE
  local BASE
  local DIR
  local TMP_FILE
  local output
  FILE="${1}"

  BASE=${FILE##*/}   #=> "foo.cpp" (basepath)
  DIR=${FILE%$BASE}  #=> "/path/to/" (dirpath)
  TMP_FILE="${DIR}_tmp_${BASE}"

  # Make sure the user passed in a valid file.
  if [[ ! -f "$FILE" ]]; then
    echo "You must pass a file"
    return 1
  fi

  # Request confirmation of file overwrite.
  # echo -e
  # local response
  # read -r "response?Continue? [y/N] "
  # echo ""
  echo -e "This command will attempt to remove the ${CL_YEL}outputs${CL_DEF} and ${CL_YEL}execution_count${CL_DEF} from all notebook cells. ${CL_RED}Make sure you backup your work before proceeding${CL_DEF}."
  echo -n "Proceed? [y\N]"
  read -r response


  # If user confirms, continue
  if [[ $response =~ ^[Yy]$ ]]; then
    # Set output to new .ipynb file with outputs removed from cells
    # Next lines explained
    # 1. Use identity operator to get entire object. Use addition operator to "merge" object on right into object on left.
    # 2. Use pipe to pass output to map function -- which iterates over each cell.
    #    Also use identity/addition pattern to merge new object into old one.
    # 3. If cell type is code, use new object with empty outputs and null execution count
    # 4. Use $FILE as input
    output="$(jq -r --indent 1 '. + { "cells": .cells
      | map(. +
        (if .cell_type == "code" then { "outputs": [], "execution_count": null } else {} end)
      ) }' "${FILE}")"
    # Write output to tmp file
    printf "%s" "${output}" > "${TMP_FILE}"
    # Copy over original file
    # This is why we ask for confirmation!
    cp "${TMP_FILE}" "${FILE}"
    # Remove tmp file.
    rm "${TMP_FILE}"
  fi

}
