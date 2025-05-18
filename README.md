# m2m

A minimal bash tool to convert video files to any other supported media files using yt-dlp and ffmpeg.

## How it works:
- Fetches the video from the URL using yt-dlp
- Saves it in your `$YTDIR` directory (`$YTDIR=$HOME/Music/ytdownloads` by default)
- Uses ffmpeg to convert the video to another file format
- Deletes the original video file and saves the converted file to `$YTDIR`

## Suggested:
Add this line to your `.bashrc` or `.zshrc` file to set your output directory:

```bash
export YTDIR=$HOME/Music/ytdownloads
```

## Usage:
 ```bash
m2m "https://www.youtube.com/watch?v=EYI489Dc4Sc" outputfile.mp3
```
Change the extension form `.mp3` to anything you like
