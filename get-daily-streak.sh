#!/bin/bash

GITHUB_USERNAME="$USERNAME"
GITHUB_TOKEN="$GH_PAT"

get_json_from_graphql() {
  local graphql=$1
  local graphql_variables=$2
  local formatted_graphql=$(echo "$graphql" | tr -d '\n' | sed 's/  */ /g')
  local query='{"query": "'$formatted_graphql'", "variables": '$graphql_variables'}'  
  local json=$(curl -s -H "Authorization: bearer $GITHUB_TOKEN" -X POST -d "$query" https://api.github.com/graphql)
  echo "$json"
}

years=$(bash "AfterReadme/get-contribution-years.sh")
streak=0

for year in $years; do
  from_date="${year}-01-01T00:00:00Z"
  to_date="${year}-12-31T23:59:59Z"

  get_daily_contribs_graphql='
query($username: String!, $from_date: DateTime!, $to_date: DateTime!) {
  user(login: $username) {
    contributionsCollection(from: $from_date, to: $to_date) {
      contributionCalendar{
        weeks {
          contributionDays{
            contributionCount
          }
        }
      }
    }
  }
}'

  json=$(get_json_from_graphql "$get_daily_contribs_graphql" '{"username": "'$GITHUB_USERNAME'", "from_date": "'$from_date'", "to_date": "'$to_date'"}')
  daily_contribs=$(echo "$json" | jq -r '[.data.user.contributionsCollection.contributionCalendar.weeks[].contributionDays[]]')
  reversed_daily_contribs=$(echo "$daily_contribs" | jq 'reverse')

  contrib_counts=($(echo "$reversed_daily_contribs" | grep '"contributionCount"' | sed -E 's/[^0-9]*([0-9]+).*/\1/'))


  # positive streak
  for contrib_count in "${contrib_counts[@]}"; do
    if [ "$contrib_count" -gt 0 ]; then
      streak=$((streak + 1))
    else
      break 2
    fi
  done

  # days since streak reset (negative value)
  if [ "$streak" -eq 0 ]; then
    for contrib_count in "${contrib_counts[@]}"; do
      if [ "$contrib_count" -eq 0 ]; then
        streak=$((streak - 1))
      else
        break 2
      fi
    done
  fi

  # no contribution today but streak is not reset
  if [ "$streak" -eq -1 ]; then
    streak=0
  fi
done

echo $streak