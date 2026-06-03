#!/bin/bash

ACTION="$1"
WIN=$(xdotool getactivewindow)

eval "$(xdotool getwindowgeometry --shell "$WIN")"

CENTER_X=$((X + WIDTH / 2))
CENTER_Y=$((Y + HEIGHT / 2))

MONITOR=$(xrandr --listmonitors | tail -n +2 | awk '
{
  geom=$3
  sub(/\*.*/, "", geom)
  split(geom,p,"+")
  split(p[1],wh,"x")
  split(wh[1],wparts,"/")
  split(wh[2],hparts,"/")
  W=wparts[1]
  H=hparts[1]
  X=p[2]
  Y=p[3]
  print W,H,X,Y
}' | while read MW MH MX MY
do
  if [ "$CENTER_X" -ge "$MX" ] && [ "$CENTER_X" -lt $((MX+MW)) ] && [ "$CENTER_Y" -ge "$MY" ] && [ "$CENTER_Y" -lt $((MY+MH)) ]; then
    echo "$MW $MH $MX $MY"
    break
  fi
done)

read MW MH MX MY <<< "$MONITOR"

[ -z "$MW" ] && exit 1

HALF_W=$((MW / 2))
HALF_H=$((MH / 2))

case "$ACTION" in
  ul)    NX=$MX;            NY=$MY;            NW=$HALF_W;       NH=$HALF_H ;;
  up)    NX=$MX;            NY=$MY;            NW=$MW;           NH=$HALF_H ;;
  ur)    NX=$((MX+HALF_W)); NY=$MY;            NW=$HALF_W;       NH=$HALF_H ;;
  left)  NX=$MX;            NY=$MY;            NW=$HALF_W;       NH=$MH ;;
  max)   NX=$MX;            NY=$MY;            NW=$MW;           NH=$MH ;;
  right) NX=$((MX+HALF_W)); NY=$MY;            NW=$HALF_W;       NH=$MH ;;
  dl)    NX=$MX;            NY=$((MY+HALF_H)); NW=$HALF_W;       NH=$HALF_H ;;
  down)  NX=$MX;            NY=$((MY+HALF_H)); NW=$MW;           NH=$HALF_H ;;
  dr)    NX=$((MX+HALF_W)); NY=$((MY+HALF_H)); NW=$HALF_W;       NH=$HALF_H ;;
  *) exit 1 ;;
esac

if [ "$MY" -eq 0 ] && { [ "$ACTION" = "left" ] || [ "$ACTION" = "right" ] || [ "$ACTION" = "max" ]; }; then
  NH=$((NH-55))
fi

wmctrl -ir "$WIN" -b remove,maximized_vert,maximized_horz
sleep 0.05
wmctrl -ir "$WIN" -e "0,$NX,$NY,$NW,$NH"
