#!/bin/bash

ACTION="$1"
WIN=$(xdotool getactivewindow)

eval "$(xdotool getwindowgeometry --shell "$WIN")"

CX=$((X + WIDTH / 2))
CY=$((Y + HEIGHT / 2))

MON=$(xrandr | awk '/ connected/ && /[0-9]+x[0-9]+\+/ {
  for(i=1;i<=NF;i++){
    if($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/){
      split($i,a,"[x+]")
      print a[1],a[2],a[3],a[4]
    }
  }
}' | awk -v cx="$CX" -v cy="$CY" '
cx >= $3 && cx < $3+$1 && cy >= $4 && cy < $4+$2 {print $0; exit}
')

[ -z "$MON" ] && exit 1

read MW MH MX MY <<< "$MON"

case "$ACTION" in
  left)   NX=$MX;              NY=$MY;              NW=$((MW/2)); NH=$MH ;;
  right)  NX=$((MX+MW/2));     NY=$MY;              NW=$((MW/2)); NH=$MH ;;
  up)     NX=$MX;              NY=$MY;              NW=$MW;       NH=$((MH/2)) ;;
  down)   NX=$MX;              NY=$((MY+MH/2));     NW=$MW;       NH=$((MH/2)) ;;
  ul)     NX=$MX;              NY=$MY;              NW=$((MW/2)); NH=$((MH/2)) ;;
  ur)     NX=$((MX+MW/2));     NY=$MY;              NW=$((MW/2)); NH=$((MH/2)) ;;
  dl)     NX=$MX;              NY=$((MY+MH/2));     NW=$((MW/2)); NH=$((MH/2)) ;;
  dr)     NX=$((MX+MW/2));     NY=$((MY+MH/2));     NW=$((MW/2)); NH=$((MH/2)) ;;
  max)    NX=$MX;              NY=$MY;              NW=$MW;       NH=$MH ;;
  *) exit 1 ;;
esac

wmctrl -ir "$WIN" -b remove,maximized_vert,maximized_horz
wmctrl -ir "$WIN" -e "0,$NX,$NY,$NW,$NH"
