
#include <linux/module.h>
#include <linux/version.h>
#include <linux/timer.h>
#include <linux/sched.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Silvia & Raina");
MODULE_ALIAS("Supertestmodul");
MODULE_DESCRIPTION("Timer Treiber");
MODULE_VERSION("1");
/*
 * CODE BEISPEIL AUS 
 * https://ezs.kr.hsnr.de//TreiberBuch/html/sec.sftirq.html#EX.KTIMER
 * 
 */
static struct timer_list mytimer;
unsigned long time_last_call = 0;
unsigned long dauern = 0;
unsigned long min = ULONG_MAX;
unsigned long max = 0L;
unsigned long jiff = 0;

static void inc_count(unsigned long arg)
{
	if(!time_last_call)
	{
		time_last_call = mytimer.expires;
		printk(KERN_INFO "DEFINE time_last_call: (%ld) \n", mytimer.expires);
	
	}else
	{
		jiff = jiffies;
		dauern = jiff - time_last_call;
		min = min(dauern, min);
		max = max(dauern, max);
		time_last_call = jiff;
	}
    printk(KERN_INFO "inc_count called (%ld)...\n", mytimer.expires);
    mytimer.expires = jiffies + (2*HZ); // 2 second
    add_timer( &mytimer );
    
}


static int __init ktimer_init(void)
{
    init_timer( &mytimer );
    mytimer.function = inc_count;
    mytimer.data = 0;
    
    mytimer.expires = jiffies + (2*HZ); // 2 second
    printk(KERN_INFO "INITIAL JIFFIES (%ld) \n", jiffies);
    add_timer( &mytimer );
    return 0;
}

static void __exit ktimer_exit(void)
{
	printk(KERN_INFO "MAX INTERVALL (%ld) \n", max);
    printk(KERN_INFO "MIN INTERVALL (%ld) \n", min);
    if( timer_pending( &mytimer ) )
        printk("Timer ist aktiviert ...\n");
    if( del_timer_sync( &mytimer ) )
        printk("Aktiver Timer deaktiviert\n");
    else
        printk("Kein Timer aktiv\n");
}

module_init( ktimer_init );
module_exit( ktimer_exit );
