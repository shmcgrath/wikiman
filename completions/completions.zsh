#compdef wikiman

_arguments -s \
		'-h[display help and exit]' \
		'-R[print raw output]' \
		'-S[list available sources and exit]' \
		'-p[disable quick result preview]' \
		'-q[enable quick search mode]' \
		'-a[enable AND operator mode]' \
		'-c[show source column]' \
		'-k[keep open after viewing a result]' \
		'-h[print version and exit]' \
		'-W[print widget code for specified shell and exit]' \
		'-s[sources to use]:source:->sources'

case $state in
	sources)
		local -a _sources
		_sources=()
		while IFS= read -r line; do
		_sources+=("$line")
		done < <(WIKIMAN_INTERNAL=1 wikiman -C sources_zsh)
		_describe 'source' _sources
		;;
esac
