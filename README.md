# python-ft232h-spi
Setup dependencies and send SPI data via FT232H connected to USB.


About
=====
This contains a bunch of stuff needed to get Python code to access a FT232H in order to use D2XX mode to make it output to SPI very fast.

I mostly followed the directions on the Adafruit tutorial [here](https://learn.adafruit.com/adafruit-ft232h-breakout/overview), but I changed some things to make it work with openSUSE 13.2 with Python3.


Changes
=======
* Instead of using [Adafruit's code](https://github.com/adafruit/Adafruit_Python_GPIO) as-is, I'm using [this version](https://github.com/matthw/Adafruit_Python_GPIO) for Python3 support.
* There's an additional patch at "data/FT232H.py.diff" to make an import statement in Python3 mode work.
* Instead of the version that's automatically installed, I installed Python3-compatible py-spidev from [here](https://github.com/doceme/py-spidev).


Installing
==========
* Install the "Base Development" Pattern from Yast -> Software Management.
* Run `do.sh py_ver deps-suse install` where `py_ver` is either `py2` or `py3`


Running
=======
Plug the device in and run `do.sh py_ver run` with the same `py_ver` as installed for.


Known bugs
==========
* Only supports installing deps for openSUSE and *buntu

In openSUSE 13.2, Python3 mode:
* This doesn't actually detect the chip. (error ~5 seconds after running run.sh)

In openSUSE 13.2, Python2 mode:
* ImportError involving libftdi: refola/python-ft232h-spi#1

In Kubuntu 14.04, Python3 mode:
* Error: "Could NOT find PythonLibs (missing:  PYTHON_LIBRARIES PYTHON_INCLUDE_DIRS)" when building libftdi, followed by "Not building python bindings"
* Running results in "ImportError: No module named 'ftdi1'"

In Kubuntu 14.04, Python2 mode:
* Same as in Python3 mode, plus this:
* "spidev_module.c:20:20: fatal error: Python.h: No such file or directory"

In Kubuntu 14.04:
* Remove command gives error "sh: 0: getcwd() failed: No such file or directory" after outputting "Removing build directory."

