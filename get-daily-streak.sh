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

