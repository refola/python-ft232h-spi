#/bin/bash
# setup3.sh
# Automate the openSUSE, Python3 installation of Adafruit_Python_GPIO....

# Where are we?
DELINKED=`readlink -f "$0"`
HERE="`dirname "$DELINKED"`"

# Finally....
echo "Installing Adafruit_Python_GPIO, updated to Python3."
cd "$HERE/Adafruit_Python_GPIO"
sudo python3 ./setup.py install

echo "Please run run.sh to run the test program."

