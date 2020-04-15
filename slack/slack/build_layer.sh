#!/bin/bash
export PKG_DIR="python"
rm -rf ${PKG_DIR} && mkdir -p ${PKG_DIR} && docker run -rm -v $(pwd):/foo lambci/lambda:build-python3.8
pip install -r requirements.txt --no-deps -t ${PKG_DIR}