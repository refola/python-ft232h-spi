#!/bin/bash
# setup.sh
# Automate the openSUSE, Python[3] installation of Adafruit_Python_GPIO....


####    INDEX    ####
# index
# system
# text-processing
# ui
# other


####    SYSTEM    ####
# Ensure right openSUSE packages are installed
susedeps() {
	# Set variable
	local pkgs="libusb-1_0-devel swig cmake libconfuse-devel boost-devel"
	if [[ "$V" == "3" ]]
	then
		pkgs="$pkgs python3-devel"
	elif [[ "$V" == "2" ]]
	then
		pkgs="$pkgs python-devel"
	fi
	debug "Package list: $pkgs"

	# Update and install
	echo "Updating repositories."
	sudo zypper up
	echo "Installing dependencies."
	sudo zypper in $pkgs
}
buntudeps() {
	# Set variable
	local pkgs="build-essential libusb-1.0-0-dev swig cmake libconfuse-dev libboost-all-dev"
	if [[ "$V" == "3" ]]
	then
		pkgs="$pkgs python3-dev python3-pip"
	elif [[ "$V" == "2" ]]
	then
		pkgs="$pkgs python-dev python-pip"
	fi
	debug "Package list: $pkgs"

	# Update and install
	echo "Updating repositories."
	sudo apt-get update
	echo "Installing dependencies."
	sudo apt-get install $pkgs
}
# Output what "python" command points to
# NOTE: Outputs "." if python command is not link
getpylink() {
	local py="$(which python)"
	if [ -h "$py" ]
	then
		echo -n "$(readlink "$py")"
	else
		echo -n "."
	fi
}
# Set what "python" command points to
# Usage: setpylink target
# NOTE: Exits script if python command is not link
setpylink() {
	local name="$(which python)"
	local target="$1"
	if [ -h "$name" ]
	then
		debug "Changing python link: $name -> $target"
		sudo rm "$name"
		sudo ln -s "$target" "$name"
	else
		err "$name is not a symlink"
	fi
}
# Output what "python" command points to sets it
# Usage: VAR="$(getsetpylink target)"
# NOTE: Exits script if python command is not link
getsetpylink() {
	# Get and change Python default version.
	local oldpy="$(getpylink)"
	if [[ "$oldpy" == "." ]]
	then
		err "cannot change python version when the python command isn't a link"
	fi
	setpylink "python$V"
	echo -n "$oldpy"
}
# Install libftdi
# NOTE: Exits script on checksum fail
installlibftdi() {
	# All the vars.
	local ftdi="libftdi1-1.1"
	local ftar="$ftdi.tar.bz2"
	local csum="$(cat "$DATA/ftdicsum")"
	local fbuild="$BUILD/$ftdi/build"
	local seconds="5"
	local pause="...    "
	local url="http://www.intra2net.com/en/developer/libftdi/download/$ftar"

	# Make sure we're in the right place.
	cd "$BUILD"

	# Acquire libftdi
	verbose "Downloading libftdi."
	wget -c "$url"
	verbosef "Calculating checksum.$pause"
	if [[ "$(sha512sum "$ftar")" == "$csum" ]]
	then
		verbosef "... Passed. Now extracting.$pause"
	else
		verbose "Failed."
		errf "Deleting file \"$ftar\" in $seconds seconds."
		for (( i=0; i<seconds; i++))
		do
			sleep 1
			errf " . "
		done
		rm "$ftar"
		errf "Deleted. Please try running the script again.\n"
		exit 1
	fi
	tar xf $ftar # "eXtract From"
	verbose "... Extracted."

	# Keep things tidy.
	mkdir "$fbuild"
	cd "$fbuild"

	# Now for the actual build and install.
	verbose "Configuring libftdi build."
	cmake -DCMAKE_INSTALL_PREFIX="/usr/" ../
	verbose "Compiling libftdi...."
	make
	echo "Installing libftdi...."
	sudo make install
}
# Install Adafruit's Python GPIO library
install_Adafruit_Python_GPIO() {
	# All the local variables
	local agp="Adafruit_Python_GPIO"
	if [[ "$V" == "3" ]]
	then
		local agpgit="https://github.com/matthw/$agp.git"
	else
		local agpgit="https://github.com/adafruit/$agp.git"
	fi
	local unpatched="$BUILD/$agp/Adafruit_GPIO/FT232H.py"
	local patch="$DATA/FT232H.py.diff"
	local spidev="py-spidev"
	local spidevgit="https://github.com/doceme/$spidev"

	# Move to right place
	cd "$BUILD"

	# Py3: Custom py-spidev
	if [[ "$V" == "3" ]]
	then
		verbose "Getting spidev."
		git clone "$spidevgit"
		cd "$BUILD/$spidev"
		echo "Installing py-spidev."
		sudo "python$V" ./setup.py install
		cd "$BUILD" # move back
	fi

	#Download
	verbose "Retrieving $agp."
	git clone "$agpgit"

	# Py3: Patch
	if [[ "$V" == "3" ]]
	then
		verbose "Patching $unpatched."
		patch "$unpatched" "$patch"
	fi

	# Install
	echo "Installing $agp for Python$V."
	cd "$BUILD/$agp"
	sudo "python$V" ./setup.py install
}
# Install Python stuff
instpystuff() {
	# Change Python version
	local oldpy="$(getsetpylink)"

	# Install
	mkdir "$BUILD"
	installlibftdi
	install_Adafruit_Python_GPIO

	# Restore python version
	setpylink "$oldpy"

	# Directions
	echo "Install complete! Use \"do.sh py$V run\" to run example code."
}
# Remove installed files except system packages
clean() {
	# Change Python version
	local oldpy="$(getsetpylink "python$V")"

	echo "Removing installed Python packages."
	sudo "pip$V" uninstall -y Adafruit-GPIO spidev

	echo "Removing libftdi stuff from around the system."
	cd "$BUILD/libftdi1-1.1/build"
	# Anyone know a better way to do what "sudo make uninstall" would do if it existed? The "cut -c16-" part looks neither clean nor portable.
	sudo rm $(sudo make install | grep 'Up-to-date' | cut -c16-)

	echo "Removing build directory."
	debug "\$BUILD = $BUILD"
	sudo rm -rf "$BUILD"

	# Restore python version
	setpylink "$oldpy"
}
# Run example Python program
run() {
	echo "Running example.py...."
	sudo "python$V" "$DATA/example.py"
}


