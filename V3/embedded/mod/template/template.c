#include <linux/module.h>
#include <linux/version.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>

//Source: http://lxr.free-electrons.com/source/include/linux/module.h

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Silvia & Raina");
MODULE_ALIAS("Supertestmodul");
MODULE_DESCRIPTION("Das hier ist zum testen wie das mit dem Treiber laden und entladen geht");
MODULE_VERSION("1");
static struct file_operations fops;
static int __init ModInit(void)
{
	printk(KERN_INFO  "Hello, world\n");
	 
	if(register_chrdev(240,"TestDriver",&fops)==0) {
		printk(KERN_INFO  "Treiber lauft auf");
		return 0; // Treiber erfolgreich angemeldet
	}
	return -EIO; // Anmeldung beim Kernel fehlgeschlagen

}

static void __exit ModExit(void)
{
        printk(KERN_INFO  "Goodbye, cruel world\n");
        unregister_chrdev(240,"TestDriver");
}

module_init(ModInit);
module_exit(ModExit);
