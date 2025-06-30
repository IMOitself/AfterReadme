#!/bin/bash
echo "$(pwd)"
total_contribs=$(bash "get-total-contribs.sh")
echo "$total_contribs"

daily_streak=$(bash "get-daily-streak.sh")
echo "$daily_streak"

readme=$(cat README.md)

readme=$(echo "$readme" | sed -E 's/.*❤️([^:]+): .*/❤️\1: '$total_contribs'/g')
readme=$(echo "$readme" | sed -E 's/.*🔥([^:]+): .*/🔥\1: '$daily_streak'/g')

echo "$readme" > README.md