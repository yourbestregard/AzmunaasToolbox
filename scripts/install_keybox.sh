#!/system/bin/sh
# install_keybox.sh
log_message() {
    TIMESTAMP=$(date +%Y-%m-%d\ %H:%M:%S)
    MESSAGE="$1"
    echo "$TIMESTAMP [SCRIPT] $MESSAGE"
    echo "$TIMESTAMP [SCRIPT] $MESSAGE" >> "/data/adb/modules/azmunaas_toolbox/executor_log.txt" 2>&1
}
log_message "Loading...."
# Skrip ini bertanggung jawab untuk mengunduh dan memasang file keybox.xml yang valid.
# File keybox ini penting untuk beberapa modifikasi sistem, terutama terkait Play Integrity Fix (PIF)
# atau sertifikasi perangkat.
# Skrip ini akan melakukan backup file keybox yang sudah ada (jika ada) sebelum mengunduh yang baru.

# ================================================
#  Definisi Variabel
# ================================================

# Jalur instalasi modul, disediakan oleh lingkungan Magisk/KernelSU.
MODPATH=/data/adb/modules/azmunaas_toolbox
# Direktori tempat file keybox akan disimpan.
KEYBOX_DIR="/data/adb/trickystore"
# Jalur lengkap untuk file keybox.xml yang akan dipasang.
KEYBOX_FILE="$KEYBOX_DIR/keybox.xml"
# Jalur untuk file backup keybox.xml yang sudah ada.
KEYBOX_BACKUP_FILE="$KEYBOX_DIR/keybox_backup.xml"
# URL tempat file valid.xml (keybox baru) akan diunduh.
# Perhatikan: URL ini mungkin perlu diperbarui jika sumber file berubah.
KEYBOX_URL="https://raw.githubusercontent.com/yourbestregard/AzmunaasToolbox/refs/heads/main/valid.xml?token=GHSAT0AAAAAADFHWCVHULYIWA3O6SXNOO522CDWPIA"

# ================================================
#  Fungsi Logging
# ================================================

# Fungsi log_message digunakan untuk mencatat pesan status ke stdout.
# Pesan ini akan ditangkap oleh executor.sh dan kemudian ditampilkan di WebUI.
log_message() {
    # Menggunakan echo dengan format waktu dan tag spesifik untuk keybox.
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [Keybox] $1"
}

# ================================================
#  Logika Utama Skrip
# ================================================

log_message "Memulai instalasi Keybox Valid..."

# Buat direktori keybox jika belum ada.
# Opsi -p memastikan bahwa direktori induk juga dibuat jika tidak ada.
mkdir -p "$KEYBOX_DIR"

# Periksa apakah file keybox.xml sudah ada.
if [ -f "$KEYBOX_FILE" ]; then
    log_message "Keybox.xml sudah ada, membackupnya ke keybox_backup.xml"
    # Pindahkan (mv) file keybox.xml yang ada ke file backup.
    mv "$KEYBOX_FILE" "$KEYBOX_BACKUP_FILE"
    # Periksa kode keluar dari perintah mv.
    if [ $? -eq 0 ]; then # $? berisi kode keluar dari perintah terakhir (0 = sukses, >0 = gagal)
        log_message "Backup berhasil."
    else
        log_message "Gagal membackup keybox.xml. Instalasi dibatalkan."
        exit 1 # Keluar dari skrip dengan kode error
    fi
fi

log_message "Mengunduh keybox.xml..."
# Menggunakan curl atau wget untuk mengunduh file.
# Skrip akan mencoba curl terlebih dahulu, jika tidak tersedia, akan mencoba wget.
# command -v <perintah> memeriksa apakah perintah tersebut ada di PATH sistem.
# >/dev/null 2>&1 mengalihkan stdout dan stderr ke /dev/null agar tidak membanjiri log.
if command -v curl >/dev/null 2>&1; then
    # curl -sL: -s (silent) menyembunyikan progress meter, -L mengikuti redirect.
    # -o <file>: menyimpan output ke file yang ditentukan.
    curl -sL "$KEYBOX_URL" -o "$KEYBOX_FILE"
elif command -v wget >/dev/null 2>&1; then
    # wget -qO: -q (quiet) menyembunyikan output, -O menyimpan ke file yang ditentukan.
    wget -qO "$KEYBOX_FILE" "$KEYBOX_URL"
else
    # Jika tidak ada curl atau wget yang ditemukan, catat error dan keluar.
    log_message "Error: curl atau wget tidak ditemukan. Tidak dapat mengunduh keybox.xml."
    exit 1
fi

# Verifikasi hasil pengunduhan.
# $? -eq 0: Perintah terakhir sukses.
# -f "$KEYBOX_FILE": File ada dan merupakan file biasa.
# -s "$KEYBOX_FILE": File ada dan tidak kosong.
if [ $? -eq 0 ] && [ -f "$KEYBOX_FILE" ] && [ -s "$KEYBOX_FILE" ]; then
    log_message "Keybox.xml berhasil diunduh dan disimpan di $KEYBOX_FILE."
    # Atur izin file agar dapat dibaca oleh sistem (rw-r--r--).
    chmod 0644 "$KEYBOX_FILE"
    log_message "Izin keybox.xml diatur ke 0644."
else
    log_message "Error: Gagal mengunduh atau memverifikasi keybox.xml. File mungkin rusak atau tidak ada."
    exit 1 # Keluar dari skrip dengan kode error
fi

log_message "Instalasi Keybox Valid selesai."
