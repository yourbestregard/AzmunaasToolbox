#!/system/bin/sh
# service.sh
# Skrip ini dijalankan lebih lambat saat boot, setelah sebagian besar layanan sistem Android dimulai.
# Ini cocok untuk modifikasi yang membutuhkan layanan sistem penuh atau ketika modifikasi post-fs-data.sh
# mungkin terlalu dini.

MODPATH=/data/adb/modules/azmunaas_toolbox
WEBUI_ROOT="$MODPATH/webroot"
LOG_TAG="AzmunaasToolbox"

# Fungsi untuk mencatat pesan ke logcat
log_message() {
    log -t "$LOG_TAG" "$1"
}

log_message "Memulai eksekusi service.sh..."

# Pastikan busybox tersedia
if ! command -v busybox &> /dev/null; then
    log_message "Error: busybox tidak ditemukan. Tidak dapat memulai server WebUI."
    exit 1
fi

log_message "busybox ditemukan. Mencoba memulai server WebUI..."

# Coba port 8080, kemudian 8081, 8082, dst. hingga 8089
PORT=8080
MAX_PORT=8089
SERVER_STARTED=false

while [ $PORT -le $MAX_PORT ]; do
    log_message "Mencoba memulai server di port: $PORT"
    # Cek apakah port sudah digunakan
    # Netstat di busybox mungkin tidak mendukung -ntl, jadi gunakan cara lain
    # Alternatif: Coba bind dan tangkap error
    
    # Memulai server httpd di background
    # -p: port
    # -h: home directory (root for web files)
    # -v: verbose output (debug)
    # 2>&1: arahkan stderr ke stdout
    # & : jalankan di background
    busybox httpd -p "$PORT" -h "$WEBUI_ROOT" &> /dev/null &
    
    # Beri sedikit waktu agar server bisa memulai atau gagal
    sleep 1
    
    # Periksa apakah proses httpd berjalan dan mendengarkan di port yang benar
    # Menggunakan netstat dari busybox untuk memeriksa port yang sedang mendengarkan
    if busybox netstat -an | grep LISTEN | grep ":$PORT " &> /dev/null; then
        log_message "Server WebUI berhasil dimulai di http://localhost:$PORT atau http://<IP_Perangkat_Anda>:$PORT"
        echo "$PORT" > "$MODPATH/webui_port" # Simpan port yang digunakan
        SERVER_STARTED=true
        break
    else
        log_message "Port $PORT sudah digunakan atau gagal memulai server."
        killall busybox httpd 2>/dev/null # Bunuh proses httpd yang mungkin gagal tapi masih menggantung
        PORT=$((PORT + 1))
    fi
done

if [ "$SERVER_STARTED" = false ]; then
    log_message "Gagal memulai server WebUI pada semua port yang dicoba ($8080-$8089)."
    log_message "Pastikan tidak ada aplikasi lain yang menggunakan port ini atau coba reboot."
fi

log_message "Eksekusi service.sh selesai."