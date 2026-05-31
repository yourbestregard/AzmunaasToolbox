#!/bin/sh

INJECTOR='/data/misc/keystore/omk/injector.toml'

# Fungsi untuk mencatat pesan dengan timestamp
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [SET_SCOPE] $1"
}

log_message "Starting to set the scope..."

# Validasi apakah file injector.toml ada
if [ ! -f "$INJECTOR" ]; then
    log_message "Error: File $INJECTOR not found!"
    exit 1
fi

# Membuat temporary file di memory untuk menyimpan raw list paket
TMP_LIST=$(mktemp)

log_message "Adding custom package to the list..."
{
    echo "com.google.android.gsf"
    echo "com.google.android.gms"
    echo "com.android.vending"
    echo "io.github.vvb2060.keyattestation"
    echo "io.github.vvb2060.mahoshojo"
    echo "# Add more packages here if needed"
} > "$TMP_LIST"

log_message "Retrieving the entire list of applications..."
pm list packages | cut -d ":" -f 2 >> "$TMP_LIST"

log_message "Formatting the list into a multiline array..."
# Format: 2 spasi awal, tanda kutip ganda, string paket, koma, baris baru
FORMATTED_SCOOP=$(sort -u "$TMP_LIST" | awk '{printf "  \"%s\",\n", $0}')

# Hapus temporary file
rm "$TMP_LIST"

log_message "Injecting configuration into $INJECTOR..."

# Menggunakan awk untuk menimpa blok multiline
awk -v new_data="$FORMATTED_SCOOP" '
/^scoop = \[/ {
    # Jika menemukan baris pembuka array, cetak pembuka baru
    print "scoop = ["
    # Cetak semua daftar aplikasi yang sudah diformat
    printf "%s", new_data
    # Cetak penutup array baru
    print "]"
    # Aktifkan flag penanda bahwa kita sedang berada di dalam blok array lama
    in_scoop = 1
    next
}
in_scoop == 1 && /\]/ {
    # Jika menemukan kurung tutup array lama, matikan flag
    in_scoop = 0
    next
}
in_scoop == 1 { 
    # Abaikan/hapus isi paket dari array lama
    next 
}
{ 
    # Cetak sisa konfigurasi di luar blok scoop secara normal
    print 
}
' "$INJECTOR" > "${INJECTOR}.tmp"

# Timpa file asli dengan file hasil modifikasi
mv "${INJECTOR}.tmp" "$INJECTOR"

log_message "Finished setting up the scope."