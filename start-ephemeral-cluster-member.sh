#!/usr/bin/env bash

# To start an ephemeral EventStore cluster suitable for local development, some
# configuration of your development machine is necessary. EventStore clustering
# is detected when a DNS lookup returns multiple IP addresses. See the section
# titled "Using DNS" here:
#
#     http://docs.geteventstore.com/server/3.9.0/cluster-without-manager-nodes/
#
# Ignore the section titled "Running on the Same Machine." Multiple EventStore
# cluster members can run on the same machine via loopback aliases, e.g.
# 127.0.111.1. Every address under 127.0.0.0/8 (i.e., 127.1.2.3.4) is reserved
# as a loopback address, but on most systems aliases will need to be set up
# explicitly to allow EventStore to bind to those IP addresses. On OS X, this
# can be done via the following command:
#
#     sudo ifconfig lo0 alias 127.0.111.1
#     sudo ifconfig lo0 alias 127.0.111.2
#     sudo ifconfig lo0 alias 127.0.111.3
#
# Ensure all loopback addresses are aliased, and then add corresponding entries
# to /etc/hosts:
#
#     127.0.111.1 eventstore-cluster.localhost
#     127.0.111.2 eventstore-cluster.localhost
#     127.0.111.3 eventstore-cluster.localhost
#
# With the above configuration, "eventstore-cluster.localhost" can be specified
# as the host whenever EventStore is configured within Eventide libraries.
#
# To start an ephemeral event store cluster member, the BIND_ADDRESS environment
# variable needs to be set to one of the loopback aliases:
#
#     BIND_ADDRESS=127.0.111.1 ./start-ephemeral-cluster-member.sh

set -eu

export CLUSTER_SIZE=3
export CLUSTER_DNS=${CLUSTER_DNS:=eventstore-cluster.localhost}

./start-ephemeral-event-store.sh
