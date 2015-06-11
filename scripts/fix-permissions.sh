#!/bin/bash

# this script sets ownership of the configuration, library, and log directories
# to the go user so that it is readable and modifiable by the Go server.
chown -R go:go /etc/go /etc/default/go-server /var/lib/go-server /var/log/go-server/
