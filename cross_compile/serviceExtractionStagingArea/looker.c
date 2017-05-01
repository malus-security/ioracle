#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <mach/mach.h>
#include <mach/bootstrap.h>
int main(int argc, char* argv[])
{
  kern_return_t kr;
  mach_port_t foo_port;

  //open and read the file containing list of mach services
  char const* const fileName = argv[1]; /* should check that argc > 1 */
  FILE* file = fopen(fileName, "r"); /* should check the result */
  char line[256];

  while (fgets(line, sizeof(line), file)) 
  {
    //need a way to skip empty lines and strip \n
    line[strcspn(line, "\n")] = 0;
    if (strlen(line) == 0)
    {
      //printf("EMPTY STRING DETECTED\n\n");
      continue;
    }

    kr = bootstrap_look_up(bootstrap_port, line, &foo_port);

    if (kr != KERN_SUCCESS) 
    {
      printf("%s~ failed because %s\n",line,bootstrap_strerror(kr));
      //errx(EXIT_FAILURE, "bootstrap_look_up: %s", bootstrap_strerror(kr));
      //break;
    }
    else
    {
      printf("%s~ succeeded\n",line);
      //break;
    }
  }

  fclose(file);

  return EXIT_SUCCESS;
}
