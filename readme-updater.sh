#!/bin/bash
echo "$(pwd)"
total_contribs=$(bash "get-total-contribs.sh")
echo "$total_contribs"

daily_streak=$(bash "get-daily-streak.sh")
echo "$daily_streak"


