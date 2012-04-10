#!/bin/sh

# This file is used as a .xsession.

export LANG=fr_FR.utf8
export LC_MESSAGES=en_US.utf8
export GTK2_RC_FILES=$HOME/.gtkrc-2.0
[ -n "$HOSTDISPLAY" ] || export HOSTDISPLAY="$(uname -n)$DISPLAY"

# If not done, restart ourself within gnome-session
[ -n "$SESSION_MANAGER" ] || {
    [ -d ~/.config/autostart ] || mkdir ~/.config/autostart
    rm -f ~/.config/autostart/*
    cat <<EOF > ~/.config/autostart/xsession.desktop
[Desktop Entry]
Name=Xsession
Comment=Start .xsession
Exec=$(readlink -f $0)
Type=Application
X-GNOME-Autostart-enabled=true
EOF
    exec gnome-session --autostart=$HOME/.config/autostart
}

# Fix XAuthority handling with GDM3
[ "$XAUTHORITY" = $HOME/.Xauthority ] || {
    XAUTHORITY=$HOME/.Xauthority xauth merge $XAUTHORITY
    export XAUTHORITY=$HOME/.Xauthority
}

# Run a composition manager if available
[ -x /usr/bin/xcompmgr ] && xcompmgr &

# And run pulseaudio
[ -x /usr/bin/pulseaudio ] && {
    pulseaudio --check || pulseaudio -D
}

# Configure GNOME stuff
[ -x /usr/bin/dconf ] && {
    # Don't allow gnome-settings-daemon to override our configuration
    for plugin in power background housekeeping keyboard \
	mouse updates xrandr; do
	dconf write /org/gnome/settings-daemon/plugins/${plugin}/active false
    done
    # Screensaver stuff
    dconf write /org/gnome/desktop/session/idle-delay "uint32 180"
    dconf write /org/gnome/desktop/screensaver/lock-delay "uint32 180"
    dconf write /org/gnome/desktop/screensaver/lock-enabled true
    dconf write /org/gnome/desktop/screensaver/user-switch-enabled false

    # Eye candy and GTK
    dconf write /org/gnome/settings-daemon/plugins/xsettings/antialiasing "'rgba'"
    dconf write /org/gnome/desktop/interface/font-name "'Cantarell 10'"
    dconf write /org/gnome/desktop/interface/gtk-key-theme "'Emacs'"
    dconf write /org/gnome/desktop/interface/gtk-theme "'Hope'"
    dconf write /org/gnome/desktop/interface/cursor-theme "'oxy-cherry'"
    dconf write /org/gnome/desktop/interface/buttons-have-icons true
    dconf write /org/gnome/desktop/interface/can-change-accels true
    dconf write /org/gnome/desktop/interface/menus-have-icons true
}

/usr/lib/gnome-settings-daemon/gnome-settings-daemon &
/usr/lib/notification-daemon/notification-daemon &
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
gnome-screensaver &
xfce4-power-manager &
bluetooth-applet &

# Host-specific configuration
case "$HOSTDISPLAY" in
  neo:*)
    xset m 3 3
    setxkbmap us "" compose:rwin
    xmodmap -e "keysym Pause = XF86ScreenSaver"
    xrandr --output  VGA-0 --auto --output DVI-0 --auto --right-of VGA-0
    transmission-gtk &
    keepassx &
    pidgin &
    ;;
  guybrush:*)
    ~/.fvwm/scripts/xrandr-auto.sh
    setxkbmap us "" compose:ralt
    xmodmap -e "keysym XF86AudioPlay = XF86ScreenSaver"
  # Wheel emulation using third button
    xinput set-int-prop "TPPS/2 IBM TrackPoint" \
      "Evdev Wheel Emulation" 8 1
    xinput set-int-prop "TPPS/2 IBM TrackPoint" \
      "Evdev Wheel Emulation Button" 8 2
    xinput set-int-prop "TPPS/2 IBM TrackPoint" \
      "Evdev Wheel Emulation Axes" 8 6 7 4 5
  # Disable touchpad
    xinput set-int-prop "SynPS/2 Synaptics TouchPad" \
      "Synaptics Off" 8 1
    /usr/sbin/rfkill block all
    nm-applet &
    keepassx &
    ;;
  naruto:*)
    xset m 4 3
    setxkbmap us "" compose:rwin
    xmodmap -e "keysym Pause = XF86ScreenSaver"
    xrandr --output VGA1 --auto --output DVI1 --auto --left-of VGA1
    ;;
esac

# Fix a X vulnerability
xmodmap -e 'keysym 0x1008fe21 = KP_Multiply'

xset r
xset -b

# Conky
case "$HOSTDISPLAY" in
  *:1*)
    ;;
  *)
    for conf in ~/.conky/${HOSTDISPLAY%:*}/*.rc ; do
      conky -c "$conf" -d -p 5 &
    done
    ;;
esac

# Run FVWM. Restart does not seem to work as expected when running in
# gnome-session. Just emulate it.
while true; do
  fvwm -f /usr/share/fvwm-crystal/fvwm/config
  sleep 1
  [ -f ~/.fvwm/.fs-restart-$HOSTDISPLAY ] || break
done

# We will never stop if gnome-session is still running
[ x"$(cat /proc/$PPID/comm)" = x"gnome-session" ] && kill $PPID
