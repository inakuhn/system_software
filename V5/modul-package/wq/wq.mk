WQ_VERSION:=1.0.0
WQ_SITE:=./dl/WQ-1.0.0.tar.gz
WQ_SITE_METHOD:=file
WQ_INSTALL_TARGET:=YES

define WQ_BUILD_CMDS
	$(MAKE) KDIR="../linux-4.2.3" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define WQ_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/wq.ko $(TARGET_DIR)/root/wq/wq.ko
	$(INSTALL) -D -m 0755 $(@D)/test_wq.sh $(TARGET_DIR)/root/wq/test_wq.sh
endef

$(eval $(generic-package))
