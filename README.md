# python-ft232h-spi
Setup dependencies and send SPI data via FT232H connected to USB.


About
=====
This contains a bunch of stuff needed to get Python code to access a FT232H in order to use D2XX mode to make it output to SPI very fast.

I mostly followed the directions on the Adafruit tutorial [here](https://learn.adafruit.com/adafruit-ft232h-breakout/overview), but I changed some things to make it work with openSUSE 13.2 with Python3.


Changes
=======
* Instead of using [Adafruit's code](https://github.com/adafruit/Adafruit_Python_GPIO) as-is, I'm using [this version](https://github.com/matthw/Adafruit_Python_GPIO) for Python3 support.
* There's an additional patch at "data/FT232H.py.diff" to make an import statement work.
* Instead of the version that's automatically installed, I installed Python3-compatible py-spidev from [here](https://github.com/doceme/py-spidev).


Installing
==========
* Install the "Base Development" Pattern from Yast -> Software Management.
* Run "do.sh deps-suse install 3"


Running
=======
Plug the device in and run "run.sh".


Bugs
====
* This doesn't actually detect the chip. (error 5 seconds after running run.sh)
* This only supports openSUSE.

