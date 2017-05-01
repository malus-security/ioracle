#include <stdio.h>
#include <sandbox.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
	int rv;
	char *errbuff;

	//rv = sandbox_init(kSBXProfileNoInternet, SANDBOX_NAMED_BUILTIN, &errbuff);
	rv = sandbox_init(argv[1], SANDBOX_NAMED, &errbuff);
    
	if (rv != 0) {
		fprintf(stderr, "sandbox_init failed: %s\n", errbuff);
		sandbox_free_error(errbuff);
	} else {
        putenv("PS1=[LUKESANDBOXED] \\h:\\w \\u\\$ ");
        printf("pid: %d\n", getpid());
        execl(argv[2], argv[3], NULL);
	}

	return 0;
}
