#!/bin/sh
ui_print ""
ui_print "- HyperBrick: feel greatness of your animations on low-end device on HyperOS 2."
ui_print ""

# Verify compability with this module: check android version
verify_compability() {
    android_ver=$(getprop ro.build.version.release)
    ui_print "- Android version check... Current android version: Android $android_ver"
    if [ "$android_ver" -lt 15 ]; then
       abort "- ❌ Your Android version is not supported(Android $android_ver). Please, update to android 15 to use this module."
    else
       ui_print "- ✅ Congrats! Your Android $android_ver is supported!"
    fi
}

# Create a new direction in /data/adb, which is "HyperUnlocked"
set_variables() {
    RESDIR=/data/adb/HyperUnlocked
    mkdir -p $RESDIR
}

save_deviceLevelList() {
    echo ""
    echo "----------"
    echo ""
    ui_print "- Saving deviceLevelList backup..."
    if [ -s "$RESDIR/default_deviceLevelList.txt" ]; then
       ui_print "- ✅ Skipping deviceLevelList backup. The backup file already exists and is more than 0 bytes."
       return
    fi
    device_level_list=$(su -c "settings get system deviceLevelList")
    if [ -z "$device_level_list" ] || [ "$device_level_list" = "null" ]; then
       ui_print "- ❌ Skipping deviceLevelList backup. Failed to create a backup."
    else
       echo "$device_level_list" > "$RESDIR/default_deviceLevelList.txt"
       ui_print "- ✅ Default deviceLevelList saved: \`$(cat "$RESDIR/default_deviceLevelList.txt")\`"
    fi
    ui_print "- ✅ DeviceLevelList backup saved!"
}

set_highend() {
    new_value="v:1,c:3,g:3"
    ui_print "- Updating deviceLevelList to: \`$new_value\`..."
    if su -c "settings put system deviceLevelList $dev_level_new_value"; then
       ui_print "- ✅ Successfully updated deviceLevelList!"
    else
       ui_print "- ❌ Failed to update deviceLevelList."
    fi
}

restore_deviceLevelList() {
    echo "-"
    if [ -f "$RESDIR/default_deviceLevelList.txt" ]; then
       saved_value=$(cat "$RESDIR/default_deviceLevelList.txt")
       ui_print "- Restore deviceLevelList to: \`$saved_value\`..."
       if su -c "settings put system deviceLevelList $saved_value"; then
           ui_print "- Successfully restored deviceLevelList."
           rm -rf "$RESDIR"
       else
           ui_print "- ❌ Failed to restore deviceLevelList."
       fi
    else
       ui_print "- ❌ No saved deviceLevelList found. Skipping restore."
    fi
    ui_print "- ✅ Restore deviceLevelList successfully!"
}
install_custom_launcher() {
    ui_print "- Welcome to installation wizard."
    ui_print " "
    ui_print "- Installation wizard: custom launcher installation"
    . $MODPATH/addon/install.sh
    ui_print "- Step 1. Do you want to install custom launcher(by Mods Center)? [XIAOMI & POCO]"
    ui_print "  Vol ➕ = Yes"
    ui_print "  Vol ➖ = No"
    ui_print " "
    if chooseport; then
        ui_print "- ✅ Yes selected, installing custom launcher..."
        # Package names
        miui_package="com.miui.home"
        poco_package="com.mi.android.globallauncher"

        # Uninstall updates safely
        pm uninstall-system-updates "$miui_package" >/dev/null 2>&1
        miui_path=$(pm path "$miui_package" | sed 's/package://')

        pm uninstall-system-updates "$poco_package" >/dev/null 2>&1
        poco_path=$(pm path "$poco_package" | sed 's/package://')

        if [ -n "$miui_path" ]; then
            launcher_folder=$(dirname "$miui_path" | sed 's/\/system//')
            launcher_name_current=$(basename "$miui_path" | sed 's/.apk//')
        elif [ -n "$poco_path" ]; then
            launcher_folder=$(dirname "$poco_path" | sed 's/\/system//')
            launcher_name_current=$(basename "$poco_path" | sed 's/.apk//')

            # Ensure overlay path exists before copying
            mkdir -p "$MODPATH/system/product/overlay"
            cp -f "$MODPATH/files/MiuiPocoLauncherResOverlay.apk" "$MODPATH/system/product/overlay"
        else
            ui_print "- ❌ Launcher package not found! Exiting..."
            return 1
        fi

        # Ensure the launcher folder exists
        mkdir -p "$MODPATH/system$launcher_folder"

        # Rename and move the launcher APK
        if [ -f "$MODPATH/files/launcher/SystemLauncher.apk" ]; then
            mv "$MODPATH/files/launcher/SystemLauncher.apk" "$MODPATH/files/launcher/$launcher_name_current.apk"
            cp -f "$MODPATH/files/launcher/$launcher_name_current.apk" "$MODPATH/system$launcher_folder"
        
            # Install the launcher to ensure it is applied
            pm install -r "$MODPATH/system$launcher_folder/$launcher_name_current.apk" >/dev/null 2>&1
        else
            ui_print "- ❌ Launcher APK not found! Exiting..."
            return 1
        fi

        # Modify init.rc safely
        SRC_FILE="/system/etc/init/hw/init.rc"
        DEST_FILE="$MODPATH/system/etc/init/hw/init.rc"

        if [ -f "$SRC_FILE" ]; then
            if grep -q 'com\.mi\.android\.globallauncher' "$SRC_FILE"; then
                mkdir -p "$(dirname "$DEST_FILE")"
                cp "$SRC_FILE" "$DEST_FILE"
                sed -i 's/com\.mi\.android\.globallauncher/com.miui.home/g' "$DEST_FILE"
            fi
        fi
    else
    {
        ui_print "- ❌ No selected, skipping custom launcher installation..."
    }
    fi
}
install_custom_theme_mgr() {
    ui_print " "
    ui_print "- Installation wizard: custom theme manager installation"
    . $MODPATH/addon/install.sh
    ui_print "- Step 2. Do you want to install custom theme manager(by Mods Center)? [XIAOMI & POCO]"
    ui_print "  Vol ➕ = Yes"
    ui_print "  Vol ➖ = No"
    ui_print " "
    if chooseport; then
        ui_print "- ✅ Yes selected, installing custom launcher..."
        # Package name
        theme_mgr_package="com.android.thememanager"

        # Uninstall updates safely
        pm uninstall-system-updates "$theme_mgr_package" >/dev/null 2>&1
        theme_mgr_path=$(pm path "$theme_mgr_package" | sed 's/package://')

        if [ -n "$theme_mgr_path" ]; then
            mgr_folder=$(dirname "$theme_mgr_path" | sed 's/\/system//')
            mgr_name_current=$(basename "$theme_mgr_path" | sed 's/.apk//')
        else
            ui_print "- ❌ Theme manager package not found! Exiting..."
            return 1
        fi

        # Ensure the theme manager folder exists
        mkdir -p "$MODPATH/system$mgr_folder"

        # Rename and move the theme manager APK
        if [ -f "$MODPATH/files/theme_manager/MIUIThemeManager.apk" ]; then
            mv "$MODPATH/files/theme_manager/MIUIThemeManager.apk" "$MODPATH/files/theme_manager/$mgr_name_current.apk"
            cp -f "$MODPATH/files/theme_manager/$mgr_name_current.apk" "$MODPATH/system$mgr_folder"
        
            # Install the theme manager to ensure it is applied
            pm install -r "$MODPATH/system$mgr_folder/$mgr_name_current.apk" >/dev/null 2>&1
        else
            ui_print "- ❌ Theme manager APK not found! Exiting..."
            return 1
        fi
    else
    {
        ui_print "- ❌ No selected, skipping custom theme manager installation..."
    }
    fi
}

install_custom_security_center() {
    ui_print " "
    ui_print "- Installation wizard: custom security center installation"
    . $MODPATH/addon/install.sh
    ui_print "- Step 3. Do you want to install custom security center(by Mods Center)? [XIAOMI & POCO]"
    ui_print "  Vol ➕ = Yes"
    ui_print "  Vol ➖ = No"
    ui_print " "
    if chooseport; then
        ui_print "- ✅ Yes selected, installing custom launcher..."
        # Package name
        security_cntr_package="com.miui.securitycenter"

        # Uninstall updates safely
        pm uninstall-system-updates "$security_cntr_package" >/dev/null 2>&1
        security_cntr_path=$(pm path "$security_cntr_package" | sed 's/package://')

        if [ -n "$security_cntr_path" ]; then
            security_cntr_folder=$(dirname "$security_cntr_path" | sed 's/\/system//')
            security_cntr_name_current=$(basename "$security_cntr_path" | sed 's/.apk//')
        else
            ui_print "- ❌ Security center package not found! Exiting..."
            return 1
        fi

        # Ensure the security center folder exists
        mkdir -p "$MODPATH/system$security_cntr_folder"

        # Rename and move the security center APK
        if [ -f "$MODPATH/files/security_center/SecurityCenter.apk" ]; then
            mv "$MODPATH/files/security_center/SecurityCenter.apk" "$MODPATH/files/security_center/$security_cntr_name_current.apk"
            cp -f "$MODPATH/files/security_center/$security_cntr_name_current.apk" "$MODPATH/system$security_cntr_folder"
        
            # Install the security center to ensure it is applied
            pm install -r "$MODPATH/system$security_cntr_folder/$security_cntr_name_current.apk" >/dev/null 2>&1
        else
            ui_print "- ❌ Security center APK not found! Exiting..."
            return 1
        fi
    else
    {
        ui_print "- ❌ No selected, skipping custom security center installation..."
    }
    fi
}

install_custom_control_center() {
    ui_print " "
    ui_print "- Installation wizard: custom control center installation"
    . $MODPATH/addon/install.sh
    ui_print "- Step 4. Do you want to install custom control center(by evo mods)?"
    ui_print "  Vol ➕ = Yes"
    ui_print "  Vol ➖ = No"
    ui_print " "
    if chooseport; then
        . $MODPATH/addon/install.sh
        ui_print "- ✅ Yes selected, installing custom control center..."

        # Package name
        control_cntr_package="miui.systemui.plugin"

        # Uninstall updates safely
        pm uninstall-system-updates "$control_cntr_package" >/dev/null 2>&1
        control_cntr_path=$(pm path "$control_cntr_package" | sed 's/package://')

        if [ -n "$control_cntr_path" ]; then
            control_cntr_folder=$(dirname "$control_cntr_path" | sed 's/\/system//')
            control_cntr_name_current=$(basename "$control_cntr_path" | sed 's/.apk//')
        else
            ui_print "- ❌ Control center package not found! Exiting..."
            return 1
        fi

        # Ensure the security center folder exists
        mkdir -p "$MODPATH/system$control_cntr_folder"

        # Rename and move the security center APK
        if [ -f "$MODPATH/files/control_center/[iOS]V43-EvoMods-Plugin.apk" ]; then
            mv "$MODPATH/files/control_center/[iOS]V43-EvoMods-Plugin.apk" "$MODPATH/files/control_center/$control_cntr_name_current.apk"
            cp -f "$MODPATH/files/control_center/$control_cntr_name_current.apk" "$MODPATH/system$control_cntr_folder"
        
            # Install the security center to ensure it is applied
            pm install -r "$MODPATH/system$control_cntr_folder/$control_cntr_name_current.apk" >/dev/null 2>&1
        else
            ui_print "- ❌ Control center APK not found! Exiting..."
            return 1
        fi
    else
    {
        ui_print "- ❌ No selected, skipping custom control center installation..."
    }
    fi
}   

