#!/usr/bin/python

import re
import sys
import pickle


CONFIG_FILE = "protocols.pk"


def main():
    try:
        with open(CONFIG_FILE, "rb") as f:
            try:
                dictionary = pickle.load(f)
            except (pickle.PickleError, EOFError):
                print >>sys.stderr, "Error: Improperly formatted file"
                sys.exit(1)
    except (IOError):
        print >>sys.stderr, "Error: Open file failed"
        dictionary = {}

    for e in dictionary:
        if dictionary[e]:
            print "/*\n * Protocols for {}\n */\n".format(e)
            for p in dictionary[e]:
                print dictionary[e][p]
            print ""

if __name__ == "__main__":
    sys.exit(main())
