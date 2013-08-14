fosscad-host
===========

Generates a website that will update itself with the lastest from fosscad-repo.

## Instructions

##### Get The tools:

Currently the fastest way to do this is to open terminal and type the following:

```bash
:~$ cd ~/
:~$ git clone https://github.com/maduce/fosscad-host.git
:~$ cd defcad-host
:~$ git clone https://github.com/maduce/fosscad-repo.git
```

***Note:*** If you already have a fosscad-repo, you can copy or move it to ~/fosscad-host/ instead of cloning it again.

##### Configurations:

Next you can edit ```~/fosscad-host/config.cfg``` if you desire.  The default configs assume the fosscad-host folder is in ```~/``` so you can avoid changing the configs and move on to the next step if you followed the above instructions.  There is a very simple php website inside of ```~/fosscad-host/web/www/``` which can recursive list the files inside of zippedlib to a webpage.  If you want to use this for a website be sure to move the contents of ```~/fosscad-host/web/www/``` to your web directory and configure ```~/fosscad-host/config.cfg``` to write ```zippedlib``` in that directory.  You can edit the index.php if you would like to customize things or change the name of the folder containing all the zip files. 

##### Generate, Update or Delete the Zip Files:

Now, to create the database and a zipped version of the repo (~/fosscad-host/web/www/zippedlib/):
```bash
:~$ sh hostlib.sh --generate 
```
To update the zippedlib and database:
```bash
:~$ sh hostlib.sh --update
```
See ~/fosscad-repo/hostpack.sh for more options.  To delete the zippedlib and the database (i.e., starting from scratch, but not deleting the ~/fosscad-host/fosscad-repo/ folder), run: 
```bash
:~$ sh hostlib.sh --delete
```
If you use --delete you will need to generate the zippedlib folder again before you update.

##### Setup Cron Update:

There is a separate update script ```cron.sh``` that can be used to check for updates instead of running ``` sh hostlib.sh --update``` manually. YOU MUST CONFIGURE THIS SCRIPT BEFORE USING IT OR ELSE IT WILL NOT WORK.  Be sure to make the cron script executable (i.e., ```chmod u+x cron.sh```) and to add the cron as root (i.e., ```sudo crontab -e```).  The cron script will not work unless it is run with root. For example, after configuring ```cron.sh```, you can add it to cron by:

```bash
:~$ sudo crontab -e
```
This might ask you to pick an editor and you can pick you favorite editor, i.e., ```nano```. From then on it will open a text file where you can add the following to have```cron.sh``` run every 24 hours:

```bash
0 */24 * * * /home/user/fosscad-host/testing/cron.sh
```
to add a log file, i.e., ```/path/to/logfile.log```, you can add the following to your cron:

```0 */24 * * * /home/user/fosscad-host/testing/cron.sh  2>&1 >> /path/to/logfile.log```

Have fun...
