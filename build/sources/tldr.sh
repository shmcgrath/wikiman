#!/usr/bin/env bash

#printf "%s\n" 'Installing tools'
#pacman -Sy --noconfirm curl git

doc_install_dir="${1:-${XDG_DATA_HOME:-$HOME/.local/share}/doc}"

install_dir="$doc_install_dir/tldr-pages"
mkdir -p "$install_dir"

tmp_dir="$(mktemp -d)"
cd "$tmp_dir" || exit 1
dir="$(pwd)"

printf "%s\n" "Downloading TLDR Pages"
git clone --depth 1 --single-branch --branch main https://github.com/tldr-pages/tldr ./doc

printf "%s\n" "Restructuring: keeping only en pages"
find "$dir/doc" -maxdepth 1 -mindepth 1 -not -name 'pages' -exec rm -rf {} \;
rm -rf "$dir/doc/pages.hbs"
mv "$dir/doc/pages" "$dir/doc/pages.en"

printf "%s\n" "Moving tldr pages.en to install directory"
mkdir -p "$install_dir/pages.en"
rsync -a "$dir/doc/pages.en/" "$install_dir/pages.en/"

printf "%s\n" "Counting Markdown pages"
pagecount="$(find "$install_dir" -type f -name '*.md' | wc -l | tr -d '[:space:]')"
if [ "$pagecount" -lt 6500 ]; then
	printf "%s\n" "Error: page count is too low tldr-pages/pages.en contains ${pagecount} markdown pages"
	exit 1
else
	printf "%s\n" "tldr-pages/pages.en contains ${pagecount} markdown pages"
fi

# cleanup and delete temporary directory
cleanup() {
    rm -rf "$tmp_dir"
}
trap cleanup EXIT


printf "%s\n" "Done installing tldr"
