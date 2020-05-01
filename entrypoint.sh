#!/bin/sh

set -x

cd $GITHUB_WORKSPACE

gem list
rubocop --require code_scanning --format CodeScanning::SarifFormatter -o rubocop.sarif
exit 0
