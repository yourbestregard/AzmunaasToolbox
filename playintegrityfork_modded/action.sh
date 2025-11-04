MODPATH="${0%/*}"

# ensure not running in busybox ash standalone shell
set +o standalone
unset ASH_STANDALONE

sh $MODPATH/mod/set_target.sh 2>&1
sh $MODPATH/mod/install_keybox.sh 2>&1
sh $MODPATH/autopif2.sh -m || exit 1

echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Closing dialog in 5 seconds.."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) (⁠*⁠＾⁠3⁠＾⁠)⁠/⁠～⁠♡ Happy Meets Strong Integrity!"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Are you not pass strong integrity? try changing the spoof settings in /data/adb/modules/playintegrityfix/custom.pif.json"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Run killpi.sh as root every time you make changes to the spoof custom.pif settings"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 1) spoofBuild: 1, spoofProps: 1, spoofProvider: 0, spoofSignature: 0, spoofVendingFinger: 0, spoofVendingSdk: 0, verboseLogs=0."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 2) spoofBuild: 1, spoofProps: 1, spoofProvider: 0, spoofSignature: 0, spoofVendingFinger: 1, spoofVendingSdk: 0, verboseLogs=0."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 3) spoofBuild: 1, spoofProps: 1, spoofProvider: 0, spoofSignature: 1, spoofVendingFinger: 1, spoofVendingSdk: 0, verboseLogs=0."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 4) spoofBuild: 1, spoofProps: 1, spoofProvider: 1, spoofSignature: 0, spoofVendingFinger: 1, spoofVendingSdk: 0, verboseLogs=0."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 5) spoofBuild: 1, spoofProps: 1, spoofProvider: 1, spoofSignature: 1, spoofVendingFinger: 1, spoofVendingSdk: 0, verboseLogs=0."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 6) spoofBuild: 1, spoofProps: 1, spoofProvider: 1, spoofSignature: 1, spoofVendingFinger: 1, spoofVendingSdk: 1, verboseLogs=0."
sleep 5
sh $MODDIR/mod/redirect.sh 2>&1