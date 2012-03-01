#!/bin/sh

# Automatically configure multiscreen setup

OUTPUTS=$(xrandr | \
    sed -n 's/^\(^[A-Z0-9-]*\) connected [0-9x]*\(+0+0\)*.*/\1\2/p')
xrandr --auto
for output in $OUTPUTS; do
    # Change current direction
    case "$output:$prevoutput" in
	*+0+0:)
	    DIRECTION=left-of
	    ;;
	*:)
	    DIRECTION=right-of
	    ;;
    esac
    xrandr --output ${output%%+*} --auto
    [ -n "$prevoutput" ] && \
	xrandr --output ${output%%+*} --$DIRECTION $prevoutput
    prevoutput=${output%%+*}
done
