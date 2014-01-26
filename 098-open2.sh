#!/bin/sh

# open2 - a smart wrapper for the cool Mac OS X 'open' command
#   to make it even more useful. By default, open launches the
#   appropriate application for a specified file or directory
#   based on the Aqua bindings, and has a limited ability to 
#   launch applications if they're in the /Applications dir.

# first off, whatever argument we're given, try it directly:

open=/usr/bin/open

if ! $open "$@" >/dev/null 2>&1 ; then
  if ! $open -a "$@" >/dev/null 2>&1 ; then

    # More than one arg?  Don't know how to deal with it: quit
    if [ $# -gt 1 ] ; then
      echo "open: Can't figure out how to open or launch $@" >&2
      exit 1
    else
      case $(echo $1 | tr '[:upper:]' '[:lower:]') in
	acrobat      ) app="Acrobat Reader"		;;
	adress*      ) app="Address Book"		;;
	chat         ) app="iChat"			;;
	cpu          ) app="CPU Monitor"		;;
	dvd          ) app="DVD Player"			;;
	excel        ) app="Microsoft Excel"		;;
	netinfo      ) app="NetInfo Manager"		;;
	prefs        ) app="System Preferences"		;;
	print        ) app="Print Center"		;;
	profil*      ) app="Apple System Profiler"	;;
	qt|quicktime ) app="QuickTime Player"		;;
	sync         ) app="iSync"			;;
	word         ) app="Microsoft Word"		;;
        * ) echo "open: Don't know what to do with $1" >&2
	    exit 1
      esac
      echo "You asked for $1 but I think you mean $app." >&2
      $open -a "$app"
    fi
  fi
fi

exit 0
