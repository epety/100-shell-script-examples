#!/bin/sh

# CONVERTATEMP - Temperature conversion script that lets the user enter
#   a temperature in any of Fahrenheit, Celsius or Kelvin and receive the
#   equivalent temperature in the other two units as the output.

if uname | grep 'SunOS'>/dev/null ; then
  echo "Yep, SunOS, let\'s fix this baby"
  PATH="/usr/xpg4/bin:$PATH"
fi

if [ $# -eq 0 ] ; then
  cat << EOF >&2
Usage: $0 temperature[F|C|K]
where the suffix:
   F	indicates input is in Fahrenheit (default)
   C	indicates input is in Celsius
   K	indicates input is in Kelvin
EOF
  exit 1
fi

unit="$(echo $1|sed -e 's/[-[[:digit:]]*//g' | tr '[:lower:]' '[:upper:]' )"
temp="$(echo $1|sed -e 's/[^-[[:digit:]]*//g')"

case ${unit:=F}
in
  F ) # Fahrenheit to Celsius formula:  Tc = (F -32 ) / 1.8
  farn="$temp"
  cels="$(echo "scale=2;($farn - 32) / 1.8" | bc)"
  kelv="$(echo "scale=2;$cels + 273.15" | bc)"
  ;;

  C ) # Celsius to Fahrenheit formula: Tf = (9/5)*Tc+32
  cels=$temp
  kelv="$(echo "scale=2;$cels + 273.15" | bc)"
  farn="$(echo "scale=2;((9/5) * $cels) + 32" | bc)"
  ;;

  K ) # Celsius = Kelvin + 273.15, then use Cels -> Fahr formula
  kelv=$temp
  cels="$(echo "scale=2; $kelv - 273.15" | bc)"
  farn="$(echo "scale=2; ((9/5) * $cels) + 32" | bc)"
esac  

echo "Fahrenheit = $farn"
echo "Celsius    = $cels"
echo "Kelvin     = $kelv"

exit 0
