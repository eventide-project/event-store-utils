#!/usr/bin/env bash

set -u

name="$1"

port=${EVENT_STORE_PORT:-2113}
host=${EVENT_STORE_HOST:-localhost}

echo
echo "Enabling $name (Host: $host, Port: $port)"
echo "- - -"

if [[ ! "$name" == "users" ]]; then
  name="%24$name"
  curl -v -i -X POST -d '' http://${host}:${port}/projection/${name}/command/enable -u admin:changeit
else
  echo "$name is enabled by default. Skipping."
fi

echo
echo
