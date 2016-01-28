MYZERO_VERSION:=1.0.0
MYZERO_SITE:=./dl/myzero-1.0.0.tar.gz
MYZERO_SITE_METHOD:=file
MYZERO_INSTALL_TARGET:=YES

define MYZERO_BUILD_CMDS
	$(MAKE) KDIR="../linux-4.2.3" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define MYZERO_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/myzero.ko $(TARGET_DIR)/root/myzero/myzero.ko
	$(INSTALL) -D -m 0755 $(@D)/test_myzero.sh $(TARGET_DIR)/root/myzero/test_myzero.sh
endef

$(eval $(generic-package))
