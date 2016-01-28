#include <linux/module.h>
#include <linux/version.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/kdev_t.h>
#include <linux/device.h>
#include <linux/sched.h>
#include <linux/completion.h>
#include <linux/sched.h>
#include <linux/interrupt.h>
#include <linux/kthread.h>

//Source: http://lxr.free-electrons.com/source/include/linux/module.h
//https://ezs.kr.hsnr.de//TreiberBuch/html/sec.kernelthread01.html

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Silvia & Raina");
MODULE_VERSION("1");

dev_t my_dev;
static const int DEV_COUNT=1;
char* DEV_NAME = "kthread";

struct file_operations my_fops = {
        .owner = THIS_MODULE
};
struct cdev *my_cdev = NULL;
struct class *my_class;
static struct task_struct *thread_id;
static wait_queue_head_t wq;
static DECLARE_COMPLETION( on_exit );


static int thread_code( void *data )
{
    unsigned long timeout;

    allow_signal( SIGTERM );
    while(!kthread_should_stop())
    {
        timeout=2*HZ; // wait 2 seconds
        timeout=wait_event_interruptible_timeout(wq, (timeout==0), timeout);
        printk("thread_code: woke up ...\n");

        if( timeout==-ERESTARTSYS ) {
            printk("got signal, break\n");
            break;
        }
    }
    thread_id = 0;
    complete_and_exit( &on_exit, 0 );
}

static int createDevice(void)
{
	/*Alocciert platz für device*/
	if(alloc_chrdev_region(&my_dev,0, DEV_COUNT, DEV_NAME) < 0)
	{
		printk (KERN_ERR "Alloc device fehler\n");  
		return -EIO;  
	
	}
	printk (KERN_INFO "MAJOR NUMBER: %d\n", MAJOR(my_dev)); 
	my_cdev = cdev_alloc();

	if(my_cdev == NULL){
		printk (KERN_ERR "cdev alloc FAIL!/n");  
		
	}
	my_cdev->owner = THIS_MODULE;
	my_cdev->ops = &my_fops;
	printk (KERN_INFO "cdev alloc SUCCESSFUL\n");

	
	if(cdev_add(my_cdev, my_dev, DEV_COUNT)){
		printk (KERN_ERR "add device FAILD\n");
		my_cdev = NULL;
		return -EIO;
	}
	return 0;
	
} 
static int createModule(void)
{
	my_class = class_create(THIS_MODULE, DEV_NAME);
	if(IS_ERR(my_class))  
    {  
		printk("Err: failed in creating class\n");  
		return -1;  
    } 
	device_create(my_class, NULL, MKDEV(MAJOR(my_dev), 0),DEV_NAME,DEV_NAME);
	return 0;
}

static int __init ModInit(void)
{
	if(createDevice() < 0)
	{
		goto errorun;
	}
	if(createModule() < 0)
	{
		goto errorun;
	}

    //------------------thread stuff-----------
    init_waitqueue_head(&wq);
    thread_id=kthread_create(thread_code, NULL, "mykthread" );
    if( thread_id==0 )
    {
        goto errorun;
    }
    wake_up_process(thread_id);
    //-------------------------------------------------------


    return 0;
    errorun:
	printk (KERN_ERR "FAIL By init!/n");
	unregister_chrdev_region (my_dev, DEV_COUNT);
	return -EIO;

}

static void __exit ModExit(void)
{//-----thread stuff----------------------
   
    kill_pid(task_pid( thread_id), SIGTERM, 1 );    
    wait_for_completion( &on_exit );
//------------------------------------------------
	printk(KERN_INFO  "Goodbye, cruel world\n");
	cdev_del (my_cdev);  
	device_destroy(my_class, my_dev);         //delete device node under /dev  
	class_destroy(my_class);                  //delete class created by us  
	printk (KERN_INFO "unregister caled\n");
	unregister_chrdev_region (my_dev, DEV_COUNT);
	printk (KERN_INFO "char driver cleaned up\n"); 

}

module_init(ModInit);
module_exit(ModExit);
