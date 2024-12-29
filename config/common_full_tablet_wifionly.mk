# Inherit mobile full common Infinity stuff
$(call inherit-product, vendor/infinity/config/common_mobile_full.mk)

# Inherit tablet common Infinity stuff
$(call inherit-product, vendor/infinity/config/tablet.mk)

$(call inherit-product, vendor/infinity/config/wifionly.mk)
