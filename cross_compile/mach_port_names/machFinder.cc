#include <mach/task.h>
#include <mach/mach_traps.h>
#include <mach/mach_init.h>
#include <mach/mach_types.h>
#include <mach/kern_return.h>
#include <mach/port.h>
#include <mach/message.h>
#include <mach/std_types.h>
#include <mach/vm_prot.h>
#include <mach/mach_port.h>
#include <mach/mach_error.h>
#include <mach/mig_errors.h>
#include <mach/mach_interface.h>
#include <mach/mach_host.h>
#include <mach/thread_switch.h>
#include <mach/rpc.h>
#include <mach/mig.h>
#include <sys/cdefs.h>
#include <stdio.h>
#include <stdlib.h>

#include <errno.h>
#include <mach/mach.h>
#include <sys/sysctl.h>

#include <iostream>
#include <map>
#include <vector>

int main(int argc, char *argv[]) 
{
int 			i;
pid_t 			pid;
kern_return_t		kr;
mach_port_name_array_t	names;
mach_port_type_array_t	types;
mach_msg_type_number_t	ncount, tcount;
mach_port_limits_t	port_limits;
mach_port_status_t 	port_status;
mach_msg_type_number_t 	port_info_count;
task_t			task;
task_t			mytask;

mytask = mach_task_self();

if (argc != 2)
{
  fprintf(stderr, "Expects one argument\n");
  exit(1);
}

pid = atoi(argv[1]);
kr = task_for_pid(mytask, (int)pid, &task);
//there was supposed to be some error code here

kr = mach_port_names(task, &names, &ncount, &types, &tcount);
//EXIT_ON_MACH_ERROR("mach_port_names", kr);

printf("%8s %8s %8s %8s %8s task rights\n",
  "name", "q-limit", "seqno", "msgcount", "sorights");

printf("ncount = %d\n",ncount);

for (i = 0; i < ncount; i++)
{
  printf("%08x ", names[i]);
}

return 0;
}
