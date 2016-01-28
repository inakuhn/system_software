#include <linux/version.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/delay.h>
#include <linux/semaphore.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Silvia & Raina");
MODULE_ALIAS("Supertestmodul");
MODULE_DESCRIPTION("Lock Treiber");
MODULE_VERSION("1");
/*
 * CODE BEISPEIL AUS 
 * https://ezs.kr.hsnr.de//TreiberBuch/html/
 * Timi repo & phillip Daniels aufgaben
 * 
 */
 
// Devices
dev_t my_dev;
unsigned dev_count = 1;
char* DEV_NAME = "lock";
// File operations
static int driver_open(struct inode *deviceFile, struct file *instance);
static int driver_close(struct inode *deviceFile, struct file *instance);
static ssize_t driver_read(struct file *instance, char __user *user, size_t count, loff_t *offset);
struct file_operations my_fops = {
	.owner = THIS_MODULE,
	.open = driver_open,
	.release = driver_close,
	.read = driver_read
};
struct cdev *my_cdev = NULL;
struct class *my_class;

static const int DEV_COUNT=1;


static struct semaphore sem;



static int driver_open(struct inode *deviceFile, struct file *instance) {
  printk (KERN_INFO "Driver-open called\n");
  while (true) {
    if(down_trylock(&sem)==0) {
     printk (KERN_INFO "Enter critical area\n");
      msleep(3000);
      up(&sem);
      printk (KERN_INFO "Leave critical area\n");
      break;
    } else {
      printk (KERN_INFO "Waiting for critical area...\n");
      msleep(200);
    }
  }
	return 0;
}

static int driver_close(struct inode *deviceFile, struct file *instance) {
 printk (KERN_INFO "Driver-closed called\n");
  return 0;
}

static ssize_t driver_read(struct file *instance, char __user *user, size_t count, loff_t *offset) {
  printk (KERN_INFO "Driver-read called\n");
  return 0;

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
	
	sema_init(&sem, 1);
	return 0;


	errorun:
		printk (KERN_ERR "FAIL By init!\n");
		unregister_chrdev_region (my_dev, DEV_COUNT);
		return -EIO;
	
	}


static void __exit drv_exit(void)
{
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
