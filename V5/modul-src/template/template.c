#include <linux/module.h>
#include <linux/version.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/kdev_t.h>
#include <linux/device.h>
//Source: http://lxr.free-electrons.com/source/include/linux/module.h

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Silvia & Raina");
MODULE_ALIAS("Supertestmodul");
MODULE_DESCRIPTION("Das hier ist zum testen wie das mit dem Treiber laden und entladen geht");
MODULE_VERSION("1");

dev_t my_dev;
unsigned dev_count = 1;
char* DEV_NAME = "template";

struct file_operations my_fops = {
		.owner = THIS_MODULE
};
struct cdev *my_cdev = NULL;
struct class *my_class;

static const int DEV_COUNT=1;

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
	return 0;

}

static void __exit ModExit(void)
{
	printk(KERN_INFO  "Goodbye, cruel world\n");
	cdev_del (my_cdev);  
	device_destroy(my_class, MKDEV(my_dev, 0));         //delete device node under /dev  
	class_destroy(my_class);                            //delete class created by us  
	printk (KERN_INFO "unregister caled\n");
	unregister_chrdev_region (my_dev, 1);
	printk (KERN_INFO "char driver cleaned up\n"); 
}



module_init(ModInit);
module_exit(ModExit);
