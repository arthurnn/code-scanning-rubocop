#!/bin/sh

set -x

cd $GITHUB_WORKSPACE

rubocop --require code_scanning --format CodeScanning::SarifFormatter -o rubocop.sarif

if [ ! -f rubocop.sarif ]; then
    exit 1
else
    exit 0
fi
