LOCK_VERSION:=1.0.0
LOCK_SITE:=./dl/LOCK-1.0.0.tar.gz
LOCK_SITE_METHOD:=file
LOCK_INSTALL_TARGET:=YES

define LOCK_BUILD_CMDS
	$(MAKE) KDIR="../linux-4.2.3" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define LOCK_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/lock.ko $(TARGET_DIR)/root/lock/lock.ko
	$(INSTALL) -D -m 0755 $(@D)/test_lock.sh $(TARGET_DIR)/root/lock/test_lock.sh
endef

$(eval $(generic-package))
