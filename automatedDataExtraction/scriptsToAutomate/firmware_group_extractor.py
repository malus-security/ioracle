#!/usr/bin/env python3
import sys

input_path = sys.argv[1]
group_file_path = input_path + "/etc/group"
user_file_path = input_path + "/etc/passwd"
fg = open(group_file_path, 'r')
fu = open(user_file_path, 'r')
group_lines = fg.read().strip().split("\n")
user_lines = fu.read().strip().split("\n")

group_number_to_name_dict = {}

for g_line in group_lines:
  #ignore comments
  if g_line.startswith('#'):
    continue

  columns = g_line.split(":")
  group_name = columns[0]
  group_id_number = columns[2]
  group_number_to_name_dict[group_id_number] = group_name

  #ignore groups without members
  if columns[3] == "":
    continue

  members = columns[3].split(",")
  for user_name in members:
    print("groupMembership(user(\"" + user_name + "\"),group(\"" + group_name +  "\"),groupIDNumber(\"" + group_id_number + "\")).")

for u_line in user_lines:
  #ignore comments
  if u_line.startswith('#'):
    continue
  #each user has a default gid number for the group they belong to by default
  #we have to extract this information from /etc/passwd since it doesn't seem to appear in /etc/group
  columns = u_line.split(":")
  user_name = columns[0]
  user_id_number = columns[2]
  group_id_number = columns[3]

  #if id of user and group match then the group name is same as user name
  if user_id_number == group_id_number:	
    print ("groupMembership(user(\"" + user_name + "\"),group(\"" + user_name +  "\"),groupIDNumber(\"" + group_id_number + "\")).")
  #otherwise we need to know what the group name is for a given gid number (e.g., user _ftp has gid for "nobody" by default instead of "_ftp")
  else:
    print ("groupMembership(user(\"" + user_name + "\"),group(\"" + group_number_to_name_dict[group_id_number] +  "\"),groupIDNumber(\"" + group_id_number + "\")).")

