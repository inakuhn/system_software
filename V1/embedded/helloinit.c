//Systemsoftware V1 init Datei
//27.10.15 rabertol & sigoetti
#include <stdio.h>
#include <sys/sysinfo.h>
#include <unistd.h>  

//source: http://stackoverflow.com/questions/8987636/sysinfo-system-call-not-returning-correct-freeram-value

int main()
{

  struct sysinfo info;

    if (sysinfo(&info) != 0){
        error("sysinfo: error reading system statistics");
	}

  	printf("Hello User world\n");
 	printf("Uptime: %ld:%ld:%ld\n", info.uptime/3600, info.uptime%3600/60, info.uptime%60);
    printf("Total RAM: %ld MB\n", info.totalram/1024/1024);
   	printf("Free RAM: %ld MB\n", (info.totalram-info.freeram)/1024/1024);
   	printf("Process count: %d\n",info.procs);
  	printf("Page size: %ld bytes\n", sysconf(_SC_PAGESIZE));
  
}
