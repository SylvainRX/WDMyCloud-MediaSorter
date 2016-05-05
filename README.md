#Automatically sort media files on a WD My Cloud NAS with Incron

##Introduction

WD My Cloud is a NAS with a web access provided by Western Digital. As it is, it is a great storage device for your media center (eg : https://kodi.tv/), but it can become a repetitive task to find the right path in which to store each newly downloaded TV show episode or movie in your library. However, the My Cloud runs under a modified version of Debian, so it can be tweaked to suit our needs. This tutorial shows how we can add a feature to automatically sort any media files dropped into a given directory to their right path in the library.

The library handled by the sorting scripts must be organized as follow :
/path/TV Shows/[tv show title]/[Season x]/[media files]
/path/Movies/[movie title]/[media files]

Incron provides possibility to simply monitor various events on files in filesystems and will be use to trigger our sorting script. http://inotify.aiken.cz/?section=incron&page=about

##Disclaimer

Any modification you may make using SSH to log into your WD My Cloud may break it and void its warranty. I am not responsible for any issues you may encounter through this process. This tutorial only exists for its informative purpose.

<b>The firmware version on the WD My Cloud that has been used for this project is v04.04.02-105 and this setup won't function on earlier builds.</b>


##Setup
###Step 1 : Enable SSH access to My Cloud

Before doing any modification, you must make sure they won't be erased by the next automatic firmware update. To do so, go in your web browser, open your My Cloud web interface (http://wdmycloud.local) and log in. Then, <b>toggle off : Settings>Firmware>Auto Update>Enable Auto Update </b>

From that same page, you must enable SSH access :
<b>toggle on : Settings>Network Services>SSH</b>

Then from your terminal :
```
ssh root@wdmycloud.local
```
The default password is welc0me, you should change it once you are logged in.


###Step 2 : Install Incron and its dependencies

Before executing the following lines, read the last section of this file. In your terminal, SSH as root in your My Cloud :
```
git clone git://github.com/SylvainRX/WDMyCloud_MediaSorter.git
chmod -R 700 WDMyCloud_MediaSorter
cd WDMyCloud_MediaSorter/incron_bin
./install.sh
```


###Step 3 : Setup the file sorting script

As root in your My Cloud, create a directory under "/shares/YourShare/repository" which will be the repository for the sorting script :
```
mkdir /shares/YourShare/repository
mkdir /shares/YourShare/repository/.trash
chmod -R 777 /shares/YourShare/repository
```
Any new files that are added to the repository will be handled and sorted by the sorting script.

Then create a directory to put in the script files :
```
mkdir /root/.incron
cd ../sortmedia_scripts
mv * /root/.incron
cd ../..
rm -rf WDMyCloud_MediaSorter
```


You need to edit sortmedias.sh in order to specify where are your TV show and movie libraries :
```
nano /root/.incron/sortmedias.sh
```
Edit the following lines in the opened file so the paths are right :
```
PATH_TVSHOWS='/shares/YourShare/TV Shows'
PATH_MOVIES='/shares/YourShare/Movies'
PATH_TRASH='/path/to/your/repository/.trash'
```
Save and exit.


Finally, you need to set up incron to watch for events happening in your repository :
```
incrontab -e
```
Add the following line in the opened file :
```
"/path/to/your/repository" IN_CREATE,IN_MOVED_TO,IN_ISDIR "/path/to/this/script/sortmedias.sh" $# $@ $% $&
```
Save and exit.


Make sure incron is running :
```
/etc/init.d/incron start
```

Your WD My Cloud should now be able to sort any files or directory of files dropped into /shares/YourShare/repository. You can further edit sortmedias.sh to specify a directory in which to write a log file and a trash directory to move unsorted files into.


##Make it better with Transmission
I created this sorting script in a way that in can be used with the bittorrent client Transmission. Transmission can use torrent files dropped into the repository and set the downloaded files into it to have them sorted automatically.

If you wish to install Transmission, you can uncomment the last lines in install.sh before executing it. However, prior to installation, you will want to create a new user "debian-transmission" via the web ui (http://wdmycloud.local/UI/) and grant it full access to the shares directory.

Then you need to set up Transmission : start by stopping transmission-deamon, then create a new directory for incomplete downloads.
```
/etc/init.d/transmission-daemon stop
mkdir "/shares/YourShare/repository"
mkdir "/shares/YourShare/repository/.transmission"
```
Edit <b>/var/lib/transmission-daemon/info/settings.json</b> and set the parameter as follows, adapting the path to your own system :
```
"incomplete-dir": "/shares/YourShare/repository/.transmission",
"incomplete-dir-enabled": true,
"rpc-authentication-required": false,
"rpc-enabled": true,
"rpc-port": 9091,
"rpc-url": "/transmission/",
"rpc-username": "",
"rpc-whitelist": "127.0.0.1,192.168.0.*",
"rpc-whitelist-enabled": true,
"watch-dir": "/shares/YourShare/repository/",
"watch-dir-enabled": true
```
Finally, restart transmission :
```
/etc/init.d/transmission-daemon start
```
You can now start downloads with transmission by dropping torrent files in /shares/YourShare/repository or via its web interface (http://wdmycloud.local:9091/transmission/web/).
