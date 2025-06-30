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

get_contribution_years() {
  get_creation_date_graphql='
  query($username: String!) {
    user(login: $username) {
      createdAt
    }
  }'

  json=$(get_json_from_graphql "$get_creation_date_graphql" '{"username": "'$GITHUB_USERNAME'"}')
  creation_date=$(echo "$json" | jq -r '.data.user.createdAt')
  creation_year=$(echo "$creation_date" | cut -d '-' -f 1)
  current_year=$(date +'%Y')

  years=$(seq $creation_year $current_year)
  echo $years
}




years=$(get_contribution_years)
total_contribs=0

for year in $years; do
  from_date="${year}-01-01T00:00:00Z"
  to_date="${year}-12-31T23:59:59Z"

  get_contribs_graphql='
query($username: String!, $from_date: DateTime!, $to_date: DateTime!) {
  user(login: $username) {
    contributionsCollection(from: $from_date, to: $to_date) {
      contributionCalendar {
        totalContributions
      }
    }
  }
}'

  json=$(get_json_from_graphql "$get_contribs_graphql" '{"username": "'$GITHUB_USERNAME'", "from_date": "'$from_date'", "to_date": "'$to_date'"}')
  contribs=$(echo "$json" | jq -r '.data.user.contributionsCollection.contributionCalendar.totalContributions')
  total_contribs=$(($total_contribs + $contribs))
done

echo $total_contribs