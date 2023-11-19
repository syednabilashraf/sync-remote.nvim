#!/bin/bash
remote_root=$1

sync_remote() {
	local_full_path=${WATCHMAN_ROOT}/$1
	remote_full_path=$remote_root/$1
	if [ -e "$local_full_path" ]; then
		rsync -rvzu --delete --no-whole-file $local_full_path $remote_full_path
	fi
}

for path in "${@:2}"; do
	sync_remote "$path"
done
