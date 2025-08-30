#!/system/bin/sh
# Skrip ini berjalan pada tahap awal proses boot.

# Mengubah properti sistem untuk menonaktifkan keamanan otorisasi ADB.
# Ini memungkinkan koneksi ADB dari komputer manapun tanpa perlu pop-up konfirmasi.
resetprop ro.adb.secure 0

# Mengubah properti agar ADB shell langsung berjalan sebagai root.
# Ini membantu untuk akses penuh tanpa perlu mengetik 'su' lagi.
resetprop service.adb.root 1
