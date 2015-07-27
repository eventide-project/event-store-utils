#!/usr/bin/env bash

projections=(
  "by_category"
  "by_event_type"
  "stream_by_category"
  "streams"
  "users"
)

echo
echo "Enabling Projections"
echo "= = ="
echo

for name in "${projections[@]}"; do
  ./enable-projection.sh $name
done

echo "= = ="
echo "done"
echo
