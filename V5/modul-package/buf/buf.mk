BUF_VERSION:=1.0.0
BUF_SITE:=./dl/BUF-1.0.0.tar.gz
BUF_SITE_METHOD:=file
BUF_INSTALL_TARGET:=YES

define BUF_BUILD_CMDS
	$(MAKE) KDIR="../linux-4.2.3" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D) default
endef

define BUF_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/buf.ko $(TARGET_DIR)/root/buf/buf.ko
	$(INSTALL) -D -m 0755 $(@D)/test_buf.sh $(TARGET_DIR)/root/buf/test_buf.sh
endef

$(eval $(generic-package))
