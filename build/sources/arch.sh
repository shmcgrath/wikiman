#!/usr/bin/env bash

doc_install_dir="${1:-${XDG_DATA_HOME:-$HOME/.local/share}/doc}"
install_dir="$doc_install_dir/arch-wiki/html"
mkdir -p "$install_dir"

workdir="$(mktemp -d)"

cleanup() {
	rm -rf "$workdir"
}
trap cleanup EXIT

printf "%s\n" "Downloading arch-wiki-docs"
curl -L "https://archlinux.org/packages/extra/any/arch-wiki-docs/download/" \
	-o arch-wiki-docs.pkg.tar.zst

printf "%s\n" 'Extracting data'
unzstd -c arch-wiki-docs.pkg.tar.zst | tar -xf - \
	--strip-components=5 \
	-C "$workdir" \
	usr/share/doc/arch-wiki/html/en \
	usr/share/doc/arch-wiki/html/ArchWikiOffline.css

printf "%s\n" 'Testing arch-wiki contents'
pagecount="$(find "$workdir" -type f -name '*.html' | wc -l | tr -d '[:space:]')"
if [ "$pagecount" -lt 2400 ]; then
	printf "%s\n" "Error: page count is too low arch-wiki/en contains ${pagecount} html pages"
	exit 1
else
	printf "%s\n" "arch-wiki/en contains ${pagecount} HTML pages"
fi

mkdir -p "$install_dir/en"
rsync -a "$workdir/en/" "$install_dir/en/"
cp -f "$workdir/ArchWikiOffline.css" "$install_dir/ArchWikiOffline.css"

printf "%s\n" 'Done arch-wiki-docs'
