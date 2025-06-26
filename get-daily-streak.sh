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





get_daily_contribs_graphql='
query($username: String!) {
  user(login: $username) {
    contributionsCollection {
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

json=$(get_json_from_graphql "$get_daily_contribs_graphql" '{"username": "'$GITHUB_USERNAME'"}')
daily_contribs=$(echo "$json" | jq -r '[.data.user.contributionsCollection.contributionCalendar.weeks[].contributionDays[]]')

echo "$daily_contribs" | jq