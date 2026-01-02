#!/bin/sh

name='arch-lite'
description='ArchWiki.txt'
path="$conf_local_share/doc/arch-wiki/text"

available() {

	[ -d "$path" ]

}

describe() {

	printf "%s\t%s\n" "$name" "$description"

}

info() {

	if available; then
		state="$(echo "$conf_sources" | grep -q "$name" && echo "+")"
		count="$("$conf_find" "$path" -type f | wc -l | sed 's| ||g')"
		printf '%-10s %-28s %3s %8i  %s\n' "$name" "$description" "$state" "$count" "$path"
	else
		state="$(echo "$conf_sources" | grep -q "$name" && echo "x")"
		printf '%-10s %-30s %-11s (not installed)\n' "$name" "$description" "$state"
	fi

}
