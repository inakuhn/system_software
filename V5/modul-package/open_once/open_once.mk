OPEN_ONCE_VERSION:=1.0.0
OPEN_ONCE_SITE:=./dl/OPEN_ONCE-1.0.0.tar.gz
OPEN_ONCE_SITE_METHOD:=file
OPEN_ONCE_INSTALL_TARGET:=YES

define OPEN_ONCE_BUILD_CMDS
	$(MAKE) KDIR="../linux-4.2.3" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define OPEN_ONCE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/open_once.ko $(TARGET_DIR)/root/open_once/open_once.ko
	$(INSTALL) -D -m 0755 $(@D)/test_open_once.sh $(TARGET_DIR)/root/open_once/test_open_once.sh
endef

$(eval $(generic-package))
