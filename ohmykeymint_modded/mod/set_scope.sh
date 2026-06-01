#!/bin/sh

# Daftar lokasi injector dipisahkan dengan spasi
TARGET_INJECTORS="/data/misc/keystore/omk/injector.toml /data/adb/modules/oh_my_keymint/injector.toml"
TMP_DIR='/data/local/tmp'

RAW_LIST="$TMP_DIR/omk_raw_pkgs.txt"
UNIQUE_LIST="$TMP_DIR/omk_unique_pkgs.txt"
FORMATTED_SCOOP="$TMP_DIR/omk_formatted_scoop.txt"
TMP_INJECTOR="$TMP_DIR/injector.toml.tmp"

# Fungsi untuk mencatat pesan dengan timestamp
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [SET_SCOPE] $1"
}

log_message "Starting to set the scope..."

# Mengumpulkan semua paket khusus dan aplikasi sistem/pengguna
log_message "Adding custom packages to the list..."
{
    echo "io.github.vvb2060.keyattestation"
    echo "com.google.android.gsf"
    echo "com.google.android.gms"
    echo "com.android.vending"
    echo "com.eltavine.duckdetector"
} > "$RAW_LIST"

# Mengambil semua paket aplikasi di perangkat
log_message "Retrieving the entire list of applications..."
pm list packages | cut -d ":" -f 2 >> "$RAW_LIST"

# Sortir dan hapus duplikasi paket
sort -u "$RAW_LIST" > "$UNIQUE_LIST"

# Format menjadi baris array TOML
log_message "Formatting the scope array..."
: > "$FORMATTED_SCOOP"
while read -r pkg; do
    if [ -n "$pkg" ]; then
        echo "  \"$pkg\"," >> "$FORMATTED_SCOOP"
    fi
done < "$UNIQUE_LIST"

for INJECTOR in $TARGET_INJECTORS; do
    log_message "======================================="
    log_message "Processing injector at: $INJECTOR"

    # Validasi apakah file injector.toml ada di lokasi saat ini
    if [ ! -f "$INJECTOR" ]; then
        log_message "Warning: File $INJECTOR not found! Skipping to next target..."
        continue # Melompat ke lokasi berikutnya, bukan 'exit' agar skrip tidak langsung mati
    fi

    # Memproses dan menyisipkan data ke injector.toml
    log_message "Injecting the configuration into $INJECTOR..."
    in_scoop=0
    : > "$TMP_INJECTOR"

    while IFS= read -r line || [ -n "$line" ]; do
        # Jika berada di dalam blok scoop lama, abaikan barisnya hingga bertemu ']'
        if [ "$in_scoop" -eq 1 ]; then
            if echo "$line" | grep -q "]"; then
                in_scoop=0
            fi
            continue
        fi

        # Jika menemukan baris pembuka 'scoop = ['
        if echo "$line" | grep -q "^scoop = \["; then
            echo "scoop = [" >> "$TMP_INJECTOR"
            cat "$FORMATTED_SCOOP" >> "$TMP_INJECTOR"
            echo "]" >> "$TMP_INJECTOR"
            in_scoop=1
            continue
        fi

        # Salin baris lain di luar blok scoop
        echo "$line" >> "$TMP_INJECTOR"
    done < "$INJECTOR"

    # Mengembalikan data ke injector.toml asli
    cat "$TMP_INJECTOR" > "$INJECTOR"
    log_message "Successfully injected into $INJECTOR"
done

log_message "======================================="
log_message "Cleaning up temporary files..."
rm -f "$RAW_LIST" "$UNIQUE_LIST" "$FORMATTED_SCOOP" "$TMP_INJECTOR"

log_message "Finished setting the scope for all targets."