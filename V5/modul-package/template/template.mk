TEMPLATE_VERSION:=1.0.0
TEMPLATE_SITE:=./dl/template-1.0.0.tar.gz
TEMPLATE_SITE_METHOD:=file
TEMPLATE_INSTALL_TARGET:=YES

define TEMPLATE_BUILD_CMDS
	$(MAKE) KDIR="../linux-4.2.3" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define TEMPLATE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/template.ko $(TARGET_DIR)/root/template/template.ko
	$(INSTALL) -D -m 0755 $(@D)/test_template.sh $(TARGET_DIR)/root/template/test_template.sh
endef

$(eval $(generic-package))
