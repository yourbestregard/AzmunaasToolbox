#!/system/bin/sh

# Daftar properti yang akan diubah
PROPERTIES="
ro.product.vendor.model
ro.product.vendor.marketname
ro.product.vendor.cert
ro.product.system.marketname
ro.product.system.model
ro.product.model
ro.product.marketname
ro.product.odm.marketname
ro.product.odm.model
ro.product.product.marketname
ro.product.product.model
ro.soc.manufacturer
ro.soc.model
sys.fps_unlock_allowed
ro.build.fingerprint
"

# Setiap properti akan diupdate menggunakan resetprop
for prop in $PROPERTIES; do
    value=$(getprop $prop)
    new_value=$(grep "$prop=" "${MODPATH}/system.prop" | cut -d'=' -f2)
    [ ! -z "$new_value" ] && [ "$value" != "$new_value" ] && resetprop -n $prop "$new_value"
done