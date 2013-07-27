defcad-host
===========

Generates a website that will update itself with the lastest from defcad-repo

#### Instructions

Currently the best way to do this is:

:~$ cd ~/
:~$ git clone https://github.com/maduce/defcad-host.git
:~$ cd defcad-host
:~$ git clone https://github.com/maduce/defcad-repo.git

Note: If you already have a defcad-repo, you can copy or move it to ~/defcad-host/ instead of recloning it.

Next you can edit ~/defcad-host/config.cfg if you desire.  The defcad configs assumes the defcad-host folder is in ~/ so you can avoid changing the configs and move on to the next step.  To create the database and zipped version of the repo:

:~$ sh hostpack.sh --generate 

To update the zippedpack and database:

:~$ sh hostpack.sh --update

See ~/defcad-repo/hostpack.sh for more options.  To delete the zippedpack and the database (starting from scratch, but not deleting the defcad-repo): 

:~$ sudo hostpack.sh --delete

If you do this you will need to generate the zippedpack again before you update.

Note: This is VERY MUCH a work in progress and has little use at this time.

#### Todo
* setup php website





