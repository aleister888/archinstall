#!/bin/bash

set -e

pacman -Sy git

git clone --branch stable \
	https://github.com/aleister888/archinstall.git \
	/tmp/archinstall

cd /tmp/archinstall
./install.sh
