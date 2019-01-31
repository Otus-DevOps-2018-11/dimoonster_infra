#!/bin/sh
set -e

if [ ! -f ./variables.json ]; then
    echo "No varables file (variables.json)"
    exit 1
fi

PACKER=/usr/local/sbin/packer

${PACKER} validate -var-file=variables.json app.json
${PACKER} validate -var-file=variables.json db.json

${PACKER} build -var-file=variables.json app.json
${PACKER} build -var-file=variables.json db.json
