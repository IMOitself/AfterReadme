#!/bin/bash

GITHUB_USERNAME=$(sed -n '1p' sensitive-info.txt)
GITHUB_TOKEN=$(sed -n '2p' sensitive-info.txt)

get_json_from_graphql() {
  local graphql=$1

  local formatted_graphql=$(echo "$graphql" | tr -d '\n' | sed 's/  */ /g')

  local query='{"query": "'$formatted_graphql'", "variables": {"username": "'$GITHUB_USERNAME'"}}'

  local json=$(curl -s -H "Authorization: bearer $GITHUB_TOKEN" -X POST -d "$query" https://api.github.com/graphql)

  echo "$json"
}

get_years_graphql='
query($username: String!) {
  user(login: $username) {
    contributionsCollection {
      contributionYears
    }
  }
}'

json=$(get_json_from_graphql "$get_years_graphql")

years=$(echo "$json" | jq -r '.data.user.contributionsCollection.contributionYears[]')

for year in $years; do
  echo $year
done