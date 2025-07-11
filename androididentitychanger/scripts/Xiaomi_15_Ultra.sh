#!/system/bin/sh

# Profil: Xiaomi 15 Ultra

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
FINGERPRINT="qti/missi/missi:15/AQ3A.240912.001/OS2.0.110.0.VOACNXM:user/release-keys"
DESCRIPTION="missi-user 15 AQ3A.240912.001 OS2.0.110.0.VOACNXM release-keys"

resetprop ro.build.id AQ3A.240912.001
resetprop ro.build.version.release 15
resetprop ro.build.version.release_or_codename 15
resetprop ro.build.version.release_or_preview_display 15
resetprop ro.build.version.sdk 35
resetprop ro.build.version.incremental OS2.0.110.0.VOACNXM
resetprop ro.build.version.security_patch "$SECURITY_PATCH"
resetprop ro.vendor.build.security_patch "$SECURITY_PATCH"
resetprop ro.boot.vbmeta.patch_level "$SECURITY_PATCH"

# Set semua fingerprint dan deskripsi di semua partisi
for prefix in "" bootimage system product vendor odm system_ext; do
    resetprop ro.${prefix}build.fingerprint "$FINGERPRINT"
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.brand Xiaomi
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.name xuanyuan
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.device xuanyuan
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.model 25010PN30C
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.manufacturer Xiaomi

    [ -n "$prefix" ] && resetprop ro.product.${prefix}.brand_for_attestation Xiaomi
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.name_for_attestation xuanyuan
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.device_for_attestation xuanyuan
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.model_for_attestation 25010PN30C
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.manufacturer_for_attestation Xiaomi
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