#!/bin/sh
cat <<EOF
if loadfont /boot/grub/unicode.pf2 ; then
  #set gfxmode="1280x1024,1024x768,800x600,640x480"
  set gfxmode="1024x768,800x600,640x480"
  insmod gfxterm
  insmod vbe
  if terminal_output gfxterm ; then true ; else
    # For backward compatibility with versions of terminal.mod that don't
    # understand terminal_output
    terminal gfxterm
  fi
fi

set locale_dir=/boot/grub/locale
set lang=ja
insmod gettext

#set menu_color_normal=white/black
#set menu_color_highlight=black/light-gray
set menu_color_normal=cyan/blue
set menu_color_highlight=white/blue

EOF
