ARCHS = arm64
TARGET = iphone:clang:latest

include theos/makefiles/common.mk

TWEAK_NAME = simplereach
simplereach_FILES = Tweak.xmi
simplereach_FRAMEWORKS = UIKit CoreGraphics QuartzCore
simplereach_PRIVATE_FRAMEWORKS = IOKit BiometricKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += settings
include $(THEOS_MAKE_PATH)/aggregate.mk
