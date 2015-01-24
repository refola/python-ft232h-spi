#/bin/bash
# setup2.sh
# Automate the openSUSE, Python3 installation of Adafruit_Python_GPIO....

# Where are we?
DELINKED=`readlink -f "$0"`
HERE="`dirname "$DELINKED"`"


# Now we can do some scripted stuff....
echo "Updating repositories."
sudo zypper up
echo "Installing dependencies."
sudo zypper in libusb-1_0-devel swig cmake python3-devel libconfuse-devel boost-devel doxygen # doxygen for libftdi


## Download, build, and install libftdi

echo "Retrieving libftdi."
ftdi="libftdi1-1.1"
ftar="$ftdi.tar.bz2"
sha512="49ca09a0e918ca5e03168cfa5d4aaec603141891cacc8f02ae63f5b21e3413a021afde05c6dc9883bb48c04a16c955b14513e8350c8c44540145fc12820721df"
csum="$sha512  $ftar"
wget -c "http://www.intra2net.com/en/developer/libftdi/download/$ftar"
echo "Verifying checksum."
if [[ "`sha512sum $ftar`" == "$csum" ]]
then
	echo "Checksum passed."
else
	echo "Checksum failed. Please try deleting \"$HERE/$ftar\" and trying again."
	exit 1
fi
echo "Extracting libftdi."
tar xvf $ftar

# Keep things tidy.
echo "Making and switching to build directory."
BUILD="$HERE/$ftdi/build"
mkdir "$BUILD"; cd "$BUILD"

# Set python -> python3 symlink so the right swig bindings are built
echo
echo "Changing python symlink to Python3 for correct swig binding building."
n="3"; PY="/usr/bin/python"; sudo rm $PY; sudo ln -s "python$n" $PY

# Now for the actual build and install.
echo
echo
echo "Configuring build."
cmake -DCMAKE_INSTALL_PREFIX="/usr/" ../
echo
echo "Compiling...."
make
echo
echo "Installing...."
sudo make install

#Restore original python -> python2 symlink
echo "Restoring python symlink to Python2."
n="2"; PY="/usr/bin/python"; sudo rm $PY; sudo ln -s "python$n" $PY


## Python libraries

cd "$HERE" # Now be here.
#Download and install Adafruit Python GPIO library
echo
echo
echo "Retrieving the library that all these screens of output are ultimately for."
git clone https://github.com/matthw/Adafruit_Python_GPIO # the thing we're after

# I need to make a diff or something.
echo "Please change line32 of \"$HERE/Adafruit_Python_GPIO/Adafruit_GPIO/FT232H.py\" from \"import GPIO\""
echo "to \"import Adafruit_GPIO.GPIO as GPIO\" and run setup3.sh."
