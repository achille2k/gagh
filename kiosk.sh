#!/bin/bash
mv /etc/xdg/openbox/autostart /etc/xdg/openbox/autostart.old
cat > /etc/xdg/openbox/autostart <<EOF
#
# These things are run when an Openbox X Session is started.
# You may place a similar script in \$HOME/.config/openbox/autostart
# to run user-specific things.
#

# If you want to use GNOME config tools...
#
#if test -x /usr/lib/x86_64-linux-gnu/gnome-settings-daemon >/dev/null; then
#  /usr/lib/x86_64-linux-gnu/gnome-settings-daemon &
#elif which gnome-settings-daemon >/dev/null 2>&1; then
#  gnome-settings-daemon &
#fi

# If you want to use XFCE config tools...
#
#xfce-mcs-manager &
# 
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
ibus-daemon -d -x
#
/opt/gagh/GAGH &
EOF

mv /etc/gdm3/custom.conf /etc/gdm3/custom.conf.old
cat > /etc/gdm3/custom.conf <<EOF
# GDM configuration storage
#
# See /usr/share/gdm/gdm.schemas for a list of available options.

[daemon]
AutomaticLoginEnable=true
AutomaticLogin=soho

# Uncomment the line below to force the login screen to use Xorg
#WaylandEnable=false

# Enabling automatic login

# Enabling timed login
#  TimedLoginEnable = true
#  TimedLogin = user1
#  TimedLoginDelay = 10

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
# More verbose logs
# Additionally lets the X server dump core if it crashes
#Enable=true

EOF

rm -rf /var/lib/AccountsService/users/soho
cat > /var/lib/AccountsService/users/soho <<EOF
[InputSource0]
xkb=us

[User]
XSession=openbox
SystemAccount=false
EOF

mv /etc/xdg/openbox/menu.xml /etc/xdg/openbox/menu.xml.old
cat > /etc/xdg/openbox/menu.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>

<openbox_menu xmlns="http://openbox.org/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://openbox.org/
                file:///usr/share/openbox/menu.xsd">

<menu id="root-menu" label="Openbox 3">
</menu>

</openbox_menu>
EOF

# disable key
sudo wget -q https://raw.githubusercontent.com/achille2k/gagh/main/rc.xml -O /etc/xdg/openbox/rc.xml > /dev/null 2>&1

# disable autoupdate
rm -rf /etc/apt/apt.conf.d/20auto-upgrades
cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "1";
EOF