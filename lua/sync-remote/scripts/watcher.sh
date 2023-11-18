#!/bin/bash
remote_root=$1
echo "executing" >>~/debug.log
for path in ${@:2}; do
	full_path=${WATCHMAN_ROOT}/$path
	if [ -e "$full_path" ] && [[ "$full_path" != *".git"* ]]; then
		echo "rsync -rvzu --no-whole-file ${WATCHMAN_ROOT}/$path $remote_root/$path" >>~/debug.log
		rsync -rvzu --no-whole-file ${WATCHMAN_ROOT}/$path $remote_root/$path
	fi
done
