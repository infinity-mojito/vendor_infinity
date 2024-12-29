# Inherit common Infinity stuff
$(call inherit-product, vendor/infinity/config/common_mobile.mk)

PRODUCT_SIZE := full

ifneq ($(PRODUCT_NO_CAMERA),true)
PRODUCT_PACKAGES += \
    Aperture
endif

ifneq ($(TARGET_EXCLUDES_AUDIOFX),true)
PRODUCT_PACKAGES += \
    AudioFX
endif

# Extra cmdline tools
PRODUCT_PACKAGES += \
    unrar \
    zstd

# Include Infinity LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/infinity/overlay/dictionaries
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/infinity/overlay/dictionaries
