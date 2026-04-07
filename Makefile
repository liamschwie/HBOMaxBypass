ARCHS = arm64
TARGET := iphone:clang:16.5:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HBOMaxBypass

HBOMaxBypass_FILES = Tweak.x
HBOMaxBypass_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
