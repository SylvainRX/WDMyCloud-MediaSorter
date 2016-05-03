# Automatically sort media files on a WD My Cloud NAS with Incron

<p>
WD My Cloud is a NAS with a web access provided by Western Digital.
As it is, it is a great storing device for your media center
(eg: https://kodi.tv/) but it can become a repetitive task to find
the right path, in your library, in which to store each newly
downloaded TV show episode or movie. Although, the My Cloud running
under a modified version of Debian so it can be tweaked to suit
your needs. So we can add the feature to automatically sort any
media files dropped into a given directory to their right path in
the library.
</p>

<h2>Disclaimer :</h2>
<p>
The modification you may do after using SSH to log into your WD My
Cloud may void its warranty and I won't take any responsibility
over that. This tutorial is only for an informative purpose.
The firmware version on the WD My Cloud that has been used for this
project is v04.04.02-105 and this setup won't function on earlier
builds.
</p>

<h2>Step 1 : Enable SSH access to My Cloud</h2>
<p>
Before doing any modification you must make sure they won't be
erased by the next automatic firmware update, to do so, go in your
web browser, open http://wdmycloud.local and log in.
Toggle off : Settings > Firmware > Auto Update > Enable Auto Update

Still from that same page, you must enable SSH access:
Toggle on : Settings > Network Services > SSH

Then from your terminal:
ssh root@wdmycloud.local
The default password is welc0me, you should change it once your are
logged in.
</p>

<h2>Step 2 : Install Incron and its dependencies</h2>
<p>
Still in your terminal, SSH as root in your My Cloud:
curl %incron_bin%
cd incron_bin
chmod 700 *
./install.sh
</p>

<h2>Step 3 : Setup the file sorting script</h2>
<p>
Still as root in your My Cloud, create a directory under
"/shares/YourShare/repository" which will be the repository for the
sorting algorithm to watch in for newly added media files :
mkdir /shares/YourShare/repository
chmod 777 /shares/YourShare/repository

Then download the sorting script files :
mkdir /root/.incron
cd /root/.incron
curl %sortmedia_scripts%
cp sortmedia_scripts/* .
rm sortmedia_scripts
chmod 700 *

You need to edit sortmedias.sh in order to specify where are your
TV show and movie libraries :
nano sortmedias.sh
Edit the following lines in the opened file :
  PATH_TVSHOWS='/DataVolume/shares/YourShare/TV Shows'
  PATH_MOVIES='/DataVolume/shares/YourShare/Movies'
Save and exit.

Finally, you need to set up incron to watch for events happening in
your repository :
incrontab -e
Add the following line in the opened file :
  "/path/to/your/repository" IN_CREATE,IN_MOVED_TO,IN_ISDIR "/path/to/this/script/sortmedias.sh" $# $@ $% $&
Save and exit.

Make sure incron is running :
/etc/init.d/incron status
And if it is not :
/etc/init.d/incron start
</p>
