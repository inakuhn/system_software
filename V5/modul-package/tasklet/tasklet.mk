TASKLET_VERSION:=1.0.0
TASKLET_SITE:=./dl/TASKLET-1.0.0.tar.gz
TASKLET_SITE_METHOD:=file
TASKLET_INSTALL_TARGET:=YES

define TASKLET_BUILD_CMDS
	$(MAKE) KDIR="../linux-4.2.3" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define TASKLET_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/tasklet.ko $(TARGET_DIR)/root/tasklet/tasklet.ko
	$(INSTALL) -D -m 0755 $(@D)/test_tasklet.sh $(TARGET_DIR)/root/tasklet/test_tasklet.sh
endef

$(eval $(generic-package))
