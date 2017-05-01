#include <stdio.h>
#include <sandbox.h>
#include <unistd.h>
#include <stdlib.h>

extern int sandbox_extension_consume(const char *token);
extern char *sandbox_extension_issue_file(const char *ext, const char *path, int reserved, int flags);

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

    printf("Currently in the afcd sandbox\n");
    printf("Now trying to read /private/var/mobile/sandbox_extension_tests/protected_file.txt\n");
    int c;
    FILE *file;
    file = fopen("/private/var/mobile/sandbox_extension_tests/protected_file.txt", "r");
    if (file) 
    {
      while ((c = getc(file)) != EOF)
      {
	      putchar(c);
      }
      fclose(file);
      printf("\n");
    }

    printf("If nothing appeared then the read was blocked by the sandbox\n");

    //try to do extension stuff
    char *token;
    char *token2;
    token = NULL;
    //const char *ext= "com.apple.afc.root";
    const char *ext= "com.apple.quicklook.readonly";
    //const char *ext= "com.SHOULDFAIL.apple.afc.root";
    //const char *path= "/shouldFail/";
    const char *path= "/";
    int reserved = 0;
    int flags = 0;
    int result = 0;
    //this seems to work for generating the extension
    //TODO try granting an extension of a different class type
    token = sandbox_extension_issue_file(ext, path, reserved, flags);
    printf("Issuing the following extension %s\n",token);

    token2 = sandbox_extension_issue_file(ext, path, reserved, flags);
    printf("Issuing another extension with same parameters %s\n",token2);

    //try to consume the extension and see if it provides more privileges

    printf("Consuming the extension I just issued...\n",token);
    result = sandbox_extension_consume(token);
  
    //const char *forgedToken = "7d003964183d3bf8275bc11abe1959cf174c79d1;00000000;00000000;00000012;com.apple.afc.root;00000001;01000002;0000000000000002;/";
    //printf("Consuming a forged token copied from previous run...\n",forgedToken);
    //result = sandbox_extension_consume(forgedToken);

    printf("%d\n",result);

    printf("Now trying to read /private/var/mobile/sandbox_extension_tests/protected_file.txt\n");
    file = fopen("/private/var/mobile/sandbox_extension_tests/protected_file.txt", "r");
    if (file) 
    {
      while ((c = getc(file)) != EOF)
      {
	      putchar(c);
      }
      fclose(file);
      printf("\n");
    }
  }

    return 0;
}
