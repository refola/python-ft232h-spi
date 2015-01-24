#/bin/bash
# setup2.sh
# Automate the openSUSE, Python3 installation of Adafruit_Python_GPIO....

# Now we can do some scripted stuff....
sudo zypper up
sudo zypper in libusb-1_0-devel swig cmake python3-devel libconfuse-devel boost-devel doxygen # doxygen for libftdi

# Where are we?
DELINKED=`readlink -f "$0"`
HERE="`dirname "$DELINKED"`"
cd "$HERE" # Be here now.

#Set python -> python3 symlink so the right swig bindings are built
n="3"; PY="/usr/bin/python"; sudo rm $PY; sudo ln -s "python$n" $PY
#Download, build, and install libftdi
wget http://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.1.tar.bz2
tar xvf libftdi1-1.1.tar.bz2
mkdir "$HERE/libftdi1-1.1/build"
cd "$HERE/libftdi1-1.1/build"
cmake -DCMAKE_INSTALL_PREFIX="/usr/" ../
make
sudo make install
#Restore original python -> python2 symlink
n="2"; PY="/usr/bin/python"; sudo rm $PY; sudo ln -s "python$n" $PY

cd "$HERE" # Now be here.
#Download and install Adafruit Python GPIO library
git clone https://github.com/adafruit/Adafruit_Python_GPIO # the thing we're after
git clone https://github.com/doceme/py-spidev.git # a dependency, updated to Python 3
cd "$HERE/py-spidev"
sudo python3 ./setup.py install

# I need to make a diff or something.
echo "Please change line32 of \"$HERE/Adafruit_Python_GPIO/FT232H.py\" from \"import GPIO\""
echo "to \"import Adafruit_GPIO.GPIO as GPIO\" and run setup3.sh."
