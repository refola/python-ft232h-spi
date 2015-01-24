#/bin/bash
# setup3.sh
# Automate the openSUSE, Python3 installation of Adafruit_Python_GPIO....

# Where are we?
DELINKED=`readlink -f "$0"`
HERE="`dirname "$DELINKED"`"

# Finally....
cd "$HERE/Adafruit_Python_GPIO"
sudo python3 ./setup.py install

