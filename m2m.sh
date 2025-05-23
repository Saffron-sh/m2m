#!/bin/bash

echo "No need to rage quit, m2m is working."
yt-dlp $1 -q -o $YTDIR/ytvideo.webm
echo "Done downloading. Now converting"
ffmpeg -v 8 -i $YTDIR/ytvideo.web* $YTDIR/$2
rm $YTDIR/ytvideo.web*
echo "All done, go check out your file in $YTDIR"
