#!/usr/bin/env bash

# Source name
SOURCE="ref"

# Base path
BASE_PATH="$HOME/dotfiles/reference"

# Tools (adjust path if needed)
REALPATH="./env/bin/realpath"

# List all files recursively, treat each as a page
list_pages() {
	find "$BASE_PATH" -type f \( -name '*.md' -o -name '*.txt' -o -name '*.html' \)
}

# Page ID is just the relative path from BASE_PATH
page_id() {
	"$REALPATH" --relative-to="$BASE_PATH" "$1"
}

# Title is first heading in Markdown or first line in plain text
page_title() {
	head -n 1 "$1" | sed 's/^#* *//'
}

# Return contents for search indexing
page_content() {
	cat "$1"
}

# Optional preview (strip Markdown if needed)
page_preview() {
	head -n 20 "$1"
}
