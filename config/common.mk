# Allow vendor/extra to override any property by setting it first
$(call inherit-product-if-exists, vendor/extra/product.mk)

PRODUCT_BRAND ?= Project Infinity X

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

ifeq ($(PRODUCT_IS_ATV),true)
ifeq ($(PRODUCT_ATV_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.oem.key1=ATV00100020
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.oem.key1=$(PRODUCT_ATV_CLIENTID_BASE)
endif
endif

ifeq ($(TARGET_BUILD_VARIANT),eng)
# Disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.strictmode.disable=true
endif

# Additional Packages
include vendor/extras/prebuilts.mk

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/infinity/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions

ifneq ($(strip $(AB_OTA_PARTITIONS) $(AB_OTA_POSTINSTALL_CONFIG)),)
PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/infinity/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/infinity/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/backuptool_ab.sh \
    system/bin/backuptool_ab.functions \
    system/bin/backuptool_postinstall.sh

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_PRODUCT)/usr/keylayout/Vendor_045e_Product_0719.kl

# Enforce privapp-permissions whitelist
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.control_privapp_permissions=enforce

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
# but also allow explicit overriding for testing and development.
SYSTEM_OPTIMIZE_JAVA ?= true
SYSTEMUI_OPTIMIZE_JAVA ?= true

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

TARGET_DISABLE_EPPE ?= true
ifneq ($(TARGET_DISABLE_EPPE),true)
# Require all requested packages to exist
$(call enforce-product-packages-exist-internal,$(wildcard device/*/$(INFINITY_BUILD)/$(TARGET_PRODUCT).mk),product_manifest.xml rild Calendar Launcher3 Launcher3Go Launcher3QuickStep Launcher3QuickStepGo android.hidl.memory@1.0-impl.vendor vndk_apex_snapshot_package)
endif

# Build Manifest
PRODUCT_PACKAGES += \
    build-manifest

# Updater
ifeq ($(INFINITY_BUILD_TYPE),OFFICIAL)
PRODUCT_PACKAGES += \
    Updater

PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/etc/init/init.infinity-updater.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.infinity-updater.rc
endif

# Blurs
ifeq ($(TARGET_SUPPORTS_BLUR),true)
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.sf.blurs_are_expensive=1 \
    ro.surface_flinger.supports_background_blur=1 \
    ro.launcher.blur.appLaunch=0 \
    persist.sys.sf.disable_blurs=1
endif

# Charger
PRODUCT_PACKAGES += \
    charger_res_images \
    product_charger_res_images \
    product_charger_res_images_vendor

# Config
PRODUCT_PACKAGES += \
    SimpleDeviceConfig \
    SimpleSettingsConfig

# Extra tools
PRODUCT_PACKAGES += \
    bash \
    curl \
    getcap \
    htop \
    nano \
    setcap \
    vim

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/curl \
    system/bin/getcap \
    system/bin/setcap

# Filesystems tools
PRODUCT_PACKAGES += \
    fsck.ntfs \
    mkfs.ntfs \
    mount.ntfs

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/fsck.ntfs \
    system/bin/mkfs.ntfs \
    system/bin/mount.ntfs \
    system/%/libfuse-lite.so \
    system/%/libntfs-3g.so

# Freeform Windows
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.freeform_window_management.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.freeform_window_management.xml
    
# Gamespace
PRODUCT_PACKAGES += \
    GameSpace

PRODUCT_PRODUCT_PROPERTIES += \
    debug.graphics.game_default_frame_rate.disabled=true

# Gapps
ifeq ($(WITH_GAPPS),true)
$(call inherit-product, vendor/google/gms/config.mk)

DONT_DEXPREOPT_PREBUILTS := true

# UpdaterGMSOverlay
PRODUCT_PACKAGES += \
    UpdaterGMSOverlay
endif

# OPA configuration
PRODUCT_PRODUCT_PROPERTIES += \
    ro.opa.eligible_device=true
    
ifeq ($(TARGET_SHIPS_FULL_GAPPS),true)
ifneq ($(WITH_GAPPS),true)
$(warning TARGET_SHIPS_FULL_GAPPS is declared without declaration of WITH_GAPPS to true, hence it will create no impact)
endif
endif

ifeq ($(TARGET_BUILD_GOOGLE_TELEPHONY),true)
ifneq ($(WITH_GAPPS),true)
$(warning TARGET_BUILD_GOOGLE_TELEPHONY is declared without declaration of WITH_GAPPS to true, hence it will create no impact)
endif
endif

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

PRODUCT_COPY_FILES += \
    vendor/infinity/prebuilt/common/etc/init/init.openssh.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.openssh.rc

# Recorder
PRODUCT_PACKAGES += \
    Recorder

# ThemeOverlays
include packages/overlays/Themes/themes.mk

# rsync
PRODUCT_PACKAGES += \
    rsync

# Relax Broken Library Check
PRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true

# BtHelper
PRODUCT_PACKAGES += \
    BtHelper
    
# BatteryStatsViewer
PRODUCT_PACKAGES += \
    BatteryStatsViewer

# Storage manager
PRODUCT_SYSTEM_PROPERTIES += \
    ro.storage_manager.enabled=true

# Default wifi country code
PRODUCT_SYSTEM_PROPERTIES += \
    ro.boot.wificountrycode?=00

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/procmem
endif

# OmniJaws
PRODUCT_PACKAGES += \
    OmniJaws

# Root
PRODUCT_PACKAGES += \
    adb_root
ifneq ($(TARGET_BUILD_VARIANT),user)
ifeq ($(WITH_SU),true)
PRODUCT_PACKAGES += \
    su

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/xbin/su
endif
endif

# Face Unlock
TARGET_FACE_UNLOCK_SUPPORTED ?= $(TARGET_SUPPORTS_64_BIT_APPS)
ifeq ($(TARGET_FACE_UNLOCK_SUPPORTED),true)
PRODUCT_PACKAGES += \
    ParanoidSense
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.face.sense_service=true
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/android.hardware.biometrics.face.xml
endif

# Lineage-specific file
PRODUCT_COPY_FILES += \
    vendor/infinity/config/permissions/org.lineageos.health.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/org.lineageos.health.xml

PRODUCT_COPY_FILES += \
    vendor/infinity/config/permissions/privapp-permissions-lineagehw.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-lineagehw.xml

# SystemUI
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI \
    Launcher3QuickStep

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.systemuicompilerfilter=speed

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/infinity/overlay/no-rro
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/infinity/overlay/common \
    vendor/infinity/overlay/no-rro

PRODUCT_PACKAGES += \
    DocumentsUIOverlay \
    NavigationBarNoHintOverlay \
    KeyboardNoNavigationBarOverlay \
    NetworkStackOverlay

# Translations
CUSTOM_LOCALES += \
    ast_ES \
    gd_GB \
    cy_GB \
    fur_IT

# Bootanimation
include vendor/infinity/config/bootanimation.mk

# Fonts
include vendor/infinity/config/fonts.mk

# Version
include vendor/infinity/config/version.mk

-include $(WORKSPACE)/build_env/image-auto-bits.mk

# Signing Keys
ifeq ($(INFINITY_BUILD_TYPE),OFFICIAL)
include vendor/infinity-priv/keys/keys.mk
else
-include vendor/infinity-priv/keys/keys.mk
endif

PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.pihooks_mainline_BRAND?=google \
    persist.sys.pihooks_mainline_DEVICE?=caiman \
    persist.sys.pihooks_mainline_MANUFACTURER?=Google \
    persist.sys.pihooks_mainline_PRODUCT?=caiman \
    persist.sys.pihooks_BRAND?=google \
    persist.sys.pihooks_MANUFACTURER?=Google \
    persist.sys.pihooks_DEVICE?=tokay \
    persist.sys.pihooks_PRODUCT?=tokay_beta \
    persist.sys.pihooks_DEVICE_INITIAL_SDK_INT?=25 \
    persist.sys.pihooks_SECURITY_PATCH?=2024-09-05 \
    persist.sys.pihooks_ID?=AP41.240823.009

PRODUCT_BUILD_PROP_OVERRIDES += \
    PihooksGmsFp="google/tokay_beta/tokay:15/AP41.240823.009/12329489:user/release-keys" \
    PihooksGmsModel="Pixel 9" \
    PihooksBuildFp="google/caiman/caiman:14/AD1A.240530.047.U1/12150698:user/release-keys" \
    PihooksBuildModel="Pixel 9 Pro"