####    TEXT-PROCESSING    ####
# Print argument iff $DEBUG && $VERBOSE
# Usage: verbug "message"
verbug() {
	if "$VERBOSE" && "$DEBUG"
	then
		errn "$1"
	fi
}
# Print argument iff $DEBUG || $VERBOSE
# Usage: verobug "message"
verobug() {
	if "$VERBOSE" || "$DEBUG"
	then
		errn "$1"
	fi
}
# Print argument iff $VERBOSE
# Usage: verbose "message"
verbose() {
	if "$VERBOSE"
	then
		errn "$1"
	fi
}
# Fprint argument iff $VERBOSE
# Usage: verbosef "message"
verbose() {
	if "$VERBOSE"
	then
		errf "$1"
	fi
}
# Print argument iff $DEBUG
# Usage: debug "message"
debug() {
	if "$DEBUG"
	then
		errn "$1"
	fi
}
# Print single parameter for usage function
# Usage: param "parameter" "description"
param() {
	printf "  %-15b%b\n" "$1" "$2"
}
# Output error message and exit script
# Usage: err "message"
err() {
	errn "Error: $1"
	exit 1
}
# Output message to /dev/stderr with newline and don't exit script
# Usage: errn "message"
errn() {
	errf "$1\n"
}
# Output printf'd error message and don't exit script
# Usage: errf "message"
errf() {
	printf "%b" "$1" > /dev/stderr
}
# Deobfuscates $DATA/thing
# Usage: VAR="$(deobfuscate "thing")"
deobfuscate(){
	"$DATA/obfus" de "$1" "$2"
}


