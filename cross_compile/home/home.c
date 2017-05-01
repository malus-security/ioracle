#include <stdio.h>
#include <sandbox.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <pwd.h>

extern int sandbox_extension_consume(const char *token);
extern char *sandbox_extension_issue_file(const char *ext, const char *path, int reserved, int flags);

int main(int argc, char *argv[]) {
  int rv;
  char *errbuff;

  //rv = sandbox_init(kSBXProfileNoInternet, SANDBOX_NAMED_BUILTIN, &errbuff);

  putenv("HOME=/var/mobile/restricted_home");
  char *home = getenv("HOME");
  printf("HOME = %s\n",home);

  struct passwd *pw = getpwuid(getuid());
  const char *homedir = pw->pw_dir;
  printf("homedir = %s\n",homedir);



  rv = sandbox_init(argv[1], SANDBOX_NAMED, &errbuff);

  if (rv != 0) 
  {
    fprintf(stderr, "sandbox_init failed: %s\n", errbuff);
    sandbox_free_error(errbuff);
  } 
  else 
  {
    //putenv("PS1=[LUKESANDBOXED] \\h:\\w \\u\\$ ");
    printf("pid: %d\n", getpid());

    printf("Currently in the sandbox\n");

    home = getenv("HOME");
    printf("HOME = %s\n",home);

    //putenv("HOME=/var/mobile/unrestricted_home");
    home = getenv("HOME");
    printf("HOME = %s\n",home);

    int c;
    FILE *file;
    const char *secret_file_path = "/private/var/mobile/luke_secret.txt";

    printf("Trying to read the file before consuming extension...\n");
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
    //const char *ext= "class_should_not_matter";
    //const char *path= "/var/mobile";
    const char *ext= "com.apple.quicklook.readonly";
    //const char *path= "/";
    //const char *ext= "com.apple.app-sandbox.read-write";
    //const char *path= "/private/var/mobile/Library/Caches/com.apple.AdSheetPhone/test/..";
    const char *path= "/";
    //const char *path= "/private/var/tmp/";
    //const char *path= "/private/var/mobile/";
    //const char *path= "/private/var/mobile/Library/Caches/com.apple.AdSheetPhone/";
    int reserved = 0;
    int flags = 0;
    //this seems to work for generating the extension
    token = sandbox_extension_issue_file(ext, path, reserved, flags);
    printf("Issuing the following extension %s\n",token);
    int result = 0;
    result = sandbox_extension_consume(token);
    printf("%d\n",result);

    printf("Trying to read the file after consuming extension...\n");
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
