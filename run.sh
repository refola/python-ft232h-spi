#!/bin/bash

# Where are we?
DELINKED=`readlink -f "$0"`
HERE="`dirname "$DELINKED"`"

# Be here now.
cd $HERE

echo "Running example.py...."
sudo python3 ./example.py
