#!/bin/bash

set -e
set -u
set -o pipefail

echo "Installing python dependencies..."

rm -rf $temp_source_dir
mkdir -p $temp_source_dir
cp -a $source_dir/. $temp_source_dir

if test -f $temp_source_dir/requirements.txt; then
  pip3 install -r $temp_source_dir/requirements.txt --target $temp_source_dir
fi

if test -f $temp_source_dir/requirements.nodeps.txt; then
  pip3 install --no-deps -r $temp_source_dir/requirements.nodeps.txt --target $temp_source_dir
fi
