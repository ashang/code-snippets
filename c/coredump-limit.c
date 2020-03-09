#include <stdlib.h>
#include <sys/resource.h>

int main(int argc, char **argv)
{
    // Get the hard and soft limit from command line
    struct rlimit new = {atoi(argv[1]), atoi(argv[1])};

    // Create some memory so as to beef up the core file size
    void *p = malloc(10 * 1024 * 1024);

    if (!p)
        return 1;

    if (setrlimit(RLIMIT_CORE, &new)) // Set the hard and soft limit
        return 2;                     // for core files produced by this
                                      // process

    while (1);

    free(p);
    return 0;
}
