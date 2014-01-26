#!/bin/sh

# exchangerate - given a currency amount, convert it into other major 
#   currencies and show the equivalent amounts in each.

# ref URL: http://www.ny.frb.org/pihome/statistics/forex12.shtml

showrate()
{
  dollars="$(echo $1 | cut -d. -f1)"
  cents="$(echo $1 | cut -d. -f2 | cut -c1-2)"
  rate="$dollars.${cents:-00}"
}

exchratefile="/tmp/.exchangerate"
scriptbc="scriptbc -p 30"  # tweak this setting as needed

. $exchratefile

# The 0.0000000001 compensates for a rounding error bug in 
# many versions of bc, where 1 != 0.99999999999999

 useuro="$($scriptbc 1 / $euro    + 0.000000001)"
 uscand="$($scriptbc 1 / $canada  + 0.000000001)"
  usyen="$($scriptbc 1 / $japan   + 0.000000001)"
uspound="$($scriptbc 1 / $uk      + 0.000000001)"

if [ $# -ne 2 ] ; then
  echo "Usage: $(basename $0) amount currency"
  echo "Where currency can be USD, Euro, Canadian, Yen, or Pound."
  exit 0
fi

amount=$1
currency="$(echo $2 | tr '[:upper:]' '[:lower:]' | cut -c1-2)"

case $currency in
  us|do ) if [ -z "$(echo $1 | grep '\.')" ] ; then
	    masterrate="$1.00"
	  else
	    masterrate="$1"
	  fi						;;
  eu    ) masterrate="$($scriptbc $1 \* $euro)"	;;
  ca|cd ) masterrate="$($scriptbc $1 \* $canada)"	;;
  ye    ) masterrate="$($scriptbc $1 \* $japan)"		;;
  po|st ) masterrate="$($scriptbc $1 \* $uk)"	;;
      * ) echo "$0: unknown currency specified."
          echo "I only know USD, EURO, CAND/CDN, YEN and GBP/POUND."
	  exit 1
esac

echo "Currency Exchange Rate Equivalents for $1 ${2}:"
showrate $masterrate
echo "      US Dollars: $rate"
showrate $($scriptbc $masterrate \* $useuro)
echo "        EC Euros: $rate"
showrate $($scriptbc $masterrate \* $uscand)
echo "Canadian Dollars: $rate"
showrate $($scriptbc $masterrate \* $usyen)
echo "    Japanese Yen: $rate"
showrate $($scriptbc $masterrate \* $uspound)
echo "   British Pound: $rate"

exit 0
