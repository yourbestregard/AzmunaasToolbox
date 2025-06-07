#!/system/bin/sh
# reboot.sh
#
# Skrip sederhana ini bertujuan untuk memicu proses reboot pada perangkat Android.
# Ini digunakan sebagai mekanisme fallback oleh WebUI jika `ApplicationInterface.reboot()`
# dari WebUI X tidak berhasil atau tidak tersedia.

# ================================================
#  Fungsi Logging
# ================================================

# Menggunakan `log -t` untuk mencatat pesan ke logcat Android dengan tag `AzmunaasToolbox`.
# Ini penting untuk memantau eksekusi skrip, terutama untuk tindakan kritis seperti reboot.
log -t "AzmunaasToolbox" "Menerima perintah reboot dari WebUI. Memicu reboot sekarang..."

# ================================================
#  Pemicu Reboot
# ================================================

# Perintah `reboot` akan menginstruksikan sistem Android untuk melakukan restart penuh.
# Skrip ini tidak memerlukan argumen tambahan dan akan langsung menjalankan perintah reboot.
reboot
