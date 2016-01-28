#include <linux/workqueue.h>
#include <linux/module.h>
#include <linux/version.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/kdev_t.h>
#include <linux/device.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Silvia & Raina");
MODULE_ALIAS("Supertestmodul");
MODULE_DESCRIPTION("WQ Treiber");
MODULE_VERSION("1");
/*
 * CODE BEISPEIL AUS 
 * https://ezs.kr.hsnr.de//TreiberBuch/html/sec.sftirq.html#EX.KTIMER
 * 
 */
 
// Devices
dev_t my_dev;
char* DEV_NAME = "wq";

struct file_operations my_fops = {
		.owner = THIS_MODULE
};
struct cdev *my_cdev = NULL;
struct class *my_class;

static const int DEV_COUNT=1;

//Workqueue parameters
static struct workqueue_struct *wq = NULL;
static unsigned long delay = 2 * HZ;
static void work_queue_func(struct work_struct *pwork);
unsigned long jiff = 0;
static DECLARE_DELAYED_WORK(work_object, work_queue_func);   
unsigned long time_last_call = 0;
unsigned long min = ULONG_MAX;
unsigned long max = 0L;
unsigned long dauern = 0;
static void secure_queue_delayed_work(void)
{
	if(queue_delayed_work(wq, &work_object, delay)) {
		printk(KERN_INFO "Workqueue object will be processed soon...\n");
	} else {
		printk(KERN_INFO "Workqueue object could not be hooked into workqueue...\n");
	}
}

static void work_queue_func(struct work_struct *pwork)
{
	jiff = jiffies;
	if(!time_last_call)
	{	
		printk(KERN_INFO "DEFINE time_last_call: (%ld) \n", jiff);
		time_last_call = jiff;
	}
	else
	{
		dauern = jiff - time_last_call;
		min = min(dauern, min);
		max = max(dauern, max);
		time_last_call = jiff;
	}
	printk(KERN_INFO "work_queue_func %ld...\n", jiff);
	secure_queue_delayed_work();
	
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
static int __init drv_init(void)
{
	if(createDevice() < 0)
	{
		goto errorun;
	}
	if(createModule() < 0)
	{
		goto errorun;
	}
	wq = create_singlethread_workqueue("Workqueue");
	if(wq == NULL)
	{
		goto errorun;
	}
	secure_queue_delayed_work();
	return 0;


	errorun:
		printk (KERN_ERR "FAIL By init!/n");
		unregister_chrdev_region (my_dev, DEV_COUNT);
		return -EIO;
	
	}


static void __exit drv_exit(void)
{
	
	printk(KERN_INFO "MAX INTERVALL: %ld \n", max);
    printk(KERN_INFO "MIN INTERVALL: %ld \n", min);
  	if(cancel_delayed_work(&work_object))
  	{
		printk(KERN_INFO  "Futere works hass been canceld\n");
	}else{
		printk(KERN_INFO  "No working was pending\n");
	}
	destroy_workqueue(wq);
	printk(KERN_INFO  "Goodbye, cruel world\n");
	cdev_del (my_cdev);  
	device_destroy(my_class, my_dev);         //delete device node under /dev  
	class_destroy(my_class);                  //delete class created by us  
	printk (KERN_INFO "unregister caled\n");
	unregister_chrdev_region (my_dev, DEV_COUNT);
	printk (KERN_INFO "char driver cleaned up\n"); 
}

module_init( drv_init );
module_exit( drv_exit );
