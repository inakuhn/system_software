/*Systemsoftware V2 init Datei
 29.10.15 rabertol & sigoetti */
#include <stdio.h>
#include <sys/sysinfo.h>
#include <unistd.h>  
#include <sys/utsname.h>
#include <stdlib.h>


/*source: http://stackoverflow.com/questions/8987636/sysinfo-system-call-not-returning-correct-freeram-value
  and http://stackoverflow.com/questions/3596310/c-how-to-use-the-function-uname */

int main()
{

  struct sysinfo info;
  struct utsname unamed;

    if (sysinfo(&info) != 0|| uname(&unamed) != 0){
        printf("error reading system informations");
        exit(-1);
	}
	printf("\n");
	printf("Hello User world\n");
	printf("\n");

	printf("Kernel:  %s | %s  | %s\n", unamed.sysname, unamed.release, unamed.version);
	printf("Hostname: %s\n" , unamed.nodename);
	printf("Machine: %s\n", unamed.machine);

 	printf("\n");
 	
 	printf("Uptime: %ld:%ld:%ld\n", info.uptime/3600, info.uptime%3600/60, info.uptime%60);
    printf("Total RAM: %ld MB\n", info.totalram/1024/1024);
   	printf("Free RAM: %ld MB\n", (info.totalram-info.freeram)/1024/1024);
   	printf("Process count: %d\n",info.procs);
  	printf("Page size: %ld bytes\n", sysconf(_SC_PAGESIZE));
  
}
