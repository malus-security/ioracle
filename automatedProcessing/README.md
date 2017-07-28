# Automated Processing of iOracle Facts

These scripts are used for automated processing of iOracle Prolog facts. iOracle Prolog facts consist of static and dynamic analysis information. Then rules files are added. Scripts are basically Prolog queries that are run on facts for each iOS version.

## Locations

Prolog input facts are in files that respect a given format. Prolog rules are in files in the iOracle repository. Both of these need to be defined in the `config` file.

The `IORACLE_REPOSITORY` variable in the `config` file points to the iOracle repository. The rules Prolog files are located in the `rules/` subfolder in the repository:

```
razvan@debian:~/ios-security/iOracle.git$ ls rules/
all_rules.pl  helper_rules.pl  sandboxAllowRules.pl  unixAllowRules.pl
```

The `PROLOG_FACTS_DIR` points to the top level directory where extracted Prolog facts are stored. The `static/` subfolder is of interest; within this there is a subfolder for each version:

```
razvan@debian:~/ios-security/prolog-data/static$ ls -F
10.0/  10.1/  10.2/  10.3/  11.0/  6.0/  6.1/  7.0/  7.1/  8.0/  8.1/  8.2/  8.3/  8.4/  9.0/  9.1/  9.2/  9.3/
```

Inside the folder for each version there is an `all_facts.pl` file. This file is the outcome of the static and dynamic analysis phase and contains all Prolog facts, as documented [here](https://github.com/malus-security/iOracle/blob/master/documentation/prolog_fact_documentation.txt).

For intermediary working environment, the `TOPLEVEL_WORKING_DIR` variable is used. This is the folder where a subfolder is created for each run of a script for each version. Subfolder use a custom name including the version, the date and a random suffix (see the `make_query` script). This is where all files are linked (input facts, rules, queries, script) and where the script is run:

```
razvan@debian:~/ios-security/prolog-query-work/9.3_2017-07-28_16:28.sC6VA$ ls
all_facts.pl  all_rules.pl  helper_rules.pl  queries.pl  run  sandboxAllowRules.pl  unixAllowRules.pl
```

The output files are stored in `TOPLEVEL_OUTPUT_DIR`. For each script run on *all* versions, a subfolder is created, using a custom name including the version, the script name, the date and a random suffix (see the `all_versions_make_query` script). The output is stored on a file per version, using the version and the `.out` extension:

```
razvan@debian:~/ios-security/query-output$ ls num-sandboxed-executables_2017-07-28_15\:04.AqzfU/
10.0.out  10.1.out  10.2.out  10.3.out  11.0.out  6.0.out  6.1.out  7.0.out  7.1.out  8.0.out  8.1.out  8.2.out  8.3.out  8.4.out  9.0.out  9.1.out  9.2.out  9.3.out
```

## Resource Files

Resource files in this folder are:

* `README.md`: this file, documenting the use of the script resource file
* `config`: configuration file defining locations of input, intermediary and output data; variables in this file need to be updated to the proper values before using the scripts
* `make_query`: the basic script to run a query for a given version
* `all_versions_make_query`: the wrapper script around `make_query` that runs a query on all versions in `PROLOG_FACTS_DIR/static/`
* `scripts`: this is where query scripts are located; there is a folder for each query and all files in that folder are linked in the working directory; a `run` script needs to be part of the folder for each query

Assuming there are query subfolders in the `scripts` folder, the `make_query` script can be used for running the query for a given version. A working directory will be created in `TOPLEVEL_WORKING_DIR` and the output will be shown at standard output:

```
razvan@debian:~/ios-security/iOracle.git/automatedProcessing$ ./make_query 10.1 scripts/num-unused-sandbox-profiles/                                                             Using /home/razvan/ios-security/prolog-query-work/10.1_2017-07-28_16:49.KNr3J as working directory.
Linking facts and rules files in /home/razvan/ios-security/prolog-query-work/10.1_2017-07-28_16:49.KNr3J.
Linking scripts, queries and support files from scripts/num-unused-sandbox-profiles/ in /home/razvan/ios-security/prolog-query-work/10.1_2017-07-28_16:49.KNr3J.
Running script.
Warning: /home/razvan/ios-security/prolog-query-work/10.1_2017-07-28_16:49.KNr3J/sandboxAllowRules.pl:18:
        Singleton variables: [Ent,Ext,Home,Subject]
[...]
29
```

Running the `make_query` script is likely to take some time (minutes) because it has to load the large input Prolog facts file (`all_facts.pl`). Ignore the `Singleton variables` warnings, they aren't critical for the running of the script.

The `all_versions_make_query` wrapper script is to be used for running a query on all versions. It calls the `make_query` script for each version. It stores the output of each run of the `make_query` script in a file in a subfolder of `TOPLEVEL_OUTPUT_DIR`:

```
razvan@debian:~/ios-security/iOracle.git/automatedProcessing$ ./all_versions_make_query scripts/list-sandbox-profiles/
Using /home/razvan/ios-security/query-output/list-sandbox-profiles_2017-07-28_16:13.xcb3c as output directory.
Running scripts/list-sandbox-profiles/ for version 10.0.
Using /home/razvan/ios-security/prolog-query-work/10.0_2017-07-28_16:13.h90xA as working directory.
Linking facts and rules files in /home/razvan/ios-security/prolog-query-work/10.0_2017-07-28_16:13.h90xA.
Linking scripts, queries and support files from scripts/list-sandbox-profiles/ in /home/razvan/ios-security/prolog-query-work/10.0_2017-07-28_16:13.h90xA.
Running script.
[...]
Output in /home/razvan/ios-security/query-output/list-sandbox-profiles_2017-07-28_16:13.xcb3c/10.1.out
Running scripts/list-sandbox-profiles/ for version 10.2.
Using /home/razvan/ios-security/prolog-query-work/10.2_2017-07-28_16:15.9hYEQ as working directory.
[...]
```

Running the `all_versions_make_query` script is going to take some time (tens of minutes to an hour) because it has to load the large input Prolog facts file (`all_facts.pl`) for each version.

## Query Scripts

Query scripts are located in the `scripts/` folder. For each query there is a subfolder named after the query containing the scripts (Bash, Prolog) and support files:

```
razvan@debian:~/ios-security/iOracle.git/automatedProcessing$ ls -F scripts/
list-sandbox-profiles/         list-used-sandbox-profiles/  num-sandbox-profiles/         num-unused-sandbox-profiles/
list-unused-sandbox-profiles/  num-sandboxed-executables/   num-unsandboxed-executables/  num-used-sandbox-profiles/
```

Files in each query subfolder are linked in the working directory together with facts and rules Prolog file.

For each query script subfolder, a `run` executable (with execution permissions enabled) must exist. It is executed in the working directory and assumes all resource files (such as Prolog facts, rules and query scripts) are located there as well. As it is assumed you would do Prolog queries, there usually is a `queries.pl` file that defines the queries and support rules required:

```
razvan@debian:~/ios-security/iOracle.git/automatedProcessing$ ls -F scripts/list-sandbox-profiles/
queries.pl  run*
```

`run` typically invokes the `swipl` to load the `queries.pl` file and run a given query; it will then post-process the output of the query. In order to use the Prolog facts and rules files, the `queries.pl` script loads them:

```
razvan@debian:~/ios-security/iOracle.git/automatedProcessing$ cat scripts/list-sandbox-profiles/queries.pl
:- [all_facts,all_rules].
[...]
```

When creating a Prolog query in the `queries.pl` file, take into account the output you want to provide. Most likely you will use `writeln` or some other Prolog printing function.

In order to create and test a query (before placing it in the `queries.pl`) file, it is recommended you create a temporary folder and link the facts and rules Prolog files. Then you start the Prolog interpreter using the `swipl` command and load the facts and rules Prolog files by using `[all_facts,all_rules].` at the `swipl` command prompt.

## Setting Up

Once you've cloned the [iOracle repository](https://github.com/malus-security/iOracle/), you need to set up the Prolog facts. Create `PROLOG_FACTS_DIR`, create a subfolder for each version and then copy the `all_facts.pl` file in each subfolder.

Fill the variables in the `config` file. Then create the `TOPLEVEL_WORKING_DIR` and `TOPLEVEL_OUTPUT_DIR`.

That's it. Now you can use the `make_query` and, more likely, the `all_versions_make_query` scripts to process data.
