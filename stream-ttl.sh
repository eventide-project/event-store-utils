#!/usr/bin/env bash

set -u

stream_name=$1
max_age=${2:-'0'}
port=${EVENT_STORE_PORT:-2113}

if [ $max_age = "0" ]; then
  echo
  echo "Disabling TTL for $stream_name"
  echo "- - -"
else
  echo
  echo "Setting TTL to $max_age for $stream_name"
  echo "- - -"
fi

metadata_uri=$(
  curl -s -H 'Accept: application/vnd.eventstore.atom+json' \
    "http://127.0.0.1:${port}/streams/$stream_name" |
  ruby -rjson -e "JSON.parse(STDIN.read)['links'].each { |e| puts e['uri'] if e['relation'] == 'metadata' }"
)

echo $metadata_uri

if [ $max_age = '0' ]; then
  read -r -d '' json <<JSON
  [
    {
      "eventId": "$(uuidgen)",
      "eventType": "\$user-updated",
      "data": {}
    }
  ]
JSON
else
  read -r -d '' json <<JSON
  [
    {
      "eventId": "$(uuidgen)",
      "eventType": "\$user-updated",
      "data": {
        "\$maxAge": $max_age
      }
    }
  ]
JSON
fi

json=$(echo $json | tr '\n' ' ')

curl -i -X POST -d "$json" $metadata_uri \
  -H 'Content-Type: application/vnd.eventstore.atom+json'
