#!/usr/bin/env bash

for i in `find . -maxdepth 1 -type d`; do pushd $i; ../up.sh; popd; done
