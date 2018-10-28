#!/bin/bash

image_size='5120x2880'
max_pages=531
paged_url_base="http://wallpaperswide.com/${image_size}-wallpapers-r/page"
image_url_base="http://wallpaperswide.com/download"
out_dir="./out"

mkdir -p "${out_dir}"

doDownload() {
    target_file="${out_dir}/${1}.jpg"
cat << EOF

#
# Saving image ${2} to ${target_file}
#
EOF
    curl -o "${target_file}" "${2}"
}

for page_num in $(seq 1 ${max_pages}); do
    paged_contents=$(curl "${paged_url_base}/${page_num}")
    wallpaper_pages=$(echo "${paged_contents}" | grep -o 'prevframe_show(.*)' | grep -o 'http.*\.html')
    
    for page_url in $wallpaper_pages; do
        image_name=$(echo "${page_url}" | sed 's/.html$//' | grep -o '[^/]*$')
        image_url="${image_url_base}/${image_name}-wallpaper-${image_size}.jpg"
        doDownload "${image_name}" "${image_url}"
    done
done