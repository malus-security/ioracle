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

    printf("Currently in the com.apple.tccd sandbox\n");

    printf("Now trying to read /private/var/mobile/sandbox_extension_tests/protected_file.txt\n");
    int c;
    FILE *file;
    const char *secret_file_path = "/private/var/mobile/sandbox_extension_tests/protected_file.txt";

    file = fopen(secret_file_path, "r");
    if (file)
    {
      while ((c = getc(file)) != EOF)
      {
	putchar(c);
      }
      fclose(file);
      printf("\n");
    }

    //try to do extension stuff
    char *token;
    token = NULL;
    //const char *ext= "com.apple.tcc.kTCCServiceAddressBook";
    //const char *ext= "com.apple.tcc.kTCCServicekTCCServicePhotos";
    //const char *ext= "com.apple.quicklook.readonly";
    const char *ext= "com.apple.mediaserverd.read";
    //const char *ext= "com.apple.afc.root";
    //const char *path= "/shouldFail/";
    const char *path= "/";
    //int reserved = 0;
    int reserved = 0;
    int flags = 0;
    int result = 0;
    //this seems to work for generating the extension
    token = sandbox_extension_issue_file(ext, path, reserved, flags);
    printf("Issuing the following extension %s\n",token);
    
    result = 0;
    result = sandbox_extension_consume(token);
    printf("result of consuming extension = %d\n",result);

    printf("Now trying to read /private/var/mobile/sandbox_extension_tests/protected_file.txt\n");
    file = fopen(secret_file_path, "r");
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
