#! /usr/bin/env python

# Set two backgrounds on a Xinerama screen

# Two first arguments are the size of the left screen
# Two next arguments are the size of the right screen
# Two next arguments are the image name
# Last one is the target

import Image
import sys

left_x = int(sys.argv[1])
left_y = int(sys.argv[2])
right_x = int(sys.argv[3])
right_y = int(sys.argv[4])

left_image = sys.argv[5]
right_image = sys.argv[6]

target = sys.argv[7]

background = Image.new('RGB', (left_x + right_x, max(left_y, right_y)))

left = Image.open(left_image).resize((left_x, left_y), Image.CUBIC)
right = Image.open(right_image).resize((right_x, right_y), Image.CUBIC)

background.paste(left, (0,0))
background.paste(right, (left_x, 0))

background.save(target)
