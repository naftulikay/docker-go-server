#!/bin/bash

# install-default-lib
#
# Upon start up of the Docker container, if /var/lib/go-server is mounted as a volume,
# on first boot it will likely be empty. This is bad, because Go expects certain files
# to live in here. This script creates files and directories in /var/lib/go-server if
# they are missing from a backup taken at image creation time.

backup_dir="/usr/share/go-server/default/lib"
target_dir="/var/lib/go-server"

find $backup_dir -mindepth 1 | while read found ; do
    trimmed_name="$(echo "$found" | sed "s:^$backup_dir/::g")"

    # if it's a directory, make it in /etc/go if need be
    if [ -d "$found" ]; then
        test -d "$target_dir/$trimmed_name" || mkdir -p "$target_dir/$trimmed_name"
    fi

    # if it's a file, make it in /etc/go if need be
    if [ -f "$found" ]; then
        test -f "$target_dir/$trimmed_name" || cp "$found" "$target_dir/$trimmed_name"
    fi
done
