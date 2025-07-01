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

total_daily_contribs=0

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
  total_daily_contribs=$(($total_daily_contribs + $daily_contribs))
done

echo $total_daily_contribs