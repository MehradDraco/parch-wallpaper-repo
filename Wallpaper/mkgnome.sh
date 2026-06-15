#!/bin/bash

OUTPUT="parch-wallpapers.xml"

cat > "$OUTPUT" <<EOF
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
EOF

mapfile -t files < <(find . -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.svg' \) | sort)

declare -A pairs seen

for f in "${files[@]}"; do
    base=$(basename "$f")
    dir=$(dirname "$f")
    stem="${base%.*}"
    lstem=$(echo "$stem" | tr '[:upper:]' '[:lower:]')
    if [[ $lstem =~ [ _-]?light$ ]]; then
        key_stem=$(echo "$stem" | sed -E 's/[ _-]?[Ll][Ii][Gg][Hh][Tt]$//')
        key="$dir/$key_stem"
        pairs["$key,light"]="$f"
        seen["$key"]=1
    elif [[ $lstem =~ [ _-]?dark$ ]]; then
        key_stem=$(echo "$stem" | sed -E 's/[ _-]?[Dd][Aa][Rr][Kk]$//')
        key="$dir/$key_stem"
        pairs["$key,dark"]="$f"
        seen["$key"]=1
    else
        key="$dir/$stem"
        pairs["$key,single"]="$f"
        seen["$key"]=1
    fi
done

for key in "${!seen[@]}"; do
    light="${pairs[$key,light]}"
    dark="${pairs[$key,dark]}"
    single="${pairs[$key,single]}"

    echo "  <wallpaper deleted=\"false\">" >> "$OUTPUT"

    pretty_name=$(basename "$key")
    folder_name=$(basename "$(dirname "$key")")
    echo "    <name>${folder_name} - ${pretty_name}</name>" >> "$OUTPUT"

    if [[ -n "$light" && -n "$dark" ]]; then
        echo "    <filename>/usr/share/wallpapers/${light#./}</filename>" >> "$OUTPUT"
        echo "    <filename-dark>/usr/share/wallpapers/${dark#./}</filename-dark>" >> "$OUTPUT"
    elif [[ -n "$light" ]]; then
        echo "    <filename>/usr/share/wallpapers/${light#./}</filename>" >> "$OUTPUT"
    elif [[ -n "$dark" ]]; then
        echo "    <filename>/usr/share/wallpapers/${dark#./}</filename>" >> "$OUTPUT"
    elif [[ -n "$single" ]]; then
        echo "    <filename>/usr/share/wallpapers/${single#./}</filename>" >> "$OUTPUT"
    fi

    echo "    <options>zoom</options>" >> "$OUTPUT"
    echo "    <shade_type>solid</shade_type>" >> "$OUTPUT"
    echo "    <pcolor>#000000</pcolor>" >> "$OUTPUT"
    echo "    <scolor>#000000</scolor>" >> "$OUTPUT"
    echo "  </wallpaper>" >> "$OUTPUT"
done

cat >> "$OUTPUT" <<EOF
</wallpapers>
EOF

echo "✅ XML wallpaper list generated: $OUTPUT"
