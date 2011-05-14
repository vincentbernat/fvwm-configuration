#!/usr/bin/env python

# Classify backgrounds into directory related to their aspect ratio

# First argument is the directory where the images are. They will be
# moved into the appropriate subdirectories

import os
import sys
import shutil
import Image

ratios = [(5,4), (4,3), (16,9), (16,10)]

directory = sys.argv[1]

def distance(ratio1, ratio2):
    r1 = float(ratio1[0])
    r2 = float(ratio1[1])
    r3 = float(ratio2[0])
    r4 = float(ratio2[1])
    r = (r1/r2)/(r3/r4)
    if r > 1:
        r = 1/r
    return 1-r

for image in os.listdir(directory):
    image = os.path.join(directory, image)
    if os.path.isfile(image):
        im = Image.open(image)
        best = ratios[0]
        for ratio in ratios[1:]:
            if distance(ratio, im.size) < distance(best, im.size):
                best = ratio
        print "Best ratio for %s (%sx%s)is %s:%s" % (image, im.size[0], im.size[1],
                                                     best[0], best[1])
        shutil.move(image, os.path.join(directory,
                                        "%d:%d" % (best[0], best[1]),
                                        os.path.basename(image)))
