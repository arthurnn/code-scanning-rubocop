#!/bin/sh

set -x

cd $GITHUB_WORKSPACE

rubocop --require code_scanning --format CodeScanning::SarifFormatter
exit 0
