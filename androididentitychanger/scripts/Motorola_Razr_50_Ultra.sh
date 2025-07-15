#!/system/bin/sh

PROP_FILE="/data/adb/modules/androididentitychanger/system.prop"
BACKUP_PROP_FILE="${PROP_FILE}.bak"

# Cek dan buat file jika belum ada, atau backup jika sudah ada
if [ ! -f "$PROP_FILE" ]; then
    touch "$PROP_FILE"
    chmod 644 "$PROP_FILE"
else
    cp "$PROP_FILE" "$BACKUP_PROP_FILE"
fi

# Bersihkan isi file
> "$PROP_FILE"

# Fungsi menulis properti ke file
write_prop_to_file() {
    echo "$1=$2" >> "$PROP_FILE"
}

# Fungsi resetprop dan tulis properti ke file
resetprop_and_write() {
    resetprop "$1" "$2" >/dev/null 2>&1
    write_prop_to_file "$1" "$2"
}

# --- Profil: Motorola Razr 50 Ultra ---

# Hitung tanggal patch keamanan bulan sebelumnya
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

# Set patch keamanan dan versi build
resetprop_and_write ro.build.id UUX34V.47
resetprop_and_write ro.build.version.incremental 16e5905
resetprop_and_write ro.build.version.security_patch "$SECURITY_PATCH"
resetprop_and_write ro.vendor.build.security_patch "$SECURITY_PATCH"
resetprop_and_write ro.boot.vbmeta.patch_level "$SECURITY_PATCH"
resetprop_and_write ro.build.description "$DESCRIPTION"

# Set properti produk di semua partisi
for prefix in "" bootimage system product odm system_ext; do
    if [ -n "$prefix" ]; then
        prop_prefix="ro.${prefix}"
        product_prefix="ro.product.${prefix}"
    else
        prop_prefix="ro"
        product_prefix="ro.product"
    fi

    # Set fingerprint
    resetprop_and_write "${prop_prefix}.build.fingerprint" "$FINGERPRINT"

    # Set product properties
    resetprop_and_write "${product_prefix}.brand" motorola
    resetprop_and_write "${product_prefix}.name" arcfox_cn
    resetprop_and_write "${product_prefix}.device" msi
    resetprop_and_write "${product_prefix}.model" XT2451-4
    resetprop_and_write "${product_prefix}.manufacturer" motorola

    resetprop_and_write "${product_prefix}.brand_for_attestation" motorola
    resetprop_and_write "${product_prefix}.name_for_attestation" arcfox_cn
    resetprop_and_write "${product_prefix}.device_for_attestation" msi
    resetprop_and_write "${product_prefix}.model_for_attestation" XT2451-4
    resetprop_and_write "${product_prefix}.manufacturer_for_attestation" motorola
done

# Ganti tag "userdebug" dan "test-keys" menjadi tag rilis resmi di fingerprint dan set build.type serta build.tags
for prefix in "" system vendor system_ext product odm odm_dlkm vendor_dlkm bootimage; do
    if [ -z "$prefix" ]; then
        prop_prefix="ro"
    else
        prop_prefix="ro.${prefix}"
    fi

    resetprop_and_write "${prop_prefix}.build.type" user
    resetprop_and_write "${prop_prefix}.build.tags" release-keys

    curr_fp=$(getprop "${prop_prefix}.build.fingerprint")
    new_fp=$(echo "$curr_fp" | sed 's/userdebug/user/g')
    new_fp=$(echo "$new_fp" | sed 's/test-keys/release-keys/g')
    resetprop_and_write "${prop_prefix}.build.fingerprint" "$new_fp"
done
