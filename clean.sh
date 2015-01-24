#/bin/bash
# clean.sh
# Clean downloaded stuff from this directory (doesn't uninstall Python modules).

# Where are we?
DELINKED=`readlink -f "$0"`
HERE="`dirname "$DELINKED"`"

# Be here now.
cd $HERE

echo "Removing generated files."
sudo rm -rf Adafruit_Python_GPIO libftdi1-1.1 libftdi1-1.1.tar.bz2
