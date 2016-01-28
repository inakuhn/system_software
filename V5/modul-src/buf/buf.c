#include <linux/module.h>
#include <linux/version.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/kdev_t.h>
#include <linux/device.h>
#include <linux/sched.h>
#include <linux/uaccess.h>
#include <stdarg.h>
#include <linux/kfifo.h>
#include <linux/gfp.h>
#include <linux/slab.h>
#include <linux/string.h>
//Source: http://lxr.free-electrons.com/source/include/linux/module.h

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Silvia & Raina");
MODULE_ALIAS("Supertestmodul");
MODULE_DESCRIPTION("Das hier ist zum testen wie das mit dem Treiber laden und entladen geht");
MODULE_VERSION("1");



static struct kfifo fifo;
 /* fifo size in elements (bytes) muss be power of 8*/
#define FIFO_SIZE 8
  /* name of the proc entry */
#define PROC_FIFO "bytestream-fifo"

#define WRITE_POSSIBLE (!kfifo_is_full(&fifo))
#define READ_POSSIBLE (!kfifo_is_empty(&fifo))

dev_t my_dev;
unsigned dev_count = 1;
char* DEV_NAME = "buf";


static int driver_open(struct inode *deviceFile, struct file *instance);
static int driver_release(struct inode *deviceFile, struct file *instance);
static ssize_t driver_read( struct file *instanz, char *user, size_t max_bytes_to_read, loff_t *offset );
static ssize_t driver_write( struct file *instanz, const char __user *userbuffer, size_t max_bytes_to_write,loff_t *offs);

struct file_operations my_fops = {
        .owner = THIS_MODULE,
        .open = driver_open,
        .read = driver_read,
        .write = driver_write,
        .release = driver_release
};
struct cdev *my_cdev = NULL;
struct class *my_class;

static const int DEV_COUNT=1;

static wait_queue_head_t wait_queue_for_read, wait_queue_for_write;

static ssize_t driver_read( struct file *instanz, char *user, size_t max_bytes_to_read, loff_t *offset ){
	unsigned char buf[max_bytes_to_read];  
	unsigned char   i;
	printk(KERN_INFO  "hello from driver_read\n");
	if (!READ_POSSIBLE && ( instanz->f_flags & O_NONBLOCK)){
		printk(KERN_INFO  "Oh no somehting went worng!!! i will free fifo!!\n");
		kfifo_free(&fifo);
		return -EAGAIN;
		}

	if(wait_event_interruptible(wait_queue_for_read,READ_POSSIBLE)){
		return -ERESTARTSYS;
	}
	
	printk(KERN_INFO  "Reading... \n");
	while(READ_POSSIBLE){
		 i = kfifo_get(&fifo, buf);
		 printk(KERN_INFO "buf: %.*s\n", i, buf);
	}
	printk(KERN_INFO "\n Finish read!!\n");
	printk(KERN_INFO  "Read: %d \n", i);
	printk(KERN_INFO  "To be read: %d \n",kfifo_len(&fifo));
	wake_up_interruptible(&wait_queue_for_write);
	return i;
}

static ssize_t driver_write( struct file *instanz, const char __user *userbuffer, size_t max_bytes_to_write,loff_t *offs){
	size_t copied = 0;
	int loop= 0; 
	 printk(KERN_INFO  "driver_open called writing ... \n");
	if (!WRITE_POSSIBLE && ( instanz->f_flags & O_NONBLOCK)){
		return -EAGAIN;
		}
	
	if(wait_event_interruptible(wait_queue_for_read,WRITE_POSSIBLE)){
		return -ERESTARTSYS;
	}
	
	printk(KERN_INFO  "user want to write:  %d ... \n",max_bytes_to_write );
	printk(KERN_INFO  "Free place in my buf: %d ... \n",kfifo_avail(&fifo));
	printk(KERN_INFO  "Word to be write: %s", userbuffer);
	//bytes to copy
	for(loop = 0; loop < max_bytes_to_write; loop++){
		if(WRITE_POSSIBLE){
			kfifo_put(&fifo,(char) userbuffer[loop]);
			printk(KERN_INFO  "Wrote: %c\n",(char) userbuffer[loop]);
			copied++;
		}else{
			printk(KERN_INFO "can not read anymore \n");
			break;
		}
	}
	printk(KERN_INFO  "Waking up Reader;!!!\n");
	printk(KERN_INFO  "Ferienabend! copied\t: %d \n",copied);
	printk(KERN_INFO  "loop\t: %d \n",loop);
	printk(KERN_INFO  "Should be copy\t: %d \n",max_bytes_to_write);
	wake_up_interruptible(&wait_queue_for_read);
	return copied;
	}

static int driver_open(struct inode *deviceFile, struct file *instanz) {
  printk(KERN_INFO  "driver_open called \n");	
  return 0;
}
static int driver_release(struct inode *deviceFile, struct file *instanz) {
 printk(KERN_INFO  "driver_release called \n");
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
	printk (KERN_INFO "MAJOR NUMBER: %d/n", MAJOR(my_dev)); 
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
		printk("Err: failed in creating class./n");  
		return -1;  
    } 
	device_create(my_class, NULL, MKDEV(MAJOR(my_dev), 0),DEV_NAME,DEV_NAME);
	return 0;
}
static int __init ModInit(void)
{
	if(createDevice() < 0)
	{
		unregister_chrdev_region (my_dev, 1);
		return -EIO;
	}
	if(createModule() < 0)
	{
		unregister_chrdev_region (my_dev, 1);
		return -EIO;
	}	
	init_waitqueue_head( &wait_queue_for_read );          
    init_waitqueue_head( &wait_queue_for_write );
    INIT_KFIFO(fifo);
    kfifo_alloc(&fifo, FIFO_SIZE, GFP_KERNEL);
	return 0;

}

static void __exit ModExit(void)
{
	printk(KERN_INFO  "Goodbye, cruel world\n");
	cdev_del (my_cdev);  
	device_destroy(my_class, my_dev);         //delete device node under /dev  
	class_destroy(my_class);                  //delete class created by us  
	printk (KERN_INFO "unregister caled\n");
	unregister_chrdev_region (my_dev, DEV_COUNT);
	printk (KERN_INFO "char driver cleaned up\n"); 
	kfifo_free(&fifo);
}

module_init(ModInit);
module_exit(ModExit);
