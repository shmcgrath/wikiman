#!/bin/sh

source_name='tldr'
description='Console commands cheatsheets'
path="$conf_local_share/doc/tldr-pages"

available() {

	[ -d "$path" ]

}

describe() {

	printf "%s\t%s\n" "$source_name" "$description"

}

info() {

	if available; then
		state="$(echo "$conf_sources" | grep -q "$source_name" && echo "+")"
		count="$("$conf_find" "$path" -type f | wc -l | sed 's| ||g')"
		printf '%-10s %-28s %3s %8i  %s\n' "$source_name" "$description" "$state" "$count" "$path"
	else
		state="$(echo "$conf_sources" | grep -q "$source_name" && echo "x")"
		printf '%-10s %-30s %-11s (not installed)\n' "$source_name" "$description" "$state"
	fi

}

setup() {

	results_title=''
	results_text=''

	if ! available; then
		echo "warning: tldr pages do not exist" 1>&2
		return 1
	fi

	langs="en"

	search_paths="$(
		"$conf_find" "$path" -maxdepth 1 -mindepth 1 -type d -printf '%p\n' | \
		"$conf_awk" "/$langs/"
	)"

	paths=''
	for rg_l in $(echo "$langs" | sed 's|*|.*|g; s|\|| |g'); do
		p="$(echo "$search_paths" | "$conf_awk" "/$rg_l/ {printf(\"%s \",\$0)}")"
		if [ "$?" = '0' ]; then
			paths="$paths${paths:+$newline}$p"
		else
			l="$(echo "$rg_l" | sed 's|_\.\*||g')"
			echo "warning: tldr pages for '$l' do not exist" 1>&2
		fi
	done
	paths="$(
		echo "$paths" | "$conf_sort" | uniq | tr '\n' ' '
	)"

	if [ "$(echo "$paths" | wc -w | sed 's| ||g')" = '0' ]; then
		return 1
	fi

	nf="$(echo "$path" | "$conf_awk" -F '/' "{print NF+1}")"

}

list() {

	setup || return 1

	eval "$conf_find $paths -type f -name '*.md'" 2>/dev/null | \
	"$conf_awk" -F '/' \
		"BEGIN {
			IGNORECASE=1;
			OFS=\"\t\"
		};
		{
			title = \"\";
			for (i=$nf+2; i<=NF; i++) {
				title = title ((i==$nf+2) ? \"\" : \"/\") \$i;
			}

			gsub(/\.md$/,\"\",title);
			gsub(\"_\",\" \",title);
			gsub(\"-\",\" \",title);

			title = title \" [\" \$($nf+1) \"]\"

			lang=\$$nf;
			path=\$0;

			print \"$source_name\", title, path;
		};"

}

search() {

	setup || return 1

	results_title="$(
		eval "$conf_find $paths -type f -name '*.md'" 2>/dev/null | \
		"$conf_awk" -F '/' \
			"BEGIN {
				IGNORECASE=1;
				OFS=\"\t\"
				and_op = \"$conf_and_operator\" == \"true\";
				split(\"$query\",kwds,\" \");
			};
			{
				title = \"\";
				for (i=$nf+2; i<=NF; i++) {
					title = title ((i==$nf+2) ? \"\" : \"/\") \$i;
				}

				gsub(/\.md$/,\"\",title);
				gsub(\"_\",\" \",title);
				gsub(\"-\",\" \",title);

				title = title \" [\" \$($nf+1) \"]\"

				lang=\$$nf;
				path=\$0;

				matched = title;
				accuracy = 0;

				if (and_op) {
					kwdmatches = 0;

					for (k in kwds) {
						subs = gsub(kwds[k],\"\",matched);
						if (subs>0) {
							kwdmatches++;
							accuracy = accuracy + subs;
						}
					}

					if (kwdmatches<length(kwds))
						accuracy = 0;
				} else {
					gsub(/$greedy_query/,\"\",matched);

					lm = length(matched)
					gsub(\" \",\"\",matched);
					gsub(\"_\",\"\",matched);

					if (length(matched)==0)
						accuracy = length(title)*100;
					else
						accuracy = 100-lm*100/length(title);
				}

				if (accuracy > 0) {
					printf(\"%s\t$source_name\t%s\t%s\n\",accuracy,title,path);
				}
			};" | \
		"$conf_sort" -rV -k1 | cut -d'	' -f2-
	)"

	if [ "$conf_quick_search" != 'true' ]; then

		results_text="$(
			eval "rg -U -i -c '$rg_query' $paths" | \
			"$conf_awk" -F '/' \
				"BEGIN {
					IGNORECASE=1;
					OFS=\"\t\"
				};
				{

					hits = \$NF;
					gsub(/^.*:/,\"\",hits);

					gsub(/:[0-9]+$/,\"\",\$0);

					title = \"\";
					for (i=$nf+2; i<=NF; i++) {
						title = title ((i==$nf+2) ? \"\" : \"/\") \$i;
					}

					gsub(/\.md$/,\"\",title);
					gsub(\"_\",\" \",title);
					gsub(\"-\",\" \",title);

					title = title \" [\" \$($nf+1) \"]\"

					lang=\$$nf;
					path=\$0;

					printf(\"%s\t$source_name\t%s\t%s\n\",hits,title,path);
				};" | \
			"$conf_sort" -rV -k1 | cut -d'	' -f2-
		)"

	fi

	printf '%s\n%s\n' "$results_title" "$results_text" | "$conf_awk" "!seen[\$0] && NF>0 {print} {++seen[\$0]};"

}


eval "$1"
