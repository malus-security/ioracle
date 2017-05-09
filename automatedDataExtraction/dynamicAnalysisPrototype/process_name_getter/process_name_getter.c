#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/ioctl.h>     // for _IOW, a macro required by FSEVENTS_CLONE
#include <sys/types.h>     // for uint32_t and friends, on which fsevents.h relies
#include <unistd.h>
#include <string.h> // memset
//#include <sys/_types.h>     // for uint32_t and friends, on which fsevents.h relies
#include <sys/stat.h> // for mkdir
#include <libgen.h> // for basename
#include <sys/sysctl.h> // for sysctl, KERN_PROC, etc.
#include <errno.h>
//#include <sys/fsevents.h>
//#include "fsevents.h"
//#include "colors.h" 
#include <signal.h> // for kill
#include <libproc.h>

int
main (int argc, char **argv)
{
/*
  int pid = 1;
  static char procName[4096];
  size_t len = 1000;
  int rc;
  int mib[4];

  memset(procName, '\0', 4096);

  mib[0] = CTL_KERN;
  mib[1] = KERN_PROC;
  mib[2] = KERN_PROC_PID;
  mib[3] = pid;

  if ((rc = sysctl(mib, 4, procName, &len, NULL,0)) < 0)
  {
    perror("trace facility failure, KERN_PROC_PID\n");
    exit(1);
  }

  char *name = (((struct kinfo_proc *)procName)->kp_proc.p_comm);
  printf("%s\n",name);
  printf("%s\n",procName);
*/

  int ret;
  pid_t pid; 
  char pathbuf[PROC_PIDPATHINFO_MAXSIZE];

  //pid = getpid();
  pid = 1;
  ret = proc_pidpath (pid, pathbuf, sizeof(pathbuf));
  if ( ret <= 0 ) {
    fprintf(stderr, "PID %d: proc_pidpath ();\n", pid);
    fprintf(stderr, "    %s\n", strerror(errno));
  } else {
    printf("proc %d: %s\n", pid, pathbuf);
  }

  return 0;
}
