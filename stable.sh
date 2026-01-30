#!/bin/bash
#shellcheck disable=SC2068

pacman --noconfirm -Sy git

git clone --branch stable \
	https://github.com/aleister888/archinstall.git \
	/tmp/archinstall

cd /tmp/archinstall || exit 1

./install.sh $@
