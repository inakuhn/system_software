OPENCLOSE_VERSION:=1.0.0
OPENCLOSE_SITE:=./dl/openclose-1.0.0.tar.gz
OPENCLOSE_SITE_METHOD:=file
OPENCLOSE_INSTALL_TARGET:=YES

define OPENCLOSE_BUILD_CMDS
	$(MAKE) KDIR="../linux-4.2.3" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D) default
endef

define OPENCLOSE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/openclose.ko $(TARGET_DIR)/root/openclose/openclose.ko
	$(INSTALL) -D -m 0755 $(@D)/test_openclose.sh $(TARGET_DIR)/root/openclose/test_openclose.sh
endef

$(eval $(generic-package))
