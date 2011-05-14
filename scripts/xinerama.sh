#!/bin/bash

# Parses xdpyinfo to get some information about xinerama.

# Possible output :

# XINERAMA version 1.1 opcode: 156
#   head #0: 1280x1024 @ 0,0
#   head #1: 1280x1024 @ 1280,0

# XINERAMA version 1.1 opcode: 155
#   head #0: 1152x864 @ 1152,0
#   head #1: 1152x864 @ 0,0

# XINERAMA version 1.1 opcode: 155
#   head #0: 1152x864 @ 0,0
#   head #1: 1400x1050 @ 1152,0

# XINERAMA version 1.1 opcode: 153
#   Xinerama is inactive.

# XINERAMA extension not supported by server

heads=$(xdpyinfo -ext XINERAMA 2> /dev/null | \
    grep -A2 '^XINERAMA' | \
    tail -2 | grep head)

function set_resolution() {
    left=$1
    right=$2
    echo $left | awk -Fx '{print "SetEnv Left-Screen-x "$1}'
    echo $left | awk -Fx '{print "SetEnv Left-Screen-y "$2}'
    echo $right | awk -Fx '{print "SetEnv Right-Screen-x "$1}'
    echo $right | awk -Fx '{print "SetEnv Right-Screen-y "$2}'
}

[[ $(echo "$heads" | wc -l) == 2 ]] && {
    echo "SetEnv Has-Xinerama 1"
    # We assume two headed left-right setup
    echo "$heads" | while read head number resolution at position; do
	x=$(echo $position | sed 's/,.*//')
	[[ -n $first ]] && {
	    # Compare with first position
	    [[ $first -lt $x ]] && {
		echo "Echo Xinerama setup with left-screen first"
		echo "SetEnv Left-Screen 0"
		echo "SetEnv Right-Screen 1"
		set_resolution $first_resolution $resolution
		exit 0
	    }
	    echo "Echo Xinerama setup with right-screen first"
	    echo "SetEnv Left-Screen 1"
	    echo "SetEnv Right-Screen 0"
	    set_resolution $resolution $first_resolution
	    exit 0
	}
	first=$x
	first_resolution=$resolution
    done
    exit 0
}

echo "Echo No Xinerama detected"
echo "SetEnv Has-Xinerama 0"
echo "SetEnv Left-Screen 0"
echo "SetEnv Right-Screen 0"
echo 'SetEnv Right-Screen-x $[vp.width]'
echo 'SetEnv Left-Screen-x $[vp.width]'
echo 'SetEnv Right-Screen-y $[vp.height]'
echo 'SetEnv Left-Screen-y $[vp.height]'
exit 0
