# m2m

A minimal bash tool to convert YouTube video files to any other supported media files.

"m2m" stands for **Media to Media**.
## How it works:
- Fetches the video from the URL using yt-dlp
- Saves it in your `$YTDIR` directory (`$YTDIR=$HOME/Music/m2m` by default)
- Or in your `$MULTI_DIR` directory for batch downloads (`$MULTI_DIR=$HOME/Music/m2m/multi_mode` by default)
- Uses ffmpeg to convert the video to another file format
- Deletes the original video file and saves the converted file to `$YTDIR`

## Dependencies
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [ffmpeg](https://ffmpeg.org/)
- [jq](https://github.com/jqlang/jq)

## Usage:
### For single downloads:
```bash
m2m "https://www.youtube.com/watch?v=EYI489Dc4Sc" outputfile.mp3
```
If no name is provided, the video will be downloaded in WAV format with its youtube name

Change the extension from `.mp3` to anything you like.

### For batch downloads:
```bash
m2m -m 5
```
You can change the **5** to the number of files you want to download.  
(Or you can set is as **n** if you want it to run infinitely until you type `done` as the url.)  
It would prompt you for the *URL* and then for the name you want to save the file as
```bash
m2m -m 2
Enter the URL: https://youtu.be/3JZ_D3ELwOQ
Enter the name to save it as: song_one.wav
Enter the URL: https://youtu.be/L_jWHffIx5E
Enter the name to save it as: song_two.mkv
[*] Initiating download for stream 1
[✓] Stream 1 downloaded
[*] Converting stream 1
[✓] Stream 1 saved to filesystem

[*] Initiating download for stream 2
[✓] Stream 2 downloaded
[*] Converting stream 2
[✓] Stream 2 saved to filesystem

... #And so on
```
### For downloading Playlists from youtube
```bash
[usernorm@xarch ~]$ m2m -pl 'https://youtube.com/playlist?list=PLb9fYCYT16Y62EXx79LCfXc1jDxdsR9jf&si=hU-KoFIK4O6ob8pq'
[*] Aquiring playlist data from YouTube
[*] Playlist data aquired, choose an extension (default: wav) 
>>wav           # <--- You can choose any media format supported by ffmpeg
[*] Downloading stream 1 (Issam_Alnajjar__Hadal_Ahbek_Performance_Video)
[✓] Stream 1 downloaded 
[*] Converting stream 1 
[✓] Stream 1 saved to filesystem 

[*] Downloading stream 2 (Clandestina__Emma_Peters_lyrical_video_lyricalvideo_song_trending_music_shortsmusic)
[✓] Stream 2 downloaded 
[*] Converting stream 2 
[✓] Stream 2 saved to filesystem 

[*] Downloading stream 3 (Luis_Fonsi__Despacito_ft_Daddy_Yankee)
[✓] Stream 3 downloaded 
[*] Converting stream 3 
[✓] Stream 3 saved to filesystem 

[*] Downloading stream 4 (Gabry_Ponte_KEL__Tarantella)
[✓] Stream 4 downloaded 
[*] Converting stream 4 
[✓] Stream 4 saved to filesystem 
```

### Infinite batch downloads:
```bash
m2m -m n

Enter the URL(type 'done' when you are done): https://youtu.be/oUfjhrSOFw8?si=GGCoI5J-5w4ejof-
Enter the name to save it as: stream01.mp4
Enter the URL(type 'done' when you are done): https://youtu.be/wN0x9eZLix4?si=2OXL-z7ldy7gAckO
Enter the name to save it as: stream02.mp4
Enter the URL(type 'done' when you are done): done
[*] Initiating download for stream 1 
[✓] Stream 1 downloaded 
[*] Converting stream 1 
[✓] Stream 1 saved to filesystem 

[*] Initiating download for stream 2 
[✓] Stream 2 downloaded 
[*] Converting stream 2 
[✓] Stream 2 saved to filesystem 
```

## Notes
- By default, downloads are saved in:
  - `$HOME/Music/m2m` for single downloads.
  - `$HOME/Music/m2m/multi_mode` for batch downloads.
  - `$HOME/Music/m2m/playlists` for playlist downloads.
- Also the error logs are saved in `$HOME/.local/share` by default, i'd personally suggest you keep it like that, but if you know what you are doing changing it would not have much effect.
- You can add the `-d` flag followed by any _path_  to have **m2m** save the file(s) there.
- The playlist flags `-pl|--playlist|-PL` create a directory in `$PLAYLIST_DIR` by the name of the title of the playlist and all the files are saved in it.
- You can change both `$YTDIR` and `$MULTI_DIR` as per your convenience.
- You can convert to any media format supported by `ffmpeg` just don't forget to put the extension after the file name.
- I have used `-f best` option for `yt-dlp` to fetch the highest quality stream available, however if you want to optimize `m2m` for less data usage, you can change that to any other stream you like.


## Contributers
- Big thanks to [hamed](https://github.com/hamedbkf) for adding the output directory flag `-d` and the spinner download animation while file downloading and conversion (The spinner was later removed because of some bugs and that's why it is no longer there but if you look into the previous commits you will be able to see hamed's works).

## Support

m2m was built mostly because I wanted it to exist.  
If it helps you too, and you’d like to buy me a coffee (no pressure at all), you can tip a few sats here:

**BTC (On-chain):** 
`bc1qsjjgj3yqvhe5dw0xlxqzch4zlqnlwqctchlztf`

Every bit goes straight into caffeine and maintaining open-source code.
