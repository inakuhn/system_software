#include <linux/module.h>
#include <linux/version.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <asm/atomic.h>
#include <linux/kdev_t.h>
#include <linux/device.h>
#include  <linux/slab.h>
#include <asm/uaccess.h>

//Source: http://lxr.free-electrons.com/source/include/linux/module.h
//Source: https://ezs.kr.hsnr.de//TreiberBuch/html/index.html

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Silvia & Raina");
MODULE_ALIAS("myzero");
MODULE_VERSION("1");

struct _instanz_data {
    int counter;
} data;

static ssize_t driver_read( struct file *instanz, char *user, size_t count, loff_t *offset );

static int driver_release(struct inode *geraetedatei, struct file *instanz);
static int driver_open(struct inode *geraetedatei, struct file *instanz);

dev_t my_dev;
unsigned dev_count = 1;
char* name = "myzero";

struct file_operations my_fops = {
        .owner = THIS_MODULE,
        .open = driver_open,
        .read = driver_read,
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
{
	
	struct _instanz_data *iptr;
	
	printk(KERN_INFO  "driver_open called \n");	

    iptr = (struct _instanz_data *)kmalloc(sizeof(struct _instanz_data),GFP_KERNEL);
    if( iptr==0 ) {
        printk("not enough kernel mem\n");
        return -ENOMEM;
    }
    data.counter= strlen("Hello World\n")+1;
    instanz->private_data = (void *)iptr;        
    return 0;
    }

static int driver_release(struct inode *geraetedatei, struct file *instanz)
{printk(KERN_INFO  "driver_release called \n");
	if( instanz->private_data )
	{
        kfree( instanz->private_data );
	}
    return 0;}

static ssize_t driver_read( struct file *instanz, char *user, size_t count, loff_t *offset ){
    
    char hello_world[] ="Hello World\n";
    char null = '0';
    int minor = iminor(instanz->f_path.dentry->d_inode);

    int not_copied = 0;
    int to_copy= 0;
    int i;
	
    printk(KERN_INFO  "driver_read called \n");
    printk(KERN_INFO  "data counter: %d",data.counter);
    
    printk(KERN_INFO  " \n");

	if(data.counter > strlen(hello_world)+1) {
		printk(KERN_INFO "no more instance for you...\n");
		return 0;
	}
    if (minor == 0)
    {   to_copy= min(count, strlen(&null)+1);
        for(i = 0; i < count; i++)
        {
            not_copied = count;
			data.counter++;
        }
         printk(KERN_INFO  "opened with minor 0 \n");
    }

    else{
	printk(KERN_INFO  "opened with minor 1 \n");
    to_copy = strlen(hello_world)+1;
    if( to_copy > count )
        to_copy = count;
    not_copied=copy_to_user(user,hello_world,to_copy);

}
    return to_copy-not_copied;

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
