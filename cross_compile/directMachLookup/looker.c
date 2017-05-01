#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <mach/mach.h>
#include <mach/bootstrap.h>
int main(int argc, char* argv[])
{
kern_return_t kr;
mach_port_t foo_port;
kr = bootstrap_look_up(bootstrap_port, "com.apple.mobile.obliteration", &foo_port);
if (kr != KERN_SUCCESS) {
errx(EXIT_FAILURE, "bootstrap_look_up: %s", bootstrap_strerror(kr));
}

return EXIT_SUCCESS;
}
