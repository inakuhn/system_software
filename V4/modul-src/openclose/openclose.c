#include <linux/module.h>
#include <linux/version.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <asm/atomic.h>
#include <linux/kdev_t.h>
#include <linux/device.h>

//Source: http://lxr.free-electrons.com/source/include/linux/module.h
//Atimic: http://www.makelinux.net/books/lkd2/ch09lev1sec1

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Silvia & Raina");
MODULE_ALIAS("Supertestmodul");
MODULE_DESCRIPTION("Das hier ist zum testen wie das mit dem Treiber laden und entladen geht");
MODULE_VERSION("1");

static int driver_release(struct inode *geraetedatei, struct file *instanz);
static int driver_open(struct inode *geraetedatei, struct file *instanz);
static atomic_t atomic = ATOMIC_INIT(0);


dev_t my_dev;
unsigned dev_count = 1;
char* name = "openclose";



static struct file_operations my_fops = {
    .open = driver_open,
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
    return 0;

}

static int driver_open(struct inode *geraetedatei, struct file *instanz)
{
    int minor = iminor(geraetedatei);

    printk("Open-Funktion aufgerufen\n");

    if (minor==1 && atomic_read(&atomic)==0){
        int test=atomic_inc_and_test(&atomic);
        if (test == 0){
            printk("Im geschützen Bereich\n");
            }
        atomic_dec(&atomic);
        }

    return 0;
}

static int driver_release(struct inode *geraetedatei, struct file *instanz)
{   int minor = iminor(geraetedatei);
    if (minor==1 && atomic_read(&atomic)==0){
        atomic_dec(&atomic);
        printk("Release-Funktion mit minor == 1 aufgerufen\n");
    }
    printk("Release-Funktion ohne minor == 1 aufgerufen\n");
    return 0;
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

