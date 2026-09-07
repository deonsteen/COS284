#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/.."

make all >/dev/null

pass=0
fail=0

for i in 1 2 3 4 5; do
    task="task$i"
    input="tests/${task}_input.txt"
    expected="tests/${task}_expected.txt"
    actual="$(mktemp)"

    ./"$task" < "$input" > "$actual"

    if cmp -s "$actual" "$expected"; then
        echo "PASS: $task"
        pass=$((pass + 1))
    else
        echo "FAIL: $task"
        diff "$expected" "$actual"
        fail=$((fail + 1))
    fi

    rm -f "$actual"
done

echo "$pass passed, $fail failed"
exit "$fail"
