defcad-host
===========

Generates a website that will update itself with the lastest from fosscad-repo.

#### Instructions

Currently the best way to do this is:

```bash
:~$ cd ~/
:~$ git clone https://github.com/maduce/fosscad-host.git
:~$ cd defcad-host
:~$ git clone https://github.com/maduce/fosscad-repo.git
```

Note: If you already have a fosscad-repo, you can copy or move it to ~/fosscad-host/ instead of recloning it.

Next you can edit ```~/fosscad-host/config.cfg``` if you desire.  The default configs assume the fosscad-host folder is in ```~/``` so you can avoid changing the configs and move on to the next step if you followed the above instructions.  To create the database and a zipped version of the repo (~/defcad-host/web/www/zippedlib/):
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
If you use --delete you will need to generate the zippedpack again before you update.

Note: This is VERY MUCH a work in progress and has little use at this time.
