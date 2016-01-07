#!/usr/bin/env bash

category=$1

if [ -z $category ]; then
  echo "Usage: $0 CATEGORY MAXAGE"
  echo "    CATEGORY - Category stream name, e.g. 'someStream' for \$ce-someStream"
  echo "    MAXAGE   - The desired TTL in seconds, or 0 if no TTL is DESIRED"
  echo
  echo "For example, to set the TTL for all streams in \$ce-someCategory to one hour:"
  echo
  echo "    $0 someCategory 3600"
  echo
  echo "To disable TTL for \$ce-someCategory, use a MAXAGE of 0, e.g."
  echo
  echo "    $0 someCategory 0"
  echo
  exit 1
fi

set -u

shift

max_age=${1:-'0'}
port=${EVENT_STORE_PORT:-2113}

streams=$(
  curl -s -H 'Accept: application/vnd.eventstore.atom+json' \
    "http://127.0.0.1:${port}/streams/%24streams" |
  ruby -rjson -e "JSON.parse(STDIN.read)['entries'].each { |e| puts e['title'] }" |
  grep "0@$category" |
  sed 's/^0@//'
)

for stream in $streams; do
  ./stream-ttl.sh $stream $max_age
done
