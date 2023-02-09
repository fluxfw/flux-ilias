#!/usr/bin/env sh

set -e

bin="`dirname "$0"`"
root="$bin/.."

update-github-metadata "$root"