####    UI    ####
# Run usage() if no input given
# Usage: checkhelp "$1"
checkhelp() {
	# Show help if no input.
	if [ -z "$1" ]
	then
		usage
	fi
}
# Print usage information and exit script
usage() {
	echo "Usage: do.sh [args]"
	echo "Does stuff involving Adafruit_Python_GPIO on Linux."
	echo "Args"
	param "debug"		"Show debugging information"
	param "deps-buntu"	"Install *buntu dependencies"
	param "deps-suse"	"Install openSUSE dependencies"
	param "help"		"Show this help message and exit"
	param "install"		"Install Adafruit_Python_GPIO"
	param "py2"		"Use Python version 2"
	param "py3"		"Use Python version 3 (default)."
	param "run"		"Run example code"
	param "remove"		"Remove everything but dependencies"
	param "support"		"Show tech support info and exit"
	param "verbose"		"More text"
	exit 1
}
# Show support information
support() {
	verbose "Please stand by while retrieving support information.\n"
	verbose "Fetching:\n"
	verbose " * email address ... "
	email="$(deobfuscate "email" "10")"
	verbose "done.\n"
	verbose " * bug report URL ... "
	url="$(deobfuscate "bugreport" "10")"
	verbose "done.\n"
	verbose "Tech support info retrieved."
	echo "You can receive technical support via these options."
	echo "1. File a GitHub ticket at $url."
	echo "   This directly integrates with the project; it's super effective."
	echo "   Please check if there's an open issue for your problem first."
	echo "2. Email a developer at $email. This directly notifies"
	echo "   a developer and doesn't need you to make a new account, but"
	echo "   no one will know about the bug report until a developer manually"
	echo "   enters it."
	exit 1
}
# Define global variable representing user's commands
# Usage: processinput "$@"
processinput() {
	# Go through user input
	for input in "$@"
	do
		case "$input" in
		debug)
			DEBUG="true";;
		deps-buntu)
			RUNDEPS="buntudeps";;
		deps-suse)
			RUNDEPS="susedeps";;
		help)
			RUNHELP="usage";;
		install)
			RUNINSTALL="instpystuff";;
		py2)
			V="2";;
		py3)
			V="3";;
		run)
			RUNRUN="run";;
		remove)
			RUNREMOVE="clean";;
		support)
			RUNSUPPORT="support";;
		verbose)
			VERBOSE="true";;
		*)
			errf "Error: unknown arg $input\n"
			usage
		esac
	done
}


####    OTHER    ####
# Set global default and noninteractive variables
setdefaultvars() {
	# Vars that don't depend on input
	HERE="$(dirname "$(readlink -f "$0")")"
	BUILD="$HERE/build"
	DATA="$HERE/data"
	# Defaults
	V="3" # The version of Python to use
	VERBOSE="false" # If a bunch of stuff should be said
	DEBUG="false" # Diagnostic output
}
# Run commands requested by user
runcommands() {
	# Run command(s)
	if [ ! -z "$RUNHELP" ] # Help - priority 1 - cancels all else
	then
		$RUNHELP
	fi
	if [ ! -z "$RUNSUPPORT" ] # Support info - also cancels the below
	then
		$RUNSUPPORT
	fi
	if [ ! -z "$RUNDEPS" ] # Dependencies - before other externalities
	then
		$RUNDEPS
	fi
	if [ ! -z "$RUNINSTALL" ] # Install - before running
	then
		$RUNINSTALL
	fi
	if [ ! -z "$RUNRUN" ] # run code
	then
		$RUNRUN
	fi
	if [ ! -z "$RUNREMOVE" ] # remove stuff
	then
		$RUNREMOVE
	fi
}
# Do everything by calling things that do things and call things
# Usage: main "$@"
main() {
	setdefaultvars # This MUST be done before anything else, even printing help.
	checkhelp "$1"
	processinput "$@"
	runcommands
}
# Invoke program
main "$@"
