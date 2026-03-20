#!/bin/bash

source lib/find_in_notebook_source.sh

PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"
  local expected_contains="$3"
  if echo "$result" | grep -q "$expected_contains"; then
    echo "PASS: $desc"
    PASS=$((PASS+1))
  else
    echo "FAIL: $desc"
    echo "  expected to find: $expected_contains"
    echo "  got: $(echo "$result" | head -3)"
    FAIL=$((FAIL+1))
  fi
}

check_absent() {
  local desc="$1"
  local result="$2"
  local should_not_contain="$3"
  if echo "$result" | grep -q "$should_not_contain"; then
    echo "FAIL: $desc (found unexpected: $should_not_contain)"
    FAIL=$((FAIL+1))
  else
    echo "PASS: $desc"
    PASS=$((PASS+1))
  fi
}

check_empty() {
  local desc="$1"
  local result="$2"
  if [[ -z "$(echo "$result" | tr -d '[:space:]')" ]]; then
    echo "PASS: $desc (no results as expected)"
    PASS=$((PASS+1))
  else
    echo "FAIL: $desc (expected no results, got output)"
    echo "  got: $(echo "$result" | head -3)"
    FAIL=$((FAIL+1))
  fi
}

echo "--- 1. Basic regex search (unchanged behavior) ---"
r=$(find_in_notebook_source examples "join")
check "basic search finds match" "$r" "Found"
check "basic search returns source" "$r" "source"

echo ""
echo "--- 2. OR regex (unchanged behavior) ---"
r=$(find_in_notebook_source examples "(join|merge)")
check "OR regex finds match" "$r" "Found"

echo ""
echo "--- 3. AND with + operator (2 terms) ---"
r=$(find_in_notebook_source examples "join+set_index")
check "AND 2 terms finds match" "$r" "Found"
check "AND result contains join" "$r" "join"
check "AND result contains set_index" "$r" "set_index"

echo ""
echo "--- 4. AND with + operator (3 terms) ---"
# This cell exists: join + set_index + dataframe (case-insensitive matches DataFrame)
r=$(find_in_notebook_source examples "join+set_index+dataframe")
check "AND 3 terms finds match" "$r" "Found"

echo ""
echo "--- 5. AND with + that should return no results ---"
r=$(find_in_notebook_source examples "join+ZZZNOMATCH")
check_empty "AND with no match returns nothing" "$r"

echo ""
echo "--- 6. --markdown flag finds markdown cells ---"
r=$(find_in_notebook_source examples "NIH" false markdown)
check "markdown search finds result" "$r" "Found"
check "result has markdown cell_type" "$r" '"cell_type": "markdown"'

echo ""
echo "--- 7. --markdown flag does NOT return code cells ---"
r=$(find_in_notebook_source examples "NIH" false markdown)
check_absent "markdown search has no code cells" "$r" '"cell_type": "code"'

echo ""
echo "--- 8. --all-cells finds both code and markdown ---"
r=$(find_in_notebook_source examples "NIH" true)
check "all-cells finds markdown" "$r" '"cell_type": "markdown"'
check "all-cells finds code" "$r" '"cell_type": "code"'

echo ""
echo "--- 9. Default (code only) does NOT return markdown cells ---"
r=$(find_in_notebook_source examples "read_csv")
check_absent "default search has no markdown cells" "$r" '"cell_type": "markdown"'

echo ""
echo "--- 10. + AND combined with --markdown ---"
r=$(find_in_notebook_source examples "NIH+data" false markdown)
check "AND + markdown finds result" "$r" "Found"
check_absent "AND + markdown has no code cells" "$r" '"cell_type": "code"'

echo ""
echo "--- 11. + AND combined with --all-cells ---"
r=$(find_in_notebook_source examples "NIH+data" true)
check "AND + all-cells finds result" "$r" "Found"

echo ""
echo "--- 12. Invalid directory error ---"
r=$(find_in_notebook_source /nonexistent "join" 2>&1)
check "invalid dir prints error" "$r" "not valid"

echo ""
echo "--- 13. Search term not present returns nothing ---"
r=$(find_in_notebook_source examples "ZZZNOMATCHATALL")
check_empty "no match returns empty" "$r"

echo ""
echo "================================"
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
