ARCHS = arm64
TARGET = iphone:clang:latest

include theos/makefiles/common.mk

BUNDLE_NAME = SimpleReachSettings
SimpleReachSettings_FILES = SimpleReachSettings.mm
SimpleReachSettings_INSTALL_PATH = /Library/PreferenceBundles
SimpleReachSettings_FRAMEWORKS = UIKit MessageUI
SimpleReachSettings_PRIVATE_FRAMEWORKS = Preferences
SimpleReachSettings_LIBRARIES = MobileGestalt

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SimpleReachSettings.plist$(ECHO_END)
