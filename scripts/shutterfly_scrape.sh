#!/bin/bash

#
# Prerequisite: brew install recode
#
# How to use: 
# 	1. Login to shutterfly
#	2. Browse to your list of albums
#	3. Open the inspector in Chrome
#	4. Click to see "all" albums
#	5. Copy/paste the output of the resulting XHR request
#	6. In the JS console, enter JSON.stringify(<paste the output of #5>)
#	7. Save the result to "items.json" and feed that file location into this script
#

base_img_url="https://uniim-share.shutterfly.com/procgtaserv"
json_location="${1}"
output_dir="./out"

mkdir -p "${output_dir}"

for group in $(cat "${json_location}" | jq -r '.result.section.groups[] | @base64'); do
	group_decoded=$(echo "${group}" | base64 --decode)
	created_at=$(date -r $(echo ${group_decoded} | jq -r ".created") '+%F')
	title="${created_at} -- $(echo ${group_decoded} | jq -r ".title" | recode html..ascii | sed 's,[^a-zA-Z0-9 ],,g')"

	group_dir="${output_dir}/${title}"
	echo "Creating group dir ${group_dir}..."

	mkdir -p "${group_dir}"

	for item in $(echo "${group_decoded}" | jq -r '.items[] | @base64'); do
		item_decoded=$(echo "${item}" | base64 --decode)
		title=$(echo ${item_decoded} | jq -r ".title")
		id=$(echo ${item_decoded} | jq -r ".shutterflyId")
		url="${base_img_url}/${id}"
		file_path="${group_dir}/${title}"

		echo "Fetching ${url} (${file_path})..."
		curl -s -o "${file_path}" "${url}"
	done
	
done
