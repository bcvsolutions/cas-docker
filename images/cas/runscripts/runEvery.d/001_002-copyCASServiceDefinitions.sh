#!/bin/bash
echo "[$0] Copying default CAS service definitions...";

if [ ! -z "${DOCKER_SKIP_CONFIGURATION+x}" ]; then
  echo "[$0] The DOCKER_SKIP_CONFIGURATION is defined, skipping this script.";
  exit;
fi

cd "$CAS_SERVICES_REGISTRY_JSON_LOCATION"

cp "/casstart/idm-200.json" idm-200.json;
if [ -z "${CAS_IDM_LOCATION}" ]; then
  echo "[$0] CAS_IDM_LOCATION not set, using default from the template.";
else
  sed -i "s#placeholderLogoutUrl#$CAS_IDM_LOCATION#" idm-200.json;
fi

cp "/casstart/casmngt-201.json" casmngt-201.json;
