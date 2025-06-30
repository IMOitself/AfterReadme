#!/bin/bash
echo "$(pwd)"
total_contribs=$(bash "get-total-contribs.sh")
echo "$total_contribs"

daily_streak=$(bash "get-daily-streak.sh")
echo "$daily_streak"

test="
## GitHub Stats

❤️ contribs: 0
🔥 streak: 0
"

echo "$test"

test=$(echo "$test" | sed -E 's/.*❤️([^:]+): .*/❤️\1: '$total_contribs'/g')
test=$(echo "$test" | sed -E 's/.*🔥([^:]+): .*/🔥\1: '$daily_streak'/g')

echo "$test"