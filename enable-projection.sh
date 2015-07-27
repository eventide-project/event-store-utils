#!/usr/bin/env bash

set -u

name="$1"

echo
echo "Enabling $name"
echo "- - -"

if [[ ! "$name" == "users" ]]; then
  name="%24$name"
  curl -i -X POST -d '' http://127.0.0.1:2113/projection/${name}/command/enable -u admin:changeit
else
  echo "$name is enabled by default. Skipping."
fi

echo
echo
