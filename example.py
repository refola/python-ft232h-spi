'''
Copied from https://learn.adafruit.com/adafruit-ft232h-breakout/spi and changed to work with our situation.

'''

import Adafruit_GPIO.FT232H as FT232H

# Temporarily disable FTDI serial drivers.
FT232H.use_FT232H()

# Find the first FT232H device.
ft232h = FT232H.FT232H()

# Create a SPI interface from the FT232H using pin 8 (C0) as chip select.
# Use a clock speed of 3mhz, SPI mode 0, and most significant bit first.
# Note: Trying pin 3 and hoping it's D3
spi = FT232H.SPI(ft232h, cs=8, max_speed_hz=3000000, mode=0, bitorder=FT232H.MSBFIRST)

# Write bytes out using the SPI protocol.
spi.write([0x3F, 0xFF])
