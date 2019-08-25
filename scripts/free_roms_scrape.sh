#!/bin/bash

base_url="https://romsmode.com/roms/nintendo"
base_download_url="https://romsmode.com/download/roms/nintendo"
out_dir="./out"
max_pages=153

mkdir -p "${out_dir}"

urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

doDownload() {
    target_file="${out_dir}/${1}"
cat << EOF

#
# Saving file ${2} to ${target_file}
#
EOF
    curl -s -o "${target_file}" "${2}"
}

for x in {1..153}
do
    echo "Processing page ${x} of ${max_pages}..."
    
    list_page_url="${base_url}/${x}"

    for game_path in $(curl -s ${list_page_url} | grep -o "${base_url}/[^\"]\+-[0-9]\+")
    do
    	download_page=$(echo "${game_path}" | sed s,${base_url},${base_download_url},)
    	download_url=$(curl -s "${download_page}"| grep -o "https://s2roms.cc[^\"]\+")
    	file_name=$(urldecode $(echo "${download_url}" | grep -o "[^/]\+$"))

    	doDownload "${file_name}" "${download_url}"
    done
done