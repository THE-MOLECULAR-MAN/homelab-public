#!/bin/bash
# Tim H 2023

# Downloading livestream of .ts files and combining them. This particular
# site was a pay-per-view boxing match of some friends 
# that I paid for and wanted to keep.
#
# On this particular site, it sends a bunch of 3 MB .ts files. Each file
# has about 5-6 seconds of video. Luckily, with .ts files, you can literally
# concatenate the files to merge them.
#
# URL seems to change slightly when show finishes, lots more parameters
# At least some of the headers are mandatory, otherwise it won't work
# There's a very long list of parameters for each URL that are also mandatory.
# Those parameters values change every once in a while during the stream, such
# as the expiration timestamp. It seems like a lot of additional parameters
# are added to the URL after the live stream is finished.

# References:
#   https://www.xmodulo.com/how-to-use-custom-http-headers-with-wget.html

# I used Chrome's Inspect mode to get the URLs and see which ones I needed.
# The stream started at 0 but the first several minutes were just a screen
# that was announcing the show would start soon, so I skipped those.

wget --no-clobber \
    --header 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/112.0' \
    --header 'Accept: */*' \
    --header 'Accept-Language: en-US,en;q=0.5' \
    --header 'Accept-Encoding: gzip, deflate, br' \
    --header 'Referer: https://redacted.com/' \
    --header 'Origin: https://redacted.com' \
    --header 'DNT: 1' \
    --header 'Connection: keep-alive' \
    --header 'Sec-Fetch-Dest: empty' \
    --header 'Sec-Fetch-Mode: cors' \
    --header 'Sec-Fetch-Site: cross-site' \
    --header 'Pragma: no-cache' \
    --header 'Cache-Control: no-cache' \
    https://zypelive-amd.akamaized.net/hls/live/REDACTED/00000001/media_{2128..2400}.ts?REDACTED

# only rename files that need it - more efficient
for i in media_*.ts\?*; do 
  mv "$i" "${i%\?*}"
done

# find the missing files:
ub=2400 # Replace this with the largest existing file's number
seq "$ub" | while read -r i; do
    [[ -f "media_$i.ts" ]] || echo "$i is missing"
done

# get the missing one(s), if there are any

# estimate the concatenated file size:
du -sh .

# orders the files and concatenates them into a single big .ts file
find . -type f -maxdepth 1 -mindepth 1 -iname 'media_*.ts' | \
    sort -n -t _ -k 2 | tr '\n' ' ' | xargs cat > combined.ts

# convert the .ts file into mp4
# use Handbrake instead to convert the .ts file into MP4 or MKV
# it's much smaller that way.
