#!/bin/bash

#http://anionix.ddns.net/dists/jessie-64k/main/binary-armhf/

dpkg -i htop_1.0.3-1_armhf.deb

dpkg -i libgcc1-dbg_4.9.2-10_armhf.deb
dpkg -i libstdc++6_4.9.2-10_armhf.deb
dpkg -i libstdc++6-4.9-dbg_4.9.2-10_armhf.deb
dpkg -i incron_0.5.10-2_armhf.deb

#uncomment the following lines to install transmission bittorent client
#dpkg -i libsystemd0_215-17+deb8u3_armhf.deb
#dpkg -i libminiupnpc10_1.9.20140610-2_armhf.deb
#dpkg -i libnatpmp1_20110808-3_armhf.deb
#dpkg -i transmission-cli_2.84-0.2_armhf.deb
#dpkg -i transmission-common_2.84-0.2_all.deb
#dpkg -i transmission-daemon_2.84-0.2_armhf.deb
