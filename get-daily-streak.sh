#!/bin/bash

GITHUB_USERNAME=$(sed -n '1p' sensitive-info.txt)
GITHUB_TOKEN=$(sed -n '2p' sensitive-info.txt)

get_json_from_graphql() {
  local graphql=$1
  local graphql_variables=$2
  local formatted_graphql=$(echo "$graphql" | tr -d '\n' | sed 's/  */ /g')
  local query='{"query": "'$formatted_graphql'", "variables": '$graphql_variables'}'
  local json=$(curl -s -H "Authorization: bearer $GITHUB_TOKEN" -X POST -d "$query" https://api.github.com/graphql)
  echo "$json"
}

get_contribution_dates() {
  get_creation_date_graphql='
  query($username: String!) {
    user(login: $username) {
      createdAt
    }
  }'

  json=$(get_json_from_graphql "$get_creation_date_graphql" '{"username": "'$GITHUB_USERNAME'"}')
  creation_date=$(echo "$json" | jq -r '.data.user.createdAt')
  current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  echo "$creation_date" 
  echo "$current_date"
}


dates=$(get_contribution_dates)

from_date=$(echo $dates | cut -d ' ' -f 1)
curr_date=$(echo $dates | cut -d ' ' -f 2)

get_daily_contribs_graphql='
query($username: String!, $from_date: DateTime!, $to_date: DateTime!) {
  user(login: $username) {
    contributionsCollection(from: $from_date, to: $to_date) {
      contributionCalendar{
        weeks {
          contributionDays{
            contributionCount
            date
          }
        }
      }
    }
  }
}'

json=$(get_json_from_graphql "$get_daily_contribs_graphql" '{"username": "'$GITHUB_USERNAME'", "from_date": "'$from_date'", "to_date": "'$curr_date'"}')
daily_contribs=$(echo "$json" | jq -r '[.data.user.contributionsCollection.contributionCalendar.weeks[].contributionDays[]]')
reversed_daily_contribs=$(echo "$daily_contribs" | jq 'reverse')

echo "$reversed_daily_contribs" > daily_contribs.json

streak=$(jq 'reduce .[] as $item ({streak: 0, done: false};
  if .done or ($item.contributionCount == 0) then
    .done = true
  else
    .streak += 1
  end
) | .streak' daily_contribs.json)

echo $streak
rm daily_contribs.json