#!/bin/sh

# Automatically configure multiscreen setup

# Grab the list of enabled outputs
OUTPUTS=$(xrandr | \
    sed -n 's/^\(^[A-Z0-9-]*\) connected [0-9x]*\(+0+0\)*.*/\1\2/p')
# Example:
#  VGA1+0+0
#  DVI1

ARGS="--auto"
for output in $OUTPUTS; do
    # Use the name of the first output to determine the order we
    # should use. Consecutive calls of this script will therefore
    # reverse the order.
    case "$output:$prevoutput" in
	*+0+0:)
	    DIRECTION=left-of
	    ;;
	*:)
	    DIRECTION=right-of
	    ;;
    esac

    # Autoconfigure this output
    ARGS="$ARGS --output ${output%%+*} --auto"

    # And put it at left or at right of the previous output
    [ -n "$prevoutput" ] && \
	ARGS="$ARGS --output ${output%%+*} --$DIRECTION $prevoutput"

    prevoutput=${output%%+*}
done

# Call xrandr
xrandr $ARGS

# Ask to restart FVWM
echo "Restart"
