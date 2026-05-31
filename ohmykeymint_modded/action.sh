MODDIR="/data/adb/modules/oh_my_keymint"

su -c "sh $MODDIR/mod/set_scope.sh 2>&1"
su -c "sh $MODDIR/mod/install_keybox.sh 2>&1"
su -c "sh $MODDIR/mod/restart_omk.sh 2>&1"
# su -c "sh $MODDIR/mod/update_checker.sh 2>&1"

echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Closing dialog in 5 seconds.."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) (⁠*⁠＾⁠3⁠＾⁠)⁠/⁠～⁠♡ Happy Meets Strong Integrity!"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Are you not pass strong integrity? Don't worry, just wait for 5 seconds and click the button to open the author's page for more information and support. Thank you for using this module! <3"
sleep 5
su -c "sh $MODDIR/mod/redirect.sh 2>&1"

