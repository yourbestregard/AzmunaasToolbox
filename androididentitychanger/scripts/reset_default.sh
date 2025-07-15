#!/system/bin/sh

PROP_FILE="/data/adb/modules/androididentitychanger/system.prop"

if [ -f "$PROP_FILE" ]; then
    > "$PROP_FILE"
fi
