#!/usr/bin/env bash
set -euo pipefail

# converted from https://gitlab.archlinux.org/grawlinson/arch-wiki-lite
# for use in my personal fork of wikiman

doc_install_dir="${1:-${XDG_DATA_HOME:-$HOME/.local/share}/doc}"
WIKI_PATH="$doc_install_dir/arch-wiki/html"
DUMP_PATH="./text"

#printf "%s\n" "Downloading arch-wiki-lite"
git clone --depth 1 --single-branch --branch master https://gitlab.archlinux.org/grawlinson/arch-wiki-lite

#printf "%s\n" 'Extracting data'
#unzstd -c arch-wiki-lite.pkg.tar.zst | tar -xf - -C "$workdir"


# Create dump directory
mkdir -p "$DUMP_PATH"

# Escape replacements
declare -A escapes=(
    ["&nbsp;"]=" " ["&quot;"]='"' ["&gt;"]=">" ["&lt;"]="<"
    ["&#34;"]='"' ["&#36;"]='$' ["&#39;"]="'"
    ["&#40;"]="(" ["&#41;"]=")" ["&#60;"]="<"
    ["&#61;"]="=" ["&#x3d;"]="=" ["&#62;"]=">"
    ["&#91;"]="[" ["&#93;"]="]" ["&#123;"]="{"
    ["&#125;"]="}" ["&#124;"]="|" ["&#135;"]="‡"
    ["&#160;"]=" " ["&#163;"]="£" ["&#167;"]="§"
    ["&#176;"]="°" ["&#180;"]="´" ["&#200;"]="È"
    ["&#224;"]="à" ["&#225;"]="á" ["&#227;"]="ã"
    ["&#231;"]="ç" ["&#232;"]="è" ["&#233;"]="é"
    ["&#234;"]="ê" ["&#235;"]="ë" ["&#236;"]="ì"
    ["&#242;"]="ò" ["&#245;"]="õ" ["&#249;"]="ù"
    ["&#8592;"]="←" ["&#8593;"]="↑" ["&#8594;"]="→"
    ["&#8595;"]="↓" ["&#8657;"]="⇑" ["&#9484;"]="┌"
    ["&#9492;"]="└" ["&#9608;"]="█" ["&#10003;"]="✓"
    ["&#10007;"]="✗" ["&#x103;"]="ă" ["&#x15f;"]="ş"
    ["&#x219;"]="ș" ["&#x21b;"]="ț" ["&#226;"]="â"
    ["&#228;"]="ä" ["&#238;"]="î" ["&lsquo;"]="'"
    ["&rsquo;"]="'"
    ["&#166;"]="|" ["&#169;"]="(c)" ["&#173;"]=""
    ["&#174;"]="(r)" ["&#187;"]=">>" ["&#8211;"]="-"
    ["&#8212;"]="--" ["&#8216;"]="'"
    ["&#8217;"]="'"
    ["&#8220;"]='"' ["&#8221;"]='"' ["&#8226;"]="*"
    ["&#8230;"]="..." ["&#8482;"]="(tm)" ["&#9472;"]="-"
    ["&#9596;"]="-"
    ["&#8202;"]=" " ["&#8206;"]=""
    ["&#x1f50e;"]="" ["&#35;"]="#" ["&amp;"]='&'
)

replace_escapes() {
    local text="$1"
    for k in "${!escapes[@]}"; do
        text="${text//"$k"/${escapes[$k]}}"
    done
    echo "$text"
}

html_to_text() {
    local html="$1"

    # Extract body content
	html=$(echo "$html" | sed -n '/<body/,/<li id="footer-info-copyright">/p' | sed '$d')

    # Remove TOC
    html=$(echo "$html" | sed '/<div class="toc noprint"/,/<\/div>/d')

    # Remove jump-to-nav
    html=$(echo "$html" | sed '/<div id="jump-to-nav"/,/<\/div>/d')

    # Replace <a> tags with placeholders
    html=$(echo "$html" | sed -E 's|<a[^>]*>|@@b|g; s|</a>|@@w|g')

    # Remove remaining HTML tags
    html=$(echo "$html" | sed -E 's|<[^>]+>||g')

    # Replace escape sequences
    html=$(replace_escapes "$html")

    echo "$html"
}

# read all html files into an array safely
mapfile -d '' files < <(find "$WIKI_PATH" -type f -name '*.html' -print0)

# sort alphabetically while preserving spaces
mapfile -t sorted_files < <(printf '%s\n' "${files[@]}" | sort)


# Build TOC
declare -A toc
i=1
for file in "${sorted_files[@]}"; do
    number=$(printf "%08d" "$i")
    toc["$file"]="$number"
    toc["$number"]="$file"
    ((i++))
done

# Write index and individual text files
INDEX_FILE="$DUMP_PATH/index"
TXT_FILE="$DUMP_PATH/arch-wiki.txt"

: > "$INDEX_FILE"
: > "$TXT_FILE"

SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-$(date +%s)}

for path in "${sorted_files[@]}"; do
    [[ "$path" =~ ^[0-9]+$ ]] && continue
    [[ "$path" == */index.html ]] && continue

    number="${toc[$path]}"
    name="${path#$WIKI_PATH/}"

    html=$(<"$path")
    text=$(html_to_text "$html")
    text=$(echo "$text" | sed "s/^/$number:/")

    # write individual text file
	outfile="$DUMP_PATH/$name.txt"
    mkdir -p "$(dirname "$outfile")"
    printf "%s\n" "$text" > "$outfile"

	# write to eventual .gz TXT_FILE
    printf '%s\n' "$text" >> "$TXT_FILE"

	# write to index
    printf '%s %s\n' "$name" "$number" >> "$INDEX_FILE"
done

# gzip with reproducible timestamp
#gzip -n -f -S .gz "$TXT_FILE"

echo "Index and text files generated in $DUMP_PATH"
