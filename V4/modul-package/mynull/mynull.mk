MYNULL_VERSION:=1.0.0
MYNULL_SITE:=./dl/mynull-1.0.0.tar.gz
MYNULL_SITE_METHOD:=file
MYNULL_INSTALL_TARGET:=YES

define MYNULL_BUILD_CMDS
	$(MAKE) KDIR="../linux-4.2.3" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define MYNULL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/mynull.ko $(TARGET_DIR)/root/mynull/mynull.ko
	$(INSTALL) -D -m 0755 $(@D)/test_mynull.sh $(TARGET_DIR)/root/mynull/test_mynull.sh
endef

$(eval $(generic-package))
