#Automatically sort media files on a WD My Cloud NAS with Incron

##Introduction

WD My Cloud is a NAS with a web access provided by Western Digital.
As it is, it is a great storing device for your media center
(eg : https://kodi.tv/) but it can become a repetitive task to find
the right path, in your library, in which to store each newly
downloaded TV show episode or movie. Although, the My Cloud runs
under a modified version of Debian so it can be tweaked to suit
our needs. So we can add the feature to automatically sort any
media files dropped into a given directory to their right path in
the library.


##Disclaimer

The modification you may do after using SSH to log into your WD My
Cloud may void its warranty and I won't take any responsibility
over that. This tutorial only exists as an informative purpose.
<b>The firmware version on the WD My Cloud that has been used for
this project is v04.04.02-105 and this setup won't function on
earlier builds.</b>


##Setup
###Step 1 : Enable SSH access to My Cloud

Before doing any modification you must make sure they won't be
erased by the next automatic firmware update, to do so, go in your
web browser, open http://wdmycloud.local and log in. Then,
<b>toggle off : Settings>Firmware>Auto Update>Enable
Auto Update </b>


From that same page, you must enable SSH access :
<b>toggle on : Settings>Network Services>SSH</b>

Then from your terminal : 
```
ssh root@wdmycloud.local
```
The default password is welc0me, you should change it once your are
logged in.


###Step 2 : Install Incron and its dependencies

Still in your terminal, SSH as root in your My Cloud :
```
git clone git://github.com/SylvainRX/WDMyCloud_MediaSorter.git
chmod -R 700 WDMyCloud_MediaSorter
cd WDMyCloud_MediaSorter/incron_bin
./install.sh
```


###Step 3 : Setup the file sorting script

Still as root in your My Cloud, create a directory under
"/shares/YourShare/repository" which will be the repository for the
sorting algorithm to watch in for newly added media files :
```
mkdir /shares/YourShare/repository
chmod 777 /shares/YourShare/repository
```


Then create a directory to put in the script files :
```
mkdir /root/.incron
cd ../sortmedia_scripts
mv * /root/.incron
cd ../..
rm -rf WDMyCloud_MediaSorter
```


You need to edit sortmedias.sh in order to specify where are your
TV show and movie libraries :
```
nano /root/.incron/sortmedias.sh
```
Edit the following lines in the opened file so the path are right :
```
PATH_TVSHOWS='/shares/YourShare/TV Shows'
PATH_MOVIES='/shares/YourShare/Movies'
```
Save and exit.


Finally, you need to set up incron to watch for events happening in
your repository :
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


Your WD My Cloud should now be able to sort any files or directory
of files dropped into /shares/YourShare/repository. You can further
edit sortmedias.sh to specify a directory in which to write a log file
and a trash directory to move unsorted files into.


##Make it better with Transmission
I have made this sorting algorithm in a way that the bittorrent
client Transmission can also drop its downloads into the
sorting repository to have them sorted automatically. If you wish
to install transmission, you can uncomment the last lines in install.sh before executing it.
In prior to install transmission, you may want to create a new user
"debian-transmission" via the web ui and grant it full access on the shares
transmission may write into.
To sort any files downloaded, you need to set up Transmission. To do so, start by stopping transmission-deamon 
```
/etc/init.d/transmission-daemon stop
mkdir "/shares/YourShare/repository/.transmission"
```
And edit <b>/var/lib/transmission-daemon/info/settings.json</b> and set the parameter as follow, adapting the path to your own system :
```
"incomplete-dir": "/shares/YourShare/repository/.transmission",
"incomplete-dir-enabled": true,
"watch-dir": "/DataVolume/shares/Sylvain/Depos/",
"watch-dir-enabled": true
```
