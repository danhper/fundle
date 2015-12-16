#!/bin/sh

tmp_dir=$(mktemp -d /tmp/fundle.XXX)
git clone https://github.com/fisherman/fishtape.git $tmp_dir
cd $tmp_dir
make install
rm -rf $tmp_dir
