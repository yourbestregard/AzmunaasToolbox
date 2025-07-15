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

# --- Profil: Sony Xperia 1 VII ---

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
#FINGERPRINT="Sony/pdx256/pdx256:15/AQ3A.241126.002/SHIMANTO-1.0.0-REL-250402-1707:user/release-keys"
#DESCRIPTION="sssi_64-user 15 AQ3A.241126.002 QSSI-15.2.0-REL-250405-1707 release-keys"

# Set patch keamanan dan versi build
resetprop_and_write ro.build.id 71.0.A.2.22
resetprop_and_write ro.build.version.incremental QSSI-15.2.0-REL-250405-1707
resetprop_and_write ro.build.version.security_patch "$SECURITY_PATCH"
resetprop_and_write ro.vendor.build.security_patch "$SECURITY_PATCH"
resetprop_and_write ro.boot.vbmeta.patch_level "$SECURITY_PATCH"
#resetprop_and_write ro.build.description "$DESCRIPTION"

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
    #resetprop_and_write "${prop_prefix}.build.fingerprint" "$FINGERPRINT"

    # Set product properties
    resetprop_and_write "${product_prefix}.brand" Sony
    resetprop_and_write "${product_prefix}.name" pa3qxxx
    resetprop_and_write "${product_prefix}.device" qssi_64
    resetprop_and_write "${product_prefix}.model" Sssi_64
    resetprop_and_write "${product_prefix}.manufacturer" Sony

    resetprop_and_write "${product_prefix}.brand_for_attestation" Sony
    resetprop_and_write "${product_prefix}.name_for_attestation" pa3qxxx
    resetprop_and_write "${product_prefix}.device_for_attestation" qssi_64
    resetprop_and_write "${product_prefix}.model_for_attestation" Sssi_64
    resetprop_and_write "${product_prefix}.manufacturer_for_attestation" Sony
done

# Ganti tag "userdebug" dan "test-keys" menjadi tag rilis resmi di fingerprint dan set build.type serta build.tags
for prefix in "" bootimage system product odm system_ext; do
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
