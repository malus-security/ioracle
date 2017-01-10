import re
import sys

def parse_one(line):
    mach_service = re.findall(r'\"(.*?)\"', line)[0]
    if "->" in line:
        processes = re.findall(r'->(.*?):', line)
        direction = "to"
    elif "<-" in line:
        processes = re.findall(r'<-(.*?):', line)
        direction = "from"

    sys.stdout.write("machComm(" + \
                     "machS(\"" + mach_service + "\")," + \
                     "comm_direction(\"" + direction + "\")" + \
                     ",processes([%s])).\n" % ','.join('"' + p + \
                                                       '"' for p in processes))

if __name__ == "__main__":
    try:
        inputf = sys.argv[1]
    except IndexError:
        print "Usage: program.py <input_file>"
        sys.exit(1)

    for line in open(inputf, "r"):
        parse_one(line)
