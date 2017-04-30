#include <stdio.h>
#include <sandbox.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  int rv;
  char *errbuff;

  //rv = sandbox_init(kSBXProfileNoInternet, SANDBOX_NAMED_BUILTIN, &errbuff);
  rv = sandbox_init(argv[1], SANDBOX_NAMED, &errbuff);

  if (rv != 0) 
  {
    fprintf(stderr, "sandbox_init failed: %s\n", errbuff);
    sandbox_free_error(errbuff);
  } 
  else 
  {
    putenv("PS1=[LUKESANDBOXED] \\h:\\w \\u\\$ ");
    printf("pid: %d\n", getpid());
    //execl(argv[2], argv[3], NULL);

    printf("Currently in the com.apple.tccd sandbox\n");
    //try to do extension stuff
    char *token;
    token = NULL;
    const char *ext= "com.apple.tcc.kTCCServiceAddressBook";
    //const char *ext= "com.SHOULDFAIL.apple.afc.root";
    //const char *path= "/shouldFail/";
    const char *path= "/";
    int reserved = 0;
    int flags = 0;
    int result = 0;
    //this seems to work for generating the extension
    token = sandbox_extension_issue_file(ext, path, reserved, flags);
    printf("Issuing the following extension %s\n",token);
  }

    return 0;
}
