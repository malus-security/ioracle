Still WIP:

Requirements:
* download filemon: wget http://newosxbook.com/tools/filemon.tgz on device

Steps to run:
* run ./createLogsDatabase.py to create *logs* database. The database contains 2 tables: *appOutput* and *run*.
* First table contain details regarding the output of the fuzzing app; the second table contains details about the run (device version, filemon output file, crash logs folder, etc.)
* configure *run.config*
* run *./run.sh*
* inspect *results* folder

