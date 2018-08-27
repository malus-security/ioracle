#!/usr/bin/awk -f

BEGIN {
	message = "";
	UNKNOWN = 0;
	KEY_READ = 1;
	state = UNKNOWN;
}

/^[ \t]+<key>/ {
	if (index($0, "<key>"key"</key>") != 0) {
		#print "key found";
		message = message $0 "\n";
		state = KEY_READ;
	}
	else {
		#print "other key";
		if (message != "") {
			printf "%s", message;
			message = "";
                        exit
		}
		state = UNKNOWN;
	}
	next;
}

{
	if (state == KEY_READ) {
		#print "in key";
		message = message $0 "\n"; 
	}
	#print "garbage: ", $0
}

END {
}
