#!/usr/bin/python

#
# Find XPC protocol names and exposed methods by parsing class-dump output
# on executable files.
#
# class-dump output is to be piped to the standard input of the program.
# The program is provided the executable file path as argument.
# Parsed information is stored in Python pickle format in the file designated
# by the CONFIG_FILE name.
#
# Sample use (with class-dump):
#  ./class-dump ~/Projects/store/out/iPhone_4.0_64bit_11.1.2_15B202/fs/usr/libexec/rapportd  | ./parse-protocol-names.py /usr/libexec/rapportd
#

import re
import sys
import pickle


CONFIG_FILE = "protocols.pk"


def usage():
    print >>sys.stderr, "Usage: {} executable_filename".format(sys.argv[0])


def main():
    if len(sys.argv) != 2:
        usage()
        sys.exit(1)

    exec_file = sys.argv[1]

    with open(CONFIG_FILE, "rb") as f:
        try:
            dictionary = pickle.load(f)
        except (pickle.PickleError, EOFError):
            dictionary = {}

    dictionary[exec_file] = {}

    # Read input file.
    inputText = sys.stdin.read().strip().replace("\n","").replace("@end","@end\n")

    # Find the names of the XPC protocols based on pattern of using NSXPCConnection.
    for line in inputText.split('\n'):
        protocolPattern = re.compile('\@interface\ (.*?)\ \:\ NSObject \<(.*?)\>\{.*NSXPCConnection.*\;.*?\}')
        protocolMatch = re.match(protocolPattern, line)
        if protocolMatch != None:
            dictionary[exec_file][protocolMatch.group(2)] = []

    # Find the methods and their arguments for each XPC protocol.
    for protName in dictionary[exec_file]:
        for line in inputText.split('\n'):
            protocolPattern = re.compile('\@protocol\ '+protName+'(.*)\@end')
            protocolMatch = re.match(protocolPattern, line)
            # If an XPC protocol header is detected, parse out the methods and arguments.
            if protocolMatch != None:
                coarseMatch = protocolMatch.group(1).replace(";",";\n")
                # Results are stored in the dictionary.
                dictionary[exec_file][protName] = coarseMatch.split("\n")[:-1]

    with open(CONFIG_FILE, "wb") as f:
        pickle.dump(dictionary, f)


if __name__ == "__main__":
    sys.exit(main())
