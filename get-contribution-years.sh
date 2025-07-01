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
}

echo $(get_contribution_years)