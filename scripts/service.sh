#!/bin/bash

# start the Go server as user 'go', discarding output. It internally uses log4j
# to log to /var/log/go-server/ and manages rotation and everything.
exec /sbin/setuser go /usr/share/go-server/server.sh > /dev/null 2>&1
