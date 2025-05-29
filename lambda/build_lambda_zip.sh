#!/bin/bash

set -e

# Variables
SRC_DIR="src"
PACKAGE_DIR="package"
ZIP_FILE="lambda_function.zip"

# Cleanup previous builds
rm -rf ${PACKAGE_DIR} ${ZIP_FILE}
mkdir -p ${PACKAGE_DIR}

# Install dependencies
pip install --target ${PACKAGE_DIR} -r requirements.txt

# Copy source files
cp -r ${SRC_DIR}/* ${PACKAGE_DIR}/

# Create deployment zip
cd ${PACKAGE_DIR}
zip -r ../${ZIP_FILE} .
cd ..

echo "Lambda package built successfully: ${ZIP_FILE}"
