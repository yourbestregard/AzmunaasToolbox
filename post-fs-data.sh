#!/system/bin/sh
# post-fs-data.sh
# Skrip ini dijalankan sangat awal saat boot, setelah partisi /data terpasang.
# Cocok untuk modifikasi yang memengaruhi properti sistem seperti build.prop.

# Define MODPATH (jalur instalasi modul) yang disediakan oleh Magisk/KernelSU
MODPATH=/data/adb/modules/azmunaas_toolbox
# Path ke build.prop overlay di dalam modul
BUILD_PROP_PATH="$MODPATH/system/build.prop"

# Fungsi untuk mencatat pesan ke logcat, membantu proses debugging
log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [Azmunaa's Toolbox - POST-FS-DATA] $1"
}

log_message "Memulai eksekusi post-fs-data.sh..."

# Pastikan direktori 'system' di modul ada. Ini penting agar build.prop dapat ditulis.
mkdir -p "$(dirname "$BUILD_PROP_PATH")"
log_message "  -> Memastikan direktori $MODPATH/system ada."

# --- Logika Pembuatan build.prop Overlay Kondisional ---
# Sesuai permintaan: Jika salah satu fitur (1, 2, atau 4) dimatikan,
# maka build.prop di folder modul akan dihapus dan dibuat ulang hanya dengan fitur yang diaktifkan.

# Langkah 1: Hapus build.prop overlay yang sudah ada untuk memastikan konten yang baru dan bersih.
# Ini penting agar perubahan status fitur (aktif/nonaktif) tercermin dengan benar.
if [ -f "$BUILD_PROP_PATH" ]; then
    rm -f "$BUILD_PROP_PATH"
    log_message "  -> Menghapus build.prop overlay lama untuk pembaruan."
fi

# Langkah 2: Inisialisasi variabel untuk menampung konten build.prop yang akan dibuat.
BUILD_PROP_CONTENT=""

# Langkah 3: Periksa status setiap fitur berdasarkan keberadaan file flag di direktori 'flags'.
# Jika file flag ada, fitur dianggap diaktifkan dan properti terkait akan ditambahkan.

# Fitur 1: Spoof Perangkat Xiaomi 15
# Memodifikasi properti agar perangkat terlihat sebagai Xiaomi 15.
if [ -f "$MODPATH/flags/xiaomi_15_spoof_enabled" ]; then
    log_message "  -> Fitur: Spoof Xiaomi 15 diaktifkan. Menambahkan properti spoofing..."
    BUILD_PROP_CONTENT="${BUILD_PROP_CONTENT}
# Properti untuk Spoof Xiaomi 15
ro.product.manufacturer=Xiaomi
ro.product.model=Xiaomi 15
ro.product.device=xiaomi15
ro.product.brand=Xiaomi
ro.product.name=xiaomi15
ro.build.product=xiaomi15
"
fi

# Fitur 2: Spoof ROM Userdebug ke User
# Mengubah tipe build dari 'userdebug' menjadi 'user'.
if [ -f "$MODPATH/flags/user_build_spoof_enabled" ]; then
    log_message "  -> Fitur: Spoof Userdebug ke User diaktifkan. Menambahkan properti build type..."
    BUILD_PROP_CONTENT="${BUILD_PROP_CONTENT}
# Properti untuk Spoof Userdebug ke User
ro.build.type=user
ro.system.build.type=user
"
    # Catatan: Jika Anda juga perlu memodifikasi ro.build.fingerprint atau ro.build.description
    # yang mungkin mengandung "userdebug", Anda perlu membaca build.prop asli, memodifikasinya
    # dengan sed, lalu menambahkannya ke BUILD_PROP_CONTENT. Contoh:
    # FINGERPRINT_MOD=$(grep "^ro.build.fingerprint=" /system/build.prop 2>/dev/null | sed 's/userdebug/user/g')
    # if [ -n "$FINGERPRINT_MOD" ]; then BUILD_PROP_CONTENT="${BUILD_PROP_CONTENT}\n$FINGERPRINT_MOD"; fi
    # DESCRIPTION_MOD=$(grep "^ro.build.description=" /system/build.prop 2>/dev/null | sed 's/userdebug/user/g')
    # if [ -n "$DESCRIPTION_MOD" ]; then BUILD_PROP_CONTENT="${BUILD_PROP_CONTENT}\n$DESCRIPTION_MOD"; fi
fi

# Langkah 4: Tulis konten build.prop yang telah disusun ke file overlay.
# File ini akan dimuat oleh Magisk/KernelSU sebagai bagian dari overlay sistem.
if [ -n "$BUILD_PROP_CONTENT" ]; then
    echo -e "$BUILD_PROP_CONTENT" > "$BUILD_PROP_PATH"
    # Langkah 5: Atur izin yang benar untuk build.prop overlay (rw-r--r-- untuk root:root).
    chmod 0644 "$BUILD_PROP_PATH"
    chown 0:0 "$BUILD_PROP_PATH" # Pastikan dimiliki oleh root user dan group
    log_message "  -> build.prop overlay baru berhasil dibuat dan disimpan di $BUILD_PROP_PATH."
else
    log_message "  -> Tidak ada properti build.prop yang diaktifkan. build.prop overlay tidak dibuat."
fi


# --- Logika Fitur Lain (Tidak Langsung Memodifikasi build.prop) ---

# Fitur 4: Mematikan Spoof PIF Bawaan ROM
# Fitur ini memengaruhi properti runtime sistem (setprop), bukan file build.prop statis.
# Properti ini langsung diterapkan ke sistem pada saat boot.
if [ -f "$MODPATH/flags/pif_spoof_disable_enabled" ]; then
    log_message "  -> Fitur: Mematikan Spoof PIF bawaan ROM diaktifkan. Mengatur properti runtime..."
    # setprop digunakan untuk mengatur properti sistem secara dinamis.
    setprop persist.sys.pihooks.disable.gms_props true
    setprop persist.sys.pihooks.disable.gms_key_attestation_block true
    log_message "  -> Properti PIF spoofing runtime telah diatur."
else
    log_message "  -> Fitur: Mematikan Spoof PIF bawaan ROM dinonaktifkan."
    # Opsional: Jika fitur dimatikan, Anda mungkin ingin menghapus properti ini.
    # setprop persist.sys.pihooks.disable.gms_props "" # Mengatur ke string kosong untuk menghapus
    # setprop persist.sys.pihooks.disable.gms_key_attestation_block ""
fi

log_message "Eksekusi post-fs-data.sh selesai."
