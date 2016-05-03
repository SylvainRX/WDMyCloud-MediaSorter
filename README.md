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

<h2>Setup</h2>
<h3>Step 1 : Enable SSH access to My Cloud</h3>
<p>
Before doing any modification you must make sure they won't be
erased by the next automatic firmware update, to do so, go in your
web browser, open http://wdmycloud.local and log in.<br/>
&nbsp;&nbsp;<b>Toggle off : Settings > Firmware > Auto Update > Enable Auto Update </b><br/>
</p>
<p>
Still from that same page, you must enable SSH access:<br/>
&nbsp;&nbsp;<b>Toggle on : Settings > Network Services > SSH</b>
</p>
Then from your terminal:
&nbsp;&nbsp;<b>ssh root@wdmycloud.local</b>
The default password is welc0me, you should change it once your are
logged in.
</p>

<h3>Step 2 : Install Incron and its dependencies</h3>
<p>
Still in your terminal, SSH as root in your My Cloud:
&nbsp;&nbsp;<b>curl %incron_bin%</b><br/>
&nbsp;&nbsp;<b>cd incron_bin</b><br/>
&nbsp;&nbsp;<b>chmod 700 *</b><br/>
&nbsp;&nbsp;<b>./install.sh</b><br/>
</p>

<h3>Step 3 : Setup the file sorting script</h3>
<p>
Still as root in your My Cloud, create a directory under
"/shares/YourShare/repository" which will be the repository for the
sorting algorithm to watch in for newly added media files :
&nbsp;&nbsp;<b>mkdir /shares/YourShare/repository</b><br/>
&nbsp;&nbsp;<b>chmod 777 /shares/YourShare/repository</b><br/>

Then download the sorting script files :
&nbsp;&nbsp;<b>mkdir /root/.incron</b><br/>
&nbsp;&nbsp;<b>cd /root/.incron</b><br/>
&nbsp;&nbsp;<b>curl %sortmedia_scripts%</b><br/>
&nbsp;&nbsp;<b>cp sortmedia_scripts/* .</b><br/>
&nbsp;&nbsp;<b>rm sortmedia_scripts</b><br/>
&nbsp;&nbsp;<b>chmod 700 *</b><br/>

You need to edit sortmedias.sh in order to specify where are your
TV show and movie libraries :
nano sortmedias.sh
Edit the following lines in the opened file :
  PATH_TVSHOWS='/DataVolume/shares/YourShare/TV Shows'
  PATH_MOVIES='/DataVolume/shares/YourShare/Movies'
Save and exit.

Finally, you need to set up incron to watch for events happening in
your repository :
&nbsp;&nbsp;<b>incrontab -e<b></br>
Add the following line in the opened file :
&nbsp;&nbsp;<b>"/path/to/your/repository" IN_CREATE,IN_MOVED_TO,IN_ISDIR "/path/to/this/script/sortmedias.sh" $# $@ $% $&</b><br/>
Save and exit.

Make sure incron is running :
&nbsp;&nbsp;<b>/etc/init.d/incron status<b></br>
And if it is not :
&nbsp;&nbsp;<b>/etc/init.d/incron start<b></br>
</p>
