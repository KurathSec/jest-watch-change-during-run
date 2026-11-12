#!/bin/sh
# jest --watchAll: a file is edited while a run is under way. Is the edit in the results once the
# run has ended? The control is the same edit between two runs.
# Usage: npm install && sh run.sh
cd "$(dirname "$0")" || exit 1
b() { sed -i "s/B[0-9]/$1/g" tests/b.test.js; }
has() { if grep -q "\"title\":\"$1\"" out.json 2>/dev/null; then echo yes; else echo no; fi; }
marked() { if grep -q "$1" marks.log 2>/dev/null; then echo yes; else echo no; fi; }
wait_for() { i=0; until [ "$($1 "$2")" = yes ] || [ $i -ge "$3" ]; do sleep 1; i=$((i+1)); done; $1 "$2"; }
rm -f out.json marks.log; : > gate; b B1; printf "test('O1', () => {});\n" > tests/other.test.js
./node_modules/.bin/jest --watchAll --json --outputFile=out.json > watch.log 2>&1 &
pid=$!
first=$(wait_for has B1 90)
sleep 2
b B2                                   # control: an edit between two runs
between=$(wait_for has B2 30)
sleep 2
rm -f gate; : > marks.log
b B3                                   # this edit starts a run; the slow test now waits
ran=$(wait_for marked "b ran B3" 60)
started=$(wait_for marked "slow started" 60)
b B4                                   # the edit while that run is under way
sleep 3
: > gate                               # the slow test ends, and with it the run
sleep 15
during=$(has B4)
shown=$(sed -n 's/.*"title":"\(B[0-9]\)".*/\1/p' out.json | head -1)
printf "test('O2', () => {});\n" > tests/other.test.js   # a later edit of another file
later=$(wait_for has O2 30)
sleep 2
after=$(has B4)
kill $pid 2>/dev/null
b B1; printf "test('O1', () => {});\n" > tests/other.test.js; rm -f gate marks.log
echo "RESULT first_run=$first edit_between_runs_in_results=$between run_under_way=$ran$started edit_during_run_in_results=$during results_show=${shown:-NA} later_edit_followed=$later edit_in_results_after_later_edit=$after"
