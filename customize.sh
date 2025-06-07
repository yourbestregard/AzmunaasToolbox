#!/system/bin/sh
# customize.sh
#
# Skrip instalasi utama untuk modul Azmunaa's Toolbox.
# Skrip ini dijalankan oleh Magisk atau KernelSU selama proses flashing (instalasi/pembaruan) modul.
# Fungsinya adalah untuk menyiapkan struktur direktori modul, menyalin file yang diperlukan
# dari direktori sementara (tempat ZIP modul diekstrak) ke jalur instalasi permanen modul,
# dan mengatur izin file yang benar.

# Pastikan variabel lingkungan MODPATH telah didefinisikan oleh Magisk/KernelSU.
# MODPATH adalah jalur absolut ke direktori tempat modul akan diinstal di sistem.
MODPATH=$MODPATH

# ================================================
#  Informasi Modul dan Pesan ke Pengguna
# ================================================

# Menampilkan banner informasi modul di log instalasi recovery/terminal.
ui_print "*******************************" # Mencetak garis pemisah untuk visualisasi
ui_print "*     Azmunaa's Toolbox     *" # Nama modul
ui_print "*    By: Az-Har Muhamad Nayif  *" # Penulis modul
ui_print "*******************************" # Mencetak garis pemisah
ui_print "" # Mencetak baris kosong untuk jarak

# Memberi tahu pengguna bahwa proses penyalinan file akan dimulai.
ui_print "- Menyalin file modul..."

# ================================================
#  Pembuatan Struktur Direktori Modul
# ================================================

# Membuat direktori yang diperlukan di dalam jalur instalasi modul ($MODPATH).
# Perintah 'mkdir -p' akan membuat direktori hanya jika belum ada, dan juga akan membuat
# direktori induk yang tidak ada secara rekursif. Ini penting untuk memastikan struktur
# direktori yang benar ada sebelum menyalin file ke dalamnya.
mkdir -p "$MODPATH/system"    # Direktori untuk overlay sistem (misal: properti build.prop, binari sistem)
mkdir -p "$MODPATH/scripts"   # Direktori untuk skrip-skrip shell yang dieksekusi oleh WebUI atau saat boot sistem
mkdir -p "$MODPATH/webroot"   # Direktori untuk file-file antarmuka web (HTML, CSS, JavaScript) WebUI X
mkdir -p "$MODPATH/flags"     # Direktori untuk file bendera (flag files) yang menandai status atau konfigurasi fitur
mkdir -p "$MODPATH/sound"     # Direktori untuk file suara kustom (misal: suara pengisian daya kustom)

# ================================================
#  Penyalinan File Modul
# ================================================

# Menyalin semua file dan direktori secara rekursif (-r) dan memaksa penimpaan (-f)
# dari direktori sumber sementara ($TMPDIR) ke direktori instalasi modul ($MODPATH).
# $TMPDIR adalah direktori tempat isi ZIP modul diekstrak sementara oleh Magisk/KernelSU
# sebelum proses instalasi dimulai.
cp -rf $TMPDIR/scripts/* "$MODPATH/scripts/"  # Menyalin semua skrip dari TMPDIR/scripts ke MODPATH/scripts
cp -rf $TMPDIR/webroot/* "$MODPATH/webroot/"  # Menyalin semua file web dari TMPDIR/webroot ke MODPATH/webroot

# Menyalin file dari direktori flags dan sound. Opsi '2>/dev/null || true' digunakan untuk:
#   - '2>/dev/null': Mengalihkan pesan error (stderr) ke /dev/null (membuangnya).
#   - '|| true': Memastikan perintah 'cp' selalu mengembalikan nilai sukses (0), bahkan jika
#                direktori sumber kosong atau ada error minor, sehingga skrip tidak berhenti.
#                Ini berguna jika direktori 'flags' atau 'sound' mungkin kosong di ZIP modul.
cp -rf $TMPDIR/flags/* "$MODPATH/flags/" 2>/dev/null || true  # Menyalin file bendera
cp -rf $TMPDIR/sound/* "$MODPATH/sound/" 2>/dev/null || true  # Menyalin file suara

# ================================================
#  Pengaturan Izin File dan Direktori
# ================================================

# Memberi tahu pengguna bahwa izin file sedang diatur.
ui_print "- Mengatur izin file..."

# set_perm_recursive adalah fungsi pembantu (helper) yang disediakan oleh Magisk/KernelSU
# untuk mengatur izin file dan direktori secara rekursif di dalam jalur modul.
# Argumen yang digunakan:
#   $MODPATH: Jalur dasar direktori modul yang akan diatur izinnya.
#   0: UID (User ID) pemilik file/direktori. '0' berarti 'root'.
#   0: GID (Group ID) pemilik file/direktori. '0' berarti 'root'.
#   0755: Izin default untuk direktori (rwxr-xr-x): baca, tulis, eksekusi untuk pemilik; baca, eksekusi untuk grup dan lainnya.
#   0644: Izin default untuk file (rw-r--r--): baca, tulis untuk pemilik; baca untuk grup dan lainnya.
set_perm_recursive $MODPATH 0 0 0755 0644

# Mengatur izin eksekusi khusus untuk semua skrip di direktori 'scripts'.
# Izin direktori diatur ke 0755 dan izin file diatur ke 0755 (rwxr-xr-x) agar semua skrip dapat dieksekusi.
set_perm_recursive $MODPATH/scripts 0 0 0755 0755

# Mengatur izin eksekusi khusus untuk skrip customize.sh itu sendiri.
# Ini penting agar skrip ini dapat dijalankan oleh lingkungan Magisk/KernelSU.
# Argumen 'set_perm': path, uid, gid, perm (izin file/direktori tunggal).
set_perm $MODPATH/customize.sh 0 0 0755

# ================================================
#  Pesan Akhir Instalasi
# ================================================

# Memberi tahu pengguna bahwa instalasi telah selesai dan perangkat harus di-reboot.
ui_print ""
ui_print "- Instalasi selesai. Silakan reboot perangkat Anda."
