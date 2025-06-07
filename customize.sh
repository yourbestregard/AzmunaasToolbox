# Ini adalah skrip instalasi utama untuk modul Azmunaa's Toolbox.
# Skrip ini dijalankan oleh Magisk/KernelSU selama proses flashing modul.

# Pastikan MODPATH (jalur instalasi modul) telah didefinisikan oleh lingkungan Magisk/KernelSU.
MODPATH=$MODPATH

# Menampilkan informasi awal modul di log instalasi.
ui_print "*******************************"
ui_print "*     Azmunaa's Toolbox     *"
ui_print "*    By: Az-Har Muhamad Nayif  *"
ui_print "*******************************"
ui_print ""

# Memberi tahu pengguna bahwa file-file modul sedang disalin.
ui_print "- Menyalin file modul..."

# Membuat direktori yang diperlukan di dalam jalur instalasi modul ($MODPATH).
# Ini memastikan struktur direktori yang benar ada sebelum menyalin file.
mkdir -p "$MODPATH/system"    # Untuk overlay sistem (misal: build.prop, binari)
mkdir -p "$MODPATH/scripts"   # Untuk skrip-skrip yang dieksekusi oleh WebUI atau saat boot
mkdir -p "$MODPATH/webroot"   # Untuk file-file antarmuka web (HTML, CSS, JS)
mkdir -p "$MODPATH/flags"     # Mungkin digunakan untuk menandai status atau konfigurasi fitur
mkdir -p "$MODPATH/sound"     # Untuk file suara kustom (misal: suara pengisian daya)

# Menyalin semua file dari direktori sumber sementara ($TMPDIR) ke direktori instalasi modul ($MODPATH).
# $TMPDIR adalah direktori tempat isi ZIP modul diekstrak sementara selama instalasi.
cp -rf $TMPDIR/scripts/* "$MODPATH/scripts/"  # Menyalin skrip
cp -rf $TMPDIR/webroot/* "$MODPATH/webroot/"  # Menyalin file web
# Opsi '2>/dev/null || true' digunakan untuk mengabaikan kesalahan jika direktori sumber kosong.
cp -rf $TMPDIR/flags/* "$MODPATH/flags/" 2>/dev/null || true  # Menyalin flag
cp -rf $TMPDIR/sound/* "$MODPATH/sound/" 2>/dev/null || true  # Menyalin file suara

# Mengatur izin yang benar untuk file dan direktori modul.
ui_print "- Mengatur izin file..."
# set_perm_recursive adalah helper Magisk untuk mengatur izin secara rekursif.
# Argumen: path, uid, gid, dir_perm, file_perm
# 0 0: root user, root group
# 0755: izin direktori (rwxr-xr-x)
# 0644: izin file (rw-r--r--)
set_perm_recursive $MODPATH 0 0 0755 0644
# Mengatur izin eksekusi untuk skrip di direktori 'scripts'.
set_perm_recursive $MODPATH/scripts 0 0 0755 0755
# Mengatur izin eksekusi khusus untuk customize.sh itu sendiri.
set_perm $MODPATH/customize.sh 0 0 0755

# Memberi tahu pengguna bahwa instalasi selesai.
ui_print ""
ui_print "- Instalasi selesai. Silakan reboot perangkat Anda."
