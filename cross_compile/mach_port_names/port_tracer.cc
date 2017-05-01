// Mach Port Tracer
// Copyright 2012 Google Inc. All rights reserved.
// Author: Robert Sesek (rsesek@google.com)

#include <errno.h>
#include <mach/mach.h>
#include <stdlib.h>
#include <sys/sysctl.h>

#include <iostream>
#include <map>
#include <vector>

class Process;

struct Port {
  Port(const Process* proc_, mach_vm_address_t addr)
      : proc(proc_),
        address(addr) {}
  const Process* proc;
  mach_vm_address_t address;

  bool operator<(const Port& right) const {
    return address < right.address;
  }

  bool operator==(const Port& right) const {
    return address == right.address;
  }
};

class Process {
 public:
  explicit Process(pid_t pid, const char* command)
      : pid_(pid),
        command_(command) {
  }

  bool ReloadPorts(bool read_only) {
    // MachPortExposer is in debug.crmachport, so the final mib length with the
    // last two components (pid, rights fitler) attached is length 4.
    const size_t mib_length = 4;
    int mib[mib_length];
    size_t len = mib_length;

    if (sysctlnametomib("debug.crmachport", mib, &len) < 0) {
      std::cerr << "sysctlnametomib error " << errno << std::endl;
      return false;
    }

    mib[2] = pid_;
    mib[3] = read_only ? MACH_PORT_TYPE_RECEIVE|MACH_PORT_TYPE_DEAD_NAME|MACH_PORT_TYPE_PORT_SET : ~0;

    // Get the length of the buffer that needs to be allocated.
    size_t length = 0;
    if (sysctl(mib, mib_length, NULL, &length, NULL, 0) < 0) {
      std::cerr << "ReloadPorts sysctl length error " << errno << std::endl;
      return false;
    }

    // sysctl again to fill the buffer.
    std::vector<vm_address_t> ports(length);
    if (sysctl(mib, mib_length, &ports[0], &length, NULL, 0) < 0) {
      std::cerr << "ReloadPorts sysctl buffer error " << errno << std::endl;
      return false;
    }

    // Remove zeros from unallocated ports. The KEXT could do it for us, but
    // the author is an idiot and didn't.
    for (std::vector<vm_address_t>::iterator it = ports.begin();
         it != ports.end();
         ++it) {
      if (*it != 0) {
        kernel_ports_.push_back(Port(this, *it));
      }
    }

    return true;
  }

  pid_t pid() const { return pid_; }
  const std::string& command() const { return command_; }
  const std::vector<Port>& kernel_ports() const {
    return kernel_ports_;
  }

 private:
  pid_t pid_;
  std::string command_;
  std::vector<Port> kernel_ports_;
};

std::ostream& operator<<(std::ostream& out, Port port) {
  out << "Port<" << port.proc->pid() << "," << port.proc->command()
      << "," << port.address << ">";
  return out;
}

bool GetRunningProcesses(std::vector<Process>* out_pids) {
  const size_t mib_size = 3;
  int mib[mib_size] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL };

  // Get the size of the buffer.
  size_t kinfo_procs_size;
  if (sysctl(mib, mib_size, NULL, &kinfo_procs_size, NULL, 0) < 0) {
    std::cerr << "Error getting proc list size: " << errno;
    return false;
  }

  std::vector<kinfo_proc> kinfo_procs(kinfo_procs_size / sizeof(kinfo_proc));
  if (sysctl(mib, mib_size, &kinfo_procs[0], &kinfo_procs_size, NULL, 0) < 0) {
    std::cerr << "Error getting proc list: " << errno;
    return false;
  }

  out_pids->clear();
  for (std::vector<kinfo_proc>::iterator it = kinfo_procs.begin();
       it != kinfo_procs.end(); ++it) {
    pid_t pid = it->kp_proc.p_pid;
    if (pid > 0) {
      out_pids->push_back(Process(it->kp_proc.p_pid, it->kp_proc.p_comm));
    }
  }

  return true;
}

// Finds all the ports that |proc| has in common with the set of ports |ports|,
// putting any common ones from |proc| into |out_ports|. |ports| must be
// sorted.
bool GetCommonPorts(Process* proc,
                    const std::vector<Port>& ports,
                    std::vector<Port>* out_ports) {
  if (!proc->ReloadPorts(true))
    return false;

  std::vector<Port> proc_ports(proc->kernel_ports());
  std::sort(proc_ports.begin(), proc_ports.end());

  std::set_intersection(proc_ports.begin(), proc_ports.end(),
                        ports.begin(), ports.end(),
                        std::back_inserter(*out_ports));

  return true;
}

int main(int argc, char** argv) {
  if (argc != 2) {
    std::cerr << "Usage: port_tracer [target_pid]" << std::endl;
    return 1;
  }

  int target_pid = atoi(argv[1]);

  std::vector<Process> procs;
  if (!GetRunningProcesses(&procs))
    return 2;

  Process target(target_pid, "** TARGET **");
  if (!target.ReloadPorts(false))
    std::cerr << "Error getting port list for target process" << std::endl;

  std::cerr << "Target ports = " << target.kernel_ports().size() << std::endl;

  // Get the sorted list of kernel addresses for the target's ports.
  std::vector<Port> sorted_target_ports(target.kernel_ports());
  std::sort(sorted_target_ports.begin(), sorted_target_ports.end());

  // Find any addresses any other process has in common with the target.
  std::vector<Port> common_ports;

  for (std::vector<Process>::iterator it = procs.begin();
       it != procs.end(); ++it) {
    if (it->pid() == target.pid())
      continue;

    GetCommonPorts(&(*it), sorted_target_ports, &common_ports);
  }

  // Print.
  for (std::vector<Port>::const_iterator it = common_ports.begin();
       it != common_ports.end(); ++it) {
    std::cout << *it << std::endl;
  }
}
