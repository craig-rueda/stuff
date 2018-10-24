#!/bin/bash

set -eo pipefail

doApply() {
	file_name="secret-${1}.yaml"
	secret_name=$(yq r "${file_name}" 'metadata.name')
	kubectx ${1}

cat << EOF


#
# Current config file:
#
EOF
	kubectl get secrets -n management "${secret_name}" -o json | jq -r '.data.".dockerconfigjson"' | base64 -D

cat << EOF


#
# Changing to:
#
EOF
	yq r "${file_name}" 'data.".dockerconfigjson"' | base64 -D

	echo
	echo
	read -p "Apply [Y/N] " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo
		echo "applying to environment ${1}..."
	    kubectl apply -n management -f "${file_name}"
    else
    	exit 1
	fi

}

#doApply engops-stg
#doApply engops-prod
#doApply integration
#doApply staging
#doApply production


