#!/bin/bash

source $(dirname "$0")/logging.sh

calculate_app_version() {
  local docker_repo="$1"
  local username="$2"
  local token="$3"
  local forced_version="$4"

  if [ -n "$forced_version" ]; then
    info_msg "Using forced APP_VERSION: $forced_version"
    echo "##vso[task.setvariable variable=APP_VERSION]$forced_version"
    return 0
  fi

  local tags_json
  tags_json=$(curl -s -u "$username:$token" "https://hub.docker.com/v2/repositories/$docker_repo/tags/?page_size=100")

  local latest
  latest=$(echo "$tags_json" | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)

  if [ -z "$latest" ]; then
    latest="0.0.0"
  fi

  local major minor patch
  IFS='.' read -r major minor patch <<< "$latest"
  patch=$((patch + 1))
  local new_version="$major.$minor.$patch"

  info_msg "Calculated APP_VERSION: $new_version"
  echo "##vso[task.setvariable variable=APP_VERSION]$new_version"
}
