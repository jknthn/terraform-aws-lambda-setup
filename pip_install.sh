#!/bin/bash

set -e
set -u
set -o pipefail

echo "Installing python dependencies..."

rm -rf $temp_source_dir
mkdir -p $temp_source_dir
cp -a $source_dir/. $temp_source_dir
pip3 install -r $temp_source_dir/requirements.txt --target $temp_source_dir
