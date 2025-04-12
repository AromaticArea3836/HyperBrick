#!/bin/sh
if ! $BOOTMODE; then
    ui_print ""
    ui_print "- HyperBrick: feel greatness of your animations on low-end device on HyperOS 2."
    ui_print ""
    ui_print "- Sorry, but recovery install is not supported."
    ui_print "- Please install from the Magisk / KernelSU / APatch app."
fi

. $MODPATH/utils.sh
    verify_compability
    set_variables
    save_deviceLevelList
    set_highend
    install_custom_launcher
    install_custom_theme_mgr
    install_custom_security_center
    install_custom_control_center
    install_custom_sounds_boot
    set_permissions
    cleanup
    credits
#EOF