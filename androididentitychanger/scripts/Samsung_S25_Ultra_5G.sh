#!/system/bin/sh

# Profil: Samsung Galaxy S25 Ultra 5G

# --- Properti Utama ---
current_year=$(date +%Y)
current_month=$(date +%m) 
current_month_num=$((10#$current_month))

if [ "$current_month_num" -eq 1 ]; then
  prev_month=12
  prev_year=$((current_year - 1))
else
  prev_month=$((current_month_num - 1))
  prev_year=$current_year
fi

formatted_month=$(printf "%02d" $prev_month)
SECURITY_PATCH="${prev_year}-${formatted_month}-05"
FINGERPRINT="samsung/pa3qxxx/pa3q:15/AP3A.240905.015.A2/S938BXXU1AYB4:user/release-keys"
DESCRIPTION="pa3qxxx-user 15 AP3A.240905.015.A2 S938BXXU1AYB4 release-keys"

resetprop ro.build.id AP3A.240905.015.A2
resetprop ro.build.version.release 15
resetprop ro.build.version.release_or_codename 15
resetprop ro.build.version.release_or_preview_display 15
resetprop ro.build.version.sdk 35
resetprop ro.build.version.incremental S938BXXU1AYB4
resetprop ro.build.version.security_patch "$SECURITY_PATCH"
resetprop ro.vendor.build.security_patch "$SECURITY_PATCH"
resetprop ro.boot.vbmeta.patch_level "$SECURITY_PATCH"

# Set semua fingerprint dan deskripsi di semua partisi
for prefix in "" bootimage system product vendor odm system_ext; do
    resetprop ro.${prefix}build.fingerprint "$FINGERPRINT"
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.brand samsung
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.name pa3qxxx
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.device pa3q
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.model SM-S938B
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.manufacturer samsung

    [ -n "$prefix" ] && resetprop ro.product.${prefix}.brand_for_attestation samsung
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.name_for_attestation pa3qxxx
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.device_for_attestation pa3q
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.model_for_attestation SM-S938B
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.manufacturer_for_attestation samsung
done

resetprop ro.build.description "$DESCRIPTION"

# Mengganti tag "userdebug" dan "test-keys" menjadi tag rilis resmi.
for prefix in "" system vendor system_ext product odm odm_dlkm vendor_dlkm bootimage; do
    # Atur build type ke "user" (rilis)
    resetprop ro.${prefix}.build.type user
    resetprop ro.${prefix}.build.tags release-keys
    
    # Ganti "userdebug" -> "user" di fingerprint jika ada
    curr_fp=$(getprop ro.${prefix}.build.fingerprint)
    new_fp=$(echo "$curr_fp" | sed 's/userdebug/user/g')
    resetprop ro.${prefix}.build.fingerprint "$new_fp"
    
    # Ganti "test-keys" -> "release-keys" di fingerprint jika ada
    curr_fp=$(getprop ro.${prefix}.build.fingerprint)
    new_fp=$(echo "$curr_fp" | sed 's/test-keys/release-keys/g')
    resetprop ro.${prefix}.build.fingerprint "$new_fp"
done