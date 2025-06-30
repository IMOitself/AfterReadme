#!/bin/bash
echo "$(pwd)"
total_contribs=$(bash "AfterReadme/get-total-contribs.sh")
echo "$total_contribs"

daily_streak=$(bash "AfterReadme/get-daily-streak.sh")
echo "$daily_streak"

readme=$(cat README.md)

readme=$(echo "$readme" | sed -E 's/.*❤️([^:]+): .*/❤️\1: '$total_contribs'/g')

if [ "$daily_streak" -gt 0 ]; then 
    readme=$(echo "$readme" | sed -E "s/([🔥💀])([^:]+): .*/🔥\2: ${daily_streak} days/g")
elif [ "$daily_streak" -eq 0 ]; then
    readme=$(echo "$readme" | sed -E "s/([🔥💀])([^:]+): .*/🔥\2: ${daily_streak} days<sup>\`update now\`<\/sup>/g")
else
    readme=$(echo "$readme" | sed -E "s/([🔥💀])([^:]+): .*/💀\2: ${daily_streak} days <sup>\`dead\`<\/sup>/g")
fi

echo "$readme" > README.md

test=$(bash "AfterReadme/test.sh")
echo "$test"