#!/sbin/sh

OUTFD=/proc/self/fd/$2
ui_print() { echo -e "ui_print $1\n" > $OUTFD; }

# [1] Buat folder ksu dan symlink
mkdir -p "$MODPATH/ksu"
ln -sf "../module.prop" "$MODPATH/ksu/module.prop"

# [2] Operasi lain
ui_print "Installing Xiaomi 14 Ultra module..."