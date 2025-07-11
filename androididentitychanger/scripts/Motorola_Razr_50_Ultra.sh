#!/system/bin/sh

# Profil: Motorola Razr 50 Ultra

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
FINGERPRINT="motorola/arcfox/arcfox:14/UUX34V.47/6e5905:user/release-keys"
DESCRIPTION="arcfox-user 14 UUX34V.47 6e5905 release-keys"

resetprop ro.build.id UUX34V.47
resetprop ro.build.version.release 14
resetprop ro.build.version.release_or_codename 14
resetprop ro.build.version.release_or_preview_display 14
resetprop ro.build.version.sdk 34
resetprop ro.build.version.incremental 16e5905
resetprop ro.build.version.security_patch "$SECURITY_PATCH"
resetprop ro.vendor.build.security_patch "$SECURITY_PATCH"
resetprop ro.boot.vbmeta.patch_level "$SECURITY_PATCH"

# Set semua fingerprint dan deskripsi di semua partisi
for prefix in "" bootimage system product vendor odm system_ext; do
    resetprop ro.${prefix}build.fingerprint "$FINGERPRINT"
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.brand motorola
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.name arcfox_cn
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.device msi
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.model XT2451-4
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.manufacturer motorola

    [ -n "$prefix" ] && resetprop ro.product.${prefix}.brand_for_attestation motorola
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.name_for_attestation arcfox_cn
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.device_for_attestation msi
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.model_for_attestation XT2451-4
    [ -n "$prefix" ] && resetprop ro.product.${prefix}.manufacturer_for_attestation motorola
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