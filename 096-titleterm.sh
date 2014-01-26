#! /bin/sh

# titleterm - tell the Mac OS X Terminal application to change its name
#   to the value specified as an argument to this succinct script.

# To use this to show your current working directory, for example:
#    alias precmd 'titleterm "$PWD"'			[tcsh]
# or
#    export PROMPT_COMMAND="titleterm \"\$PWD\"" 	[bash]

if [ $# -eq 0 ]; then
  echo "Usage: $0 title" >&2
  exit 1
else 
  echo -ne "\033]0;$1\007"
fi

exit 0
