#!/bin/bash

DIR="$1"
WIN=$(xdotool getactivewindow)

eval "$(xdotool getwindowgeometry --shell "$WIN")"

CX=$((X + WIDTH / 2))
CY=$((Y + HEIGHT / 2))

MONS=$(xrandr | awk '/ connected/ && /[0-9]+x[0-9]+\+/ {
  for(i=1;i<=NF;i++){
    if($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/){
      split($i,a,"[x+]")
      print a[1],a[2],a[3],a[4]
    }
  }
}')

CUR=$(echo "$MONS" | awk -v cx="$CX" -v cy="$CY" '
cx >= $3 && cx < $3+$1 && cy >= $4 && cy < $4+$2 {print $0; exit}
')

[ -z "$CUR" ] && exit 1

read CW CH CX0 CY0 <<< "$CUR"
CCX=$((CX0 + CW / 2))
CCY=$((CY0 + CH / 2))

TARGET=$(echo "$MONS" | awk -v dir="$DIR" -v ccx="$CCX" -v ccy="$CCY" '
{
  mw=$1; mh=$2; mx=$3; my=$4;
  tx=mx+mw/2; ty=my+mh/2;
  dx=tx-ccx; dy=ty-ccy;
  ok=0;
  if(dir=="left"  && dx<0) ok=1;
  if(dir=="right" && dx>0) ok=1;
  if(dir=="up"    && dy<0) ok=1;
  if(dir=="down"  && dy>0) ok=1;
  if(ok){
    dist=(dx*dx)+(dy*dy);
    if(best=="" || dist<best){best=dist; line=$0}
  }
}
END{print line}
')

[ -z "$TARGET" ] && exit 0

read TW TH TX TY <<< "$TARGET"

NX=$((TX + (TW - WIDTH) / 2))
NY=$((TY + (TH - HEIGHT) / 2))

wmctrl -ir "$WIN" -b remove,maximized_vert,maximized_horz
wmctrl -ir "$WIN" -e "0,$NX,$NY,$WIDTH,$HEIGHT"
