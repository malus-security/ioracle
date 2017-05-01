#include <stdio.h>
#include <sandbox.h>
#include <unistd.h>
#include <stdlib.h>

extern int sandbox_extension_consume(const char *token);
extern int sandbox_issue_extension(const char *extension, const char *token);
extern char *sandbox_extension_issue_file(const char *ext, const char *path, int reserved, int flags);
extern char *sandbox_extension_issue_mach(const char *ext, const char *mach, int reserved, int flags);
extern char *sandbox_extension_issue_generic(const char *ext, int reserved, int flags);
extern char *sandbox_extension_issue(const char *ext, int reserved, int flags);

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

    printf("Currently in the sandbox\n");

    //try to do extension stuff
    char *token;
    token = NULL;
    const char *ext= "com.apple.afc.root";
    const char *mach= "whatever.service";
    int result = 0;
    int reserved = 0;
    int flags = 0;
    token = sandbox_extension_issue_mach(ext, mach, reserved, flags);
    printf("Issuing the following extension %s\n",token);
    //sandbox_extension_consume(token);

    token = sandbox_extension_issue_file(ext, mach, reserved, flags);
    printf("Issuing the following extension %s\n",token);
    //sandbox_extension_consume(token);

    ext= "com.apple.afc.root";
    token = sandbox_extension_issue_generic(ext, reserved, flags);
    printf("Issuing the following extension %s\n",token);
    //sandbox_extension_consume(token);

    ext= "com.apple.afc.root";
    token = sandbox_extension_issue_generic(ext, reserved, flags);
    printf("Issuing the following extension %s\n",token);
    //sandbox_extension_consume(token);

    ext= "com.apple.afc.root";
    result = sandbox_issue_extension(ext, &token);
    printf("Issuing the following extension %s\n",token);
    //sandbox_extension_consume(token);

    while(1)
    {}

  }
}
