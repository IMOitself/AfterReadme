#!/bin/bash

GITHUB_USERNAME=$(sed -n '1p' sensitive-info.txt)
GITHUB_TOKEN=$(sed -n '2p' sensitive-info.txt)

graphql='
query($username: String!) {
  user(login: $username) {
    contributionsCollection {
      contributionYears
    }
  }
}'

formatted_graphql=$(echo "$graphql" | tr -d '\n' | sed 's/  */ /g')

query='{"query": "'$formatted_graphql'", "variables": {"username": "'$GITHUB_USERNAME'"}}'

query_json=$(curl -s -H "Authorization: bearer $GITHUB_TOKEN" -X POST -d "$query" https://api.github.com/graphql)

echo $query_json