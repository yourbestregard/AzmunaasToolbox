#!/system/bin/sh
# post-fs-data.sh
#
# Skrip ini dijalankan sangat awal dalam proses boot Android, setelah partisi /data dipasang.
# Ini adalah tahap yang ideal untuk modifikasi yang memengaruhi properti sistem (`build.prop`)
# atau yang memerlukan akses ke partisi /data sebelum layanan sistem lainnya dimulai sepenuhnya.
# Modul ini menggunakan skrip ini untuk mengelola properti spoofing perangkat dan build type
# berdasarkan file bendera (flag files) yang diatur melalui WebUI.

# Define MODPATH (jalur instalasi modul) yang disediakan oleh Magisk/KernelSU.
# Ini adalah jalur absolut ke direktori tempat modul diinstal (`/data/adb/modules/<module_id>`).
MODPATH=/data/adb/modules/azmunaas_toolbox
# Tentukan jalur lengkap untuk file `build.prop` overlay di dalam direktori `system` modul.
# File ini akan digunakan oleh Magisk/KernelSU untuk menumpuk (overlay) properti sistem asli.
BUILD_PROP_PATH="$MODPATH/system/build.prop"

# ================================================
#  Fungsi Logging
# ================================================

# Fungsi `log_message` digunakan untuk mencatat pesan ke logcat Android.
# Ini sangat membantu untuk debugging dan memantau eksekusi skrip selama boot.
log_message() {
    # Menggunakan `echo` dengan format waktu dan tag modul untuk pesan log yang jelas.
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [Azmunaa's Toolbox - POST-FS-DATA] $1"
}

# ================================================
#  Logika Utama Skrip
# ================================================

log_message "Memulai eksekusi post-fs-data.sh..."

# Pastikan direktori `system` di dalam modul ada.
# Ini penting karena `build.prop` akan ditulis di `MODPATH/system/build.prop`.
# `dirname "$BUILD_PROP_PATH"` akan menghasilkan `$MODPATH/system`.
mkdir -p "$(dirname "$BUILD_PROP_PATH")"
log_message "  -> Memastikan direktori $MODPATH/system ada."

# --- Logika Pembuatan build.prop Overlay Kondisional ---
# Bagian ini bertanggung jawab untuk membuat atau memperbarui file `build.prop` overlay
# berdasarkan fitur spoofing yang diaktifkan/dinonaktifkan oleh pengguna melalui WebUI.
# Status fitur dikendalikan oleh keberadaan file bendera di `$MODPATH/flags/`.

# Langkah 1: Hapus `build.prop` overlay yang sudah ada (jika ada).
# Ini memastikan bahwa setiap kali skrip dijalankan, konten `build.prop` yang baru
# akan dibuat dari awal, mencerminkan perubahan status fitur secara akurat.
if [ -f "$BUILD_PROP_PATH" ]; then # Memeriksa apakah file `build.prop` ada
    rm -f "$BUILD_PROP_PATH" # Menghapus file secara paksa
    log_message "  -> Menghapus build.prop overlay lama untuk pembaruan."
fi

# Langkah 2: Inisialisasi variabel untuk menampung konten `build.prop` yang akan dibangun.
# Konten ini akan diisi secara bertahap berdasarkan fitur yang diaktifkan.
BUILD_PROP_CONTENT=""

# Langkah 3: Periksa status setiap fitur berdasarkan keberadaan file bendera.
# Jika file bendera (`_enabled`) ditemukan di direktori `flags`, fitur dianggap diaktifkan.
# Properti `build.prop` yang relevan kemudian ditambahkan ke `BUILD_PROP_CONTENT`.

# Fitur 1: Spoof Perangkat Xiaomi 15
# Jika file `xiaomi_15_spoof_enabled` ada, properti sistem akan diubah agar perangkat
# terlihat sebagai Xiaomi 15.
if [ -f "$MODPATH/flags/xiaomi_15_spoof_enabled" ]; then
    log_message "  -> Fitur: Spoof Xiaomi 15 diaktifkan. Menambahkan properti spoofing..."
    BUILD_PROP_CONTENT="${BUILD_PROP_CONTENT}
# Properti untuk Spoof Xiaomi 15 (Model: 24129PN74G)
ro.product.brand=xiaomi
ro.product.manufacturer=xiaomi
ro.product.device=dada
ro.product.model=24129PN74G
ro.product.marketname=Xiaomi 15

# Properti spoofing untuk partisi ODM (Original Design Manufacturer)
ro.product.odm.brand=xiaomi
ro.product.odm.manufacturer=xiaomi
ro.product.odm.device=dada
ro.product.odm.model=24129PN74G
ro.product.odm.marketname=Xiaomi 15

# Properti spoofing untuk partisi Product
ro.product.product.brand=xiaomi
ro.product.product.manufacturer=xiaomi
ro.product.product.device=dada
ro.product.product.model=24129PN74G
ro.product.product.marketname=Xiaomi 15

# Properti spoofing untuk partisi System
ro.product.system.brand=xiaomi
ro.product.system.manufacturer=xiaomi
ro.product.system.device=dada
ro.product.system.model=24129PN74G
ro.product.system.marketname=Xiaomi 15

# Properti spoofing untuk partisi System_Ext (System Extension)
ro.product.system_ext.brand=xiaomi
ro.product.system_ext.manufacturer=xiaomi
ro.product.system_ext.device=dada
ro.product.system_ext.model=24129PN74G
ro.product.system_ext.marketname=Xiaomi 15

# Properti spoofing untuk partisi Vendor
ro.product.vendor.brand=xiaomi
ro.product.vendor.manufacturer=xiaomi
ro.product.vendor.device=dada
ro.product.vendor.model=24129PN74G
ro.product.vendor.marketname=Xiaomi 15

# Properti tambahan terkait chipset dan fitur (misal: unlock FPS)
ro.soc.model=SM8750
sys.fps_unlock_allowed=120
"
fi

# Fitur 2: Spoof ROM Userdebug ke User
# Jika file `user_build_spoof_enabled` ada, tipe build ROM akan diubah dari
# 'userdebug' (build pengembangan) menjadi 'user' (build final konsumen).
# Ini seringkali diperlukan untuk lolos pemeriksaan integritas tertentu.
if [ -f "$MODPATH/flags/user_build_spoof_enabled" ]; then
    log_message "  -> Fitur: Spoof Userdebug ke User diaktifkan. Menambahkan properti build type..."
    BUILD_PROP_CONTENT="${BUILD_PROP_CONTENT}
# Properti untuk Spoof Userdebug ke User
ro.build.type=user
ro.system.build.type=user
"
    # Catatan: Beberapa properti seperti fingerprint atau description mungkin juga
    # mengandung string "userdebug". Bagian ini mencoba membaca properti asli dari
    # `/system/build.prop`, mengganti "userdebug" dengan "user" menggunakan `sed`,
    # dan menambahkannya ke konten `build.prop` overlay.
    FINGERPRINT_MOD=$(grep "^ro.build.fingerprint=" /system/build.prop 2>/dev/null | sed 's/userdebug/user/g')
    if [ -n "$FINGERPRINT_MOD" ]; then BUILD_PROP_CONTENT="${BUILD_PROP_CONTENT}\n$FINGERPRINT_MOD"; fi
    FINGERPRINT_MOD=$(grep "^ro.system.fingerprint=" /system/build.prop 2>/dev/null | sed 's/userdebug/user/g')
    if [ -n "$FINGERPRINT_MOD" ]; then BUILD_PROP_CONTENT="${BUILD_PROP_CONTENT}\n$FINGERPRINT_MOD"; fi
    DESCRIPTION_MOD=$(grep "^ro.build.description=" /system/build.prop 2>/dev/null | sed 's/userdebug/user/g')
    if [ -n "$DESCRIPTION_MOD" ]; then BUILD_PROP_CONTENT="${BUILD_PROP_CONTENT}\n$DESCRIPTION_MOD"; fi
fi

# Langkah 4: Tulis konten `build.prop` yang telah disusun ke file overlay.
# File ini akan dimuat oleh Magisk/KernelSU sebagai bagian dari overlay sistem saat boot.
# Menggunakan `echo -e` untuk menginterpretasikan escape sequences (seperti `\n` untuk baris baru).
if [ -n "$BUILD_PROP_CONTENT" ]; then # Memeriksa apakah `BUILD_PROP_CONTENT` tidak kosong
    echo -e "$BUILD_PROP_CONTENT" > "$BUILD_PROP_PATH" # Menulis konten ke file
    # Langkah 5: Atur izin yang benar untuk `build.prop` overlay.
    # Izin 0644 (rw-r--r--) memungkinkan root membaca dan menulis, dan grup/lainnya hanya membaca.
    chmod 0644 "$BUILD_PROP_PATH"
    chown 0:0 "$BUILD_PROP_PATH" # Pastikan file dimiliki oleh pengguna root (UID 0) dan grup root (GID 0)
    log_message "  -> build.prop overlay baru berhasil dibuat dan disimpan di $BUILD_PROP_PATH."
else
    log_message "  -> Tidak ada properti build.prop yang diaktifkan. build.prop overlay tidak dibuat."
fi


# --- Logika Fitur Lain (Tidak Langsung Memodifikasi build.prop, tetapi Properti Runtime) ---

# Fitur 4: Mematikan Spoof PIF Bawaan ROM
# Jika file `pif_spoof_disable_enabled` ada, properti runtime sistem akan diatur
# untuk menonaktifkan mekanisme spoofing PIF (Play Integrity Fix) bawaan ROM.
# Ini berguna untuk modul yang menyediakan solusi PIF kustom.
if [ -f "$MODPATH/flags/pif_spoof_disable_enabled" ]; then
    log_message "  -> Fitur: Mematikan Spoof PIF bawaan ROM diaktifkan. Mengatur properti runtime..."
    # Perintah `setprop` digunakan untuk mengatur properti sistem secara dinamis saat runtime.
    # Properti ini langsung memengaruhi perilaku sistem tanpa perlu reboot untuk properti tertentu.
    setprop persist.sys.pihooks.disable.gms_props true # Menonaktifkan GMS properties hooks
    setprop persist.sys.pihooks.disable.gms_key_attestation_block true # Menonaktifkan GMS key attestation blocking
    log_message "  -> Properti PIF spoofing runtime telah diatur."
else
    log_message "  -> Fitur: Mematikan Spoof PIF bawaan ROM dinonaktifkan."
    # Jika fitur dimatikan, properti terkait diatur ke string kosong untuk menghapusnya atau mengembalikan ke nilai default.
    setprop persist.sys.pihooks.disable.gms_props "" 
    setprop persist.sys.pihooks.disable.gms_key_attestation_block ""
fi

log_message "Eksekusi post-fs-data.sh selesai."
