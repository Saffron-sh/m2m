# m2m
A minimal bash tool to convert video files to any other supported media files using yt-dlp and ffmpeg.

#How it works:
->Fetches the video from the url using yt-dlp
->Saves it in your $YTDIR directory ($YTDIR=$HOME/Music/ytdownloads) by default.
->Uses ffmpeg to convert the video to another file format
->Deletes the video file and saves the converted file to $YTDIR

#Suggested:
Add 'export YTDIR=$HOME/Music/ytdownloads' to your .bashrc or .zshrc file.

#Usage:
$m2m <VIDEO URL> <Output file WITH extension>
