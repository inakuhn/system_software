#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <getopt.h>

int readtime= 0;
int opentime= 0;
int sleeptime= 0;
void help ();
void mynull() ;
void myzero();
void openclose();
void tasklet();
void kthread();
void buf();
void work_queue();


//With the help of group 15

int main(int argc, char *argv[]){
    int c;
    while ((c = getopt(argc, argv, ":horwt:d:abkq:")) != -1) {
        switch(c) {
            case 'h':
                printf (" Aufruf: ./access [-h] [-o] [-w] [-r] [-t] [-d] [-a] [-b] [-q]");
                return EXIT_SUCCESS;
            case 'o':
                openclose();
                break;
            case 'r':
                myzero();
                break;
            case 'w':
                mynull();
                break;
            case 't':
                opentime = atoi(optarg);
                break;
            case 'd':
                readtime = atoi(optarg);
                break;
            case 'a' :
				tasklet();
				break;
			case 'k':
				kthread();
				break;
			case 'b':
				buf();
				break;
			case 'q':
				sleeptime = atoi(optarg);
				work_queue();
				break;
            case '?':
                printf("Unrecognized option: -%c\n", optopt);
                break;
        }
    }
	printf ("Finished all test...\n");
    return 0;

}


void openclose() {
    int fd1, fd2, fd3;

    printf("open test...\n");

    printf("Open first \n");
    fd1 = open("/dev/openclose", O_RDONLY);
    if (fd1 < 0) {
        printf("failed\n");
    } else {
        printf("succeed\n");
    }

    printf("Open second \n");
    fd2 = open("/dev/openclose", O_RDONLY);
    if (fd2 < 0) {
        printf("failed\n");
    } else {
        printf("succeed\n");
    }

    if (fd1 >= 0) {
        printf("close first\n");
        close(fd1);
    }

    if (fd2 >= 0) {
        printf("close second\n");
        close(fd2);
    }

    printf("Open first again \n");
    fd3 = open("/dev/openclose", O_RDONLY);
    if (fd3 < 0) {
        printf("failed\n");
    } else {
        printf("succeed\n");
    }

    if (fd3 >= 0) {
        printf("close first\n");
        close(fd3);
    }

    printf("Finished open test...\n");
}

void myzero() {
    int i;
    int fd;
    char string[20];;

    fd = open("/dev/myzero", O_RDONLY);
    if (fd < 0) {
        printf(" open failed\n");
        return;
    } else {
        printf("open succeed\n");
    }

    printf("start reading\n");
    for(i = 0; i < 5; i++) {
        read(fd, &string, 20);
        printf("%s", string);
        usleep(readtime * 1000);
    }
    printf("\n");
    printf("end reading\n");

    close(fd);

}

void mynull() {
    int i;
    int fd;
    char string[] = "Hello World\n";

    fd = open("/dev/mynull", O_WRONLY);
    if (fd < 0) {
        printf("open failed\n");
        return;
    } else {
        printf("open succeed\n");
    }

    printf("start writing\n");
    for(i = 0; i < 5; i++) {
        if (write(fd, &string, 20) == 20) {
            printf("writing succeed\n");
        } else {
            printf("writing failed\n");
        }
        printf("%s", string);
        usleep(readtime * 1000);
    }
    printf("end writing\n");
    close(fd);
}
void tasklet(){
	

}

void kthread(){
	
}
void work_queue()
{
    int fd1;

    fd1 = open("/dev/wq", O_RDONLY);
    if (fd1 < 0) {
        printf(" open failed: %d\n", fd1);
        return;
    } else {
        printf("open succeed\n");
    }

	if(sleeptime > 0)
	{
		printf("Sleep %d\n",sleeptime);
		sleep(sleeptime);
		
	}
	
	
    if(close(fd1)){
		printf(" close failed: %d\n", fd1);
        return;
    } else {
        printf("close succed\n");
    }
    
 
    
    
}
void buf(){
	
    int fd;
    char string[] = "Hello World\n";
    
    //open device
    fd = open("/dev/buf", O_WRONLY);
    if (fd < 0) {
        printf("open failed\n");
        return;
    } else {
        printf("open succeed\n");
    }
    
    //write into buffer
     printf("start writing\n");
    
	if (write(fd, &string, 20) == 20) {
		printf("writing succeed\n");
	} else {
		printf("writing failed\n");
	}
    printf("%s", string);
    usleep(1000);
    
    printf("end writing\n");
    
    //read from buffer
    printf("start reading\n");
  
    read(fd, &string, 20);
    printf("%s\n", string);
    usleep( 1000);
   
    printf("end reading\n");
    
    //close device
    close(fd);
}