install_custom_sounds_boot() {
    ui_print " "
    ui_print "- Installation wizard: custom boot animation & sounds installation"
    . $MODPATH/addon/install.sh
    ui_print "- Step 5. Do you want to install custom boot animation & sounds?"
    ui_print "  Vol ➕ = Yes"
    ui_print "  Vol ➖ = No"
    ui_print " "
    if chooseport; then
        ui_print "- ✅ Yes selected, installing custom boot animation & sounds..."
        unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2
        ui_print "- ✅ Mods installation done!"
    else
    {
        ui_print "- ❌ No selected, skipping custom boot animation & sounds installation..."
        ui_print "- ✅ Mods installation done!"
    }
    fi
}

set_permissions() {
    echo ""
    echo "----------"
    echo ""
    echo "- Setting permissions to launcher..."
    su -c "pm grant com.miui.home android.permission.READ_MEDIA_IMAGES" >/dev/null 2>&1
    su -c "pm grant com.miui.home android.permission.ACCESS_CONTEXTUAL_SEARCH" >/dev/null 2>&1
    echo "- ✅ Applied permissions to launcher!"
    echo "- Setting permissions to theme manager..."
    su -c "pm grant com.android.thememanager android.permission.READ_MEDIA_IMAGES" >/dev/null 2>&1
    su -c "pm grant com.android.thememanager android.permission.POST_NOTIFICATIONS" >/dev/null 2>&1
    su -c "pm grant com.android.thememanager android.permission.READ_MEDIA_AUDIO" >/dev/null 2>&1
    echo "- ✅ Applied permissions to theme manager!"
    echo "- Setting permissions to security center..."
    su -c "pm grant com.miui.securitycenter android.permission.READ_CONTACTS" >/dev/null 2>&1
    su -c "pm grant com.miui.securitycenter android.permission.READ_CALL_LOG" >/dev/null 2>&1
    su -c "pm grant com.miui.securitycenter android.permission.POST_NOTIFICATIONS" >/dev/null 2>&1
    su -c "pm grant com.miui.securitycenter android.permission.READ_SMS" >/dev/null 2>&1
    echo "- ✅ Applied permissions to security center!"
    set_perm_recursive "$MODPATH" 0 0 0755 0644
}

cleanup() {
    echo "- Cleaning up...."
    rm -rf "$MODPATH/files" 2>/dev/null
    rm -rf /data/resource-cache/* /data/system/package_cache/* /cache/* /data/dalvik-cache/*
    touch "$MODPATH/hyperoslaunchermod/remove"
}


credits() {
    echo ""
    echo "----------"
    echo ""
    ui_print "- HyperBrick by RickAstley"
    ui_print ""
    ui_print "- Compatible with HyperOS 2"
    ui_print ""
    ui_print "- Disable 'Unmount Modules' in KernelSU settings to prevent issues."
    ui_print ""
    ui_print "- Big thanks to VizXtrenme!"
    ui_print "- https://github.com/VizXtreme"
    ui_print ""
    ui_print "- Big thanks to urkiu!"
    ui_print "- https://github.com/ukriu"
    ui_print ""
    ui_print "- Thanks for Mods center for volume select feature and custom apps included here."
    ui_print ""
    ui_print "- Thanks for Evo Mods for custom control center."
    ui_print "- https://t.me/ProjectEvolexia"
    ui_print ""
    ui_print "- Check out my GitHub: https://github.com/xnggypr"
    ui_print ""
    ui_print "- Ping me in my Telegram, if any problems: https://t.me/xnggypr"
    ui_print ""
    ui_print "- Thank you for using HyperBrick :D!"
    ui_print ""
    ui_print "- HyperBrick: feel greatness of your animations on low-end device on HyperOS 2."
    ui_print ""
    ui_print "- ✅ Installation complete! Please reboot device to enjoy the module."
}

#EOF
