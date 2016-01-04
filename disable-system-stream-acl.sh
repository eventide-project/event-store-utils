#!/usr/bin/env bash

set -u

port=${EVENT_STORE_PORT:-2113}

echo
echo "Disabling ACL for System Streams"
echo "= = ="
echo

read -r -d '' json <<'JSON'
{
    "$userStreamAcl" : {
        "$r"  : "$all",
        "$w"  : "$all",
        "$d"  : "$all",
        "$mr" : "$all",
        "$mw" : "$all"
    },
    "$systemStreamAcl" : {
        "$r"  : "$all",
        "$w"  : "$admin",
        "$d"  : "$admin",
        "$mr" : "$admin",
        "$mw" : "$admin"
    }
}
JSON

json=$(echo $json | tr '\n' ' ')

curl -i -X POST -d "$json" http://127.0.0.1:${port}/streams/%24settings \
  -H 'Content-Type: application/json' \
  -H 'ES-EventType: settings' \
  -H "ES-EventId: $(uuidgen)" \
  -u admin:changeit
