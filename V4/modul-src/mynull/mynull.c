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
char* name = "mynull";


static ssize_t driver_write( struct file *instanz, const char __user *userbuffer, size_t count,loff_t *offs);

static int driver_release(struct inode *geraetedatei, struct file *instanz);
static int driver_open(struct inode *geraetedatei, struct file *instanz);

struct file_operations my_fops = {
        .owner = THIS_MODULE,
        .open = driver_open,
        .write = driver_write,
        .release = driver_release
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
    printk(KERN_INFO  "calling alloc\n");
    alloc_chrdev_region(&my_dev, 0, dev_count, name);
    printk(KERN_INFO  "calling cdev_init\n");
    cdev_init(&my_cdev, &my_fops);
    printk(KERN_INFO  "calling cdev_add\n");
    result = cdev_add(&my_cdev, my_dev, dev_count);
    if(result < 0){
        printk (KERN_NOTICE "Error %d adding char_reg_setup_cdev", result);
    }
    printk(KERN_INFO  "initialization my class\n");
    my_class = class_create(THIS_MODULE, name);
    if(IS_ERR(my_class))
    {
        printk("Err: failed in creating class./n");
        return -1;
    }
    printk(KERN_INFO  "calling create device");
    device_create(my_class, NULL, MKDEV(MAJOR(my_dev), 0),name,name);
    printk(KERN_INFO  "pass all functions\n");
    return 0;

}
static int driver_open(struct inode *geraetedatei, struct file *instanz)
{   printk(KERN_INFO  "driver_open called \n");
    return 0;
}

static int driver_release(struct inode *geraetedatei, struct file *instanz)
{   printk(KERN_INFO  "driver_release called \n");
    return 0;
}

static ssize_t driver_write( struct file *instanz, const char __user *userbuffer, size_t count, loff_t *offs) {
    printk(KERN_INFO  "driver_write called \n");
    return count;
}
static void __exit ModExit(void)
{
    printk(KERN_INFO  "Goodbye, cruel world\n");
    cdev_del (&my_cdev);
    device_destroy(my_class, MKDEV(my_dev, 0));         //delete device node under /dev
    class_destroy(my_class);                            //delete class created by us
    unregister_chrdev_region (my_dev, 1);
    printk (KERN_INFO "char driver cleaned up\n");


}

module_init(ModInit);
module_exit(ModExit);
