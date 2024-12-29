# Inherit common mobile Infinity stuff
$(call inherit-product, vendor/infinity/config/common.mk)

# Apps
PRODUCT_PACKAGES += \
    LatinIME

# Media
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    media.recorder.show_manufacturer_and_model=true

# SystemUI plugins
PRODUCT_PACKAGES += \
    QuickAccessWallet

# Themes
PRODUCT_PACKAGES += \
    ThemePicker \
    ThemesStub
