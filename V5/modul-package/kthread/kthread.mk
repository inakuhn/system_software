KTHREAD_VERSION:=1.0.0
KTHREAD_SITE:=./dl/KTHREAD-1.0.0.tar.gz
KTHREAD_SITE_METHOD:=file
KTHREAD_INSTALL_TARGET:=YES

define KTHREAD_BUILD_CMDS
	$(MAKE) KDIR="../linux-4.2.3" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define KTHREAD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/kthread.ko $(TARGET_DIR)/root/kthread/kthread.ko
	$(INSTALL) -D -m 0755 $(@D)/test_kthread.sh $(TARGET_DIR)/root/kthread/test_kthread.sh
endef

$(eval $(generic-package))
