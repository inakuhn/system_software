TIMER_VERSION:=1.0.0
TIMER_SITE:=./dl/TIMER-1.0.0.tar.gz
TIMER_SITE_METHOD:=file
TIMER_INSTALL_TARGET:=YES

define TIMER_BUILD_CMDS
	$(MAKE) KDIR="../linux-4.2.3" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define TIMER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/timer.ko $(TARGET_DIR)/root/timer/timer.ko
	$(INSTALL) -D -m 0755 $(@D)/test_timer.sh $(TARGET_DIR)/root/timer/test_timer.sh
endef

$(eval $(generic-package))
