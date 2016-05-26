#!/bin/bash

# Run in gms folder
# Replaces id => <UUID> to uuid => <UUID> to comply wiht new id standards.
# Also adds a numeric id.

# Thanks to mst

perl -pi -E 's/^(\s+)id\s+=>/${1}uuid =>/ and say "${1}id => ".++$i.","' t/etc/pending_changes/*/*.fix
