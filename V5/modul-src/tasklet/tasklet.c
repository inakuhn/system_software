#include <linux/module.h>
#include <linux/version.h>
#include <linux/init.h>
#include <linux/interrupt.h>
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

static void tasklet_func( unsigned long data );
DECLARE_TASKLET( tl_descr, tasklet_func, 0L );

dev_t my_dev;
unsigned dev_count = 1;
char* name = "SilviIna\n";

struct file_operations my_fops = {
		.owner = THIS_MODULE
};
struct cdev my_cdev = {
		.owner = THIS_MODULE	
};
struct class *my_class;  
static int __init ModInit(void)
{
	int result;
	printk(KERN_INFO  "Hello, world\n");
	result = register_chrdev_region(my_dev,0, name);
	if(result < 0 ){
	  printk (KERN_WARNING "hello: can't get major number %d/n", my_dev);  
      return result;  

	}
	alloc_chrdev_region(&my_dev, 0, dev_count, name);
	cdev_init(&my_cdev, &my_fops);
	result = cdev_add(&my_cdev, my_dev, dev_count);
	if(result < 0){
		printk (KERN_NOTICE "Error %d adding char_reg_setup_cdev", result);
	}
	my_class = class_create(THIS_MODULE, name);
	if(IS_ERR(my_class))  
    {  
		printk("Err: failed in creating class./n");  
		return -1;  
    } 
	device_create(my_class, NULL, MKDEV(MAJOR(my_dev), 0),name,name);
	tasklet_schedule( &tl_descr ); // Tasklet sobald als möglich ausführen
	return 0;

}

static void tasklet_func( unsigned long data )
{
    printk("Tasklet called...\n");
}




static void __exit ModExit(void)
{
	printk(KERN_INFO  "Goodbye, cruel world\n");
	tasklet_kill( &tl_descr );
	cdev_del (&my_cdev);  
	device_destroy(my_class, MKDEV(my_dev, 0));         //delete device node under /dev  
	class_destroy(my_class);                            //delete class created by us  
	unregister_chrdev_region (my_dev, 1);  
	printk (KERN_INFO "char driver cleaned up\n"); 
}

module_init(ModInit);
module_exit(ModExit);
