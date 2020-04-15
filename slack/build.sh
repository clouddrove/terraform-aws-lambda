#!/bin/bash
export WRKDIR=$(pwd)
export LYR_PDS_DIR="slack"

#Init Packages Directory
mkdir -p packages/

# Building Python-pandas layer
cd ${WRKDIR}/${LYR_PDS_DIR}/
${WRKDIR}/${LYR_PDS_DIR}/build_layer.sh
zip -r ${WRKDIR}/packages/Python3-slack.zip .
rm -rf ${WRKDIR}/${LYR_PDS_DIR}/python/