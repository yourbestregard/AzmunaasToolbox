#!/bin/sh

log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [SET_TARGET] $1"
}
log_message “Start setting target...”
t='/data/adb/tricky_store/target.txt'
tees='/data/adb/tricky_store/tee_status'

# tee status 
teeBroken="false"
if [ -f "$tees" ]; then
    teeBroken=$(grep -E '^teeBroken=' "$tees" | cut -d '=' -f2 2>/dev/null || echo "false")
fi

# add list special
echo "android" >> "$t"
echo "com.android.vending!" >> "$t"
echo "com.google.android.gms!" >> "$t"
echo "com.reveny.nativecheck!" >> "$t"
echo "io.github.vvb2060.keyattestation!" >> "$t"
echo "io.github.vvb2060.mahoshojo" >> "$t"
echo "icu.nullptr.nativetest" >> "$t"

# add list
log_message “Writing target...”
add_packages() {
    pm list packages "$1" | cut -d ":" -f 2 | while read -r pkg; do
        if [ -n "$pkg" ] && ! grep -q "^$pkg" "$t"; then
            if [ "$teeBroken" = "true" ]; then
                echo "$pkg!" >> "$t"
            else
                echo "$pkg" >> "$t"
            fi
        fi
    done
}

# add user apps
add_packages "-3"

# add system apps
add_packages "-s"
log_message “Finish setting target.”