#!/bin/bash
# Tim H 2011
# Strip EXIF (location) data from images (JPG files)
#
# Examples:
#   ./centos-strip-exif-data $HOME/Pictures

# prereq package to use mogrify:
#yum install -qy ImageMagick
# OS X:
#brew install ImageMagick

find "$@" -name '*.jpg' -exec mogrify -strip {} \;
