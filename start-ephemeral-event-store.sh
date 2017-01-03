#!/usr/bin/env bash

# To specify the port numbers to use, supply the desired external HTTP port via
# the HTTP_PORT environment variable. The internal HTTP, external TCP, and
# internal IP ports will be adjusted accordingly. For example:
#
#    HTTP_PORT=2213 ./start
#
# The above command will configure event store to use the following ports:
#
#    Name           Port
#    ----           ----
#    Internal TCP   1112
#    External TCP   1113
#    Internal HTTP  2112
#    External HTTP  2113

set -eu

BIND_ADDRESS=${BIND_ADDRESS:=127.0.0.1}
CLUSTER_SIZE=${CLUSTER_SIZE:=1}
HTTP_PORT=${HTTP_PORT:=2113}
EVENT_STORE_DIR=${EVENT_STORE_DIR:=event-store}

INT_TCP_PORT=$(( $HTTP_PORT - 1001 ))
EXT_TCP_PORT=$(( $HTTP_PORT - 1000 ))
INT_HTTP_PORT=$(( $HTTP_PORT - 1 ))
EXT_HTTP_PORT=$(( $HTTP_PORT - 0 ))

if [ $CLUSTER_SIZE = "1" ]; then
  COMMAND="./run-node.sh --mem-db --run-projections=System --int-ip=$BIND_ADDRESS --ext-ip=$BIND_ADDRESS --int-tcp-port=$INT_TCP_PORT --ext-tcp-port=$EXT_TCP_PORT --int-http-port=$INT_HTTP_PORT --ext-http-port=$EXT_HTTP_PORT"
else
  COMMAND="./run-node.sh --mem-db --run-projections=System --int-ip=$BIND_ADDRESS --ext-ip=$BIND_ADDRESS --int-tcp-port=$INT_TCP_PORT --ext-tcp-port=$EXT_TCP_PORT --int-http-port=$INT_HTTP_PORT --ext-http-port=$EXT_HTTP_PORT --cluster-dns=$CLUSTER_DNS --cluster-gossip-port=$INT_HTTP_PORT --cluster-size=$CLUSTER_SIZE --discover-via-dns=true"
fi

echo
echo "Starting EventStore"
echo "= = ="
echo
echo "Command: $COMMAND"
echo

if [ ! -f $EVENT_STORE_DIR/run-node.sh ]; then
  echo "You must create a symbolic link in this directory named \`$EVENT_STORE_DIR' that points to a directory where EventStore is unpacked, e.g."
  echo
  echo "  ln -s /path/to/EventStore-OSS-MacOSX-v3.9.0 $EVENT_STORE_DIR"
  echo
  exit 1
fi

pushd $EVENT_STORE_DIR
exec $COMMAND
popd
