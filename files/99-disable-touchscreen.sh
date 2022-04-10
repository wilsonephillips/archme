# This file must be placed in the following folder
# /etc/X11/xinit/xinitrc.d/99-disable-touchscreen.sh

Section "InputClass"
    Identifier  "Wacom HID 4861 Finger"
    MatchIsTouchscreen  "on"
    Option  "Ignore"    "on"
EndSection

Section "InputClass"
    Identifier  "Wacom HID 4861 Pen"
    MatchIsTouchscreen  "on"
    Option  "Ignore"    "on"
EndSection
