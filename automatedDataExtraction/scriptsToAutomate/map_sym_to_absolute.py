#!/usr/bin/python

#this script resolves file paths that include symbolic links to their absolute paths.
#it expects as arguments the chown_chmod results from the backtracer as well as the results of dynamic analysis.
#firmware processing does not generate any dynamic analysis results, so we need to borrow these files from versions where we had a physical device.

import re
import sys

if len(sys.argv) < 6:
  print "Usage: ./map_sym_to_absolute.py chown_chmod_parameters.pl file_access_observations.pl process_ownership_observations.pl sandbox_extension_observations.pl symlink_metadata_facts.pl"
  exit()

#this function resolves symbolic links in the file path and returns the result.
#It also handles links to relative paths including those with ./ and ../
def resolve_links(path,symlink_target_dictionary):
  for link in symlink_target_dictionary.keys():
    if path.startswith(link):
      #we only replace the the whole filepath if the link taget is an absolute path.
      target = symlink_target_dictionary[link]
      
      if target.startswith("/"):
	path = target + path[len(link):]
      else:
	#use regex to isolate the leaf.
	pattern = re.compile('(^.*\/)(.*?$)')
	match = pattern.match(link)
	link_prefix= match.group(1)
	link_leaf= match.group(2)
	#replace the leaf of the link path with the link target instead and then update the path.
	#e.g., /var/luke/files has /var -> private/var and becomes /private/var/luke/files
	path = link_prefix + target + path[len(link):]
	#resolve ./ and ../ in file path
	#I don't expect to see /./ since it wouldn't do anything, but we might as well model it.

	while "/./" in path:
	  path = path.replace("/./","/")
	while "/../" in path:
	  if path.startswith("/../"):
	    path = path[3:]
	  else:
	    pattern = re.compile('(^.*?\/)([^\/]*\/\.\.\/)(.*$)')
	    match = pattern.match(path)
	    path_prefix= match.group(1)
	    path_to_remove= match.group(2)
	    path_postfix= match.group(3)
	    path = path_prefix + path_postfix
  
  return path

#wrapper for resolve_link function that calls it recursively until there are no links left to resolve in the path.
#this allows us to process file paths that include links to other links
def get_absolute_path(path, symlink_target_dictionary):
  start = path

  dirty_bit = 1
  while dirty_bit == 1:
    result = resolve_links(path,symlink_target_dictionary)
    if result == path:
      dirty_bit = 0
    else:
      #print path
      #print result
      path = result
  
  #some of my replacements might accidentally introduce extra /'s.
  #it's easier to just remove and redundant slashes than to try preventing them.
  while "//" in path:
    path = path.replace("//","/")
  
  #we should keep an eye out for this error in our results
  if not path.startswith("/"):
    path = "ERROR: file path should begin with /" 
  return path

#read the input prolog files specified in command line arguments
fdata = open(sys.argv[1],"r").read().strip()
chown_chmod_entries = fdata.split("\n")

fdata = open(sys.argv[2],"r").read().strip()
file_access_entries = fdata.split("\n")

pdata = open(sys.argv[3],"r").read().strip()
process_ownership_entries = pdata.split("\n")

sdata = open(sys.argv[4],"r").read().strip()
sandbox_extension_entries = sdata.split("\n")

#get the symlinks
symdata = open(sys.argv[5],"r").read().strip()
symlink_lines = symdata.split("\n")

#TODO add user facts as an input source
#TODO update whatever script calls this one to specify the new file
udata = open(sys.argv[6],"r").read().strip()
user_entries = udata.split("\n")

#start a dictionary of symlinks
symlink_target_dictionary = {}
for symlink in symlink_lines:
  pattern = re.compile('^fileSymLink\(symLinkObject\("([^"]*)"\),filePath\("([^"]*)"\)\)\.$')
  match = pattern.match(symlink)
  link_target = match.group(1)
  link_location = match.group(2)
  symlink_target_dictionary[link_location] = link_target

#resolve links in backtracer results
for ch_access in chown_chmod_entries:
  #print ch_access
  pattern = re.compile('(^.*\),parameter\(")([^"]*)(".*)$')
  match = pattern.match(ch_access)
  prefix = match.group(1)
  path = match.group(2)
  postfix = match.group(3)
  #some of the process paths are invalid and I'd rather throw them out than leave them in the data set
  #for now, we can only handle backtracer parameters that are absolute file paths.
  if "/" in path:
    absolute_path = get_absolute_path(path, symlink_target_dictionary)
    print prefix + absolute_path + postfix

#resolve links in fileAccessObservation results
for file_access in file_access_entries:
  pattern = re.compile('(^fileAccessObservation\(process\(")([^"]*)(".*)$')
  match = pattern.match(file_access)
  prefix = match.group(1)
  path = match.group(2)
  postfix = match.group(3)
  #some of the process paths are invalid and I'd rather throw them out than leave them in the data set
  if "/" in path:
    absolute_path = get_absolute_path(path, symlink_target_dictionary)
    print prefix + absolute_path + postfix

#resolve links in process_ownership results
for process_ownership in process_ownership_entries:
  pattern = re.compile('(^.*,comm\(")([^"]*)(.*$)')
  match = pattern.match(process_ownership)
  prefix = match.group(1)
  path = match.group(2)
  postfix = match.group(3)
  #some of the process paths are invalid and I'd rather throw them out than leave them in the data set
  if "/" in path:
    absolute_path = get_absolute_path(path, symlink_target_dictionary)
    print prefix + absolute_path + postfix

#resolve links in sandbox_extension results
for sandbox_extension in sandbox_extension_entries:
  #we only need to worry about symbolic links in the file path type values
  if ",type(\"file\")," in sandbox_extension:
    pattern = re.compile('(sandbox_extension\(process\(")([^"]*)(".*,type\("file"\),value\(")([^"]*)(.*$)')
    match = pattern.match(sandbox_extension)
    prefix = match.group(1)
    process_path = match.group(2)
    between_process_and_value = match.group(3)
    value_path = match.group(4)
    postfix = match.group(5)
    #some of the process paths are invalid and I'd rather throw them out than leave them in the data set
    if "/" in process_path:
      absolute_process_path = get_absolute_path(process_path, symlink_target_dictionary)
      absolute_value_path = get_absolute_path(value_path, symlink_target_dictionary)
      print prefix + absolute_process_path + between_process_and_value + absolute_value_path + postfix
  else:
    pattern = re.compile('(sandbox_extension\(process\(")([^"]*)(.*$)')
    match = pattern.match(sandbox_extension)
    prefix = match.group(1)
    path = match.group(2)
    postfix = match.group(3)
    #some of the process paths are invalid and I'd rather throw them out than leave them in the data set
    if "/" in path:
      absolute_path = get_absolute_path(path, symlink_target_dictionary)
      print prefix + absolute_path + postfix

#TODO copy the process_ownership loop and do the same for user homes.
#resolve links in Unix user results
for user in user_entries:
  pattern = re.compile('(^.*,homeDirectory\(")([^"]*)(.*$)')
  match = pattern.match(user)
  prefix = match.group(1)
  path = match.group(2)
  postfix = match.group(3)
  #some of the process paths are invalid and I'd rather throw them out than leave them in the data set
  if "/" in path:
    absolute_path = get_absolute_path(path, symlink_target_dictionary)
    print prefix + absolute_path + postfix


