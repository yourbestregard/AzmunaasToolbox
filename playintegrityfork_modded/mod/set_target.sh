#!/bin/sh

# Fungsi untuk mencatat pesan dengan timestamp
log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [SET_TARGET] $1"
}

log_message "Start setting target..."
t='/data/adb/tricky_store/target.txt'
tees='/data/adb/tricky_store/tee_status'

# Periksa status tee
teeBroken="false"
if [ -f "$tees" ]; then
    teeBroken=$(grep -E '^teeBroken=' "$tees" | cut -d '=' -f2 2>/dev/null || echo "false")
fi

# Kosongkan file target dan langsung isi dengan daftar spesial
log_message "Creating new target list with special packages..."
{
    echo "android"
    echo "com.android.vending!"
    echo "com.google.android.gms!"
    echo "io.github.vvb2060.keyattestation!"
    echo "io.github.vvb2060.mahoshojo"
} > "$t"

# Fungsi untuk menambahkan paket ke daftar
add_packages() {
    # Ambil daftar paket dan proses satu per satu
    pm list packages "$1" | cut -d ":" -f 2 | while read -r pkg; do
        # Lewati jika nama paket kosong
        if [ -z "$pkg" ]; then
            continue
        fi
        
        # Periksa apakah paket sudah ada 
        if ! grep -q -E "^${pkg}(!|\$)" "$t"; then
            # Jika tidak ditemukan, tambahkan ke daftar
            if [ "$teeBroken" = "true" ]; then
                echo "$pkg!" >> "$t"
            else
                echo "$pkg" >> "$t"
            fi
        fi
    done
}

# Tambahkan aplikasi pengguna (-3)
log_message "Adding user apps..."
add_packages "-3"

# Tambahkan aplikasi sistem (-s)
log_message "Adding system apps..."
add_packages "-s"

log_message "Finish setting target."