#!/bin/bash

norm="\033[1;0m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
blue="\033[1;34m"

#Script natives
VERSION="2.5.1-1"

#Making arrangements before executing the script

YTDIR="$HOME/Music/m2m"
MULTI_DIR="$YTDIR/multi_mode"
PLAYLIST_DIR="$YTDIR/playlists"
ERROR_LOG="$HOME/.local/share/m2m_error_log"
mkdir -p "$YTDIR"
mkdir -p "$MULTI_DIR"
mkdir -p "$ERROR_LOG"
DATE=$(date +'%a_%b_%d_%H_%M_%S')
READ_TIMEOUT=15
LINK=""
file_name="placeholder"
playlist_switch=false
multiple_switch=false
opt_dest_dir_switch=false
meta_switch=false

multi_dnc(){
	dest_dir=$1
	#counter=1
	for file in "${!multiple_download_dict[@]}";do
		url="${multiple_download_dict[$file]}"
		counter=$(yt-dlp -J "$url" 2>/dev/null | jq -r '.title' | tr -cd '[:alnum:] ' | tr ' ' '_')
		echo -e "$blue[*] Initiating downlaod for $yellow$counter$norm"
		if [[ $file == *"wav"* ]] || [[ $file == *"mp3"* ]];then
			yt-dlp --quiet --progress --no-warnings -f bestaudio $url -o "$dest_dir/ytvideo.webm"
		else
			yt-dlp --quiet --progress --no-warnings -f best $url -o "$dest_dir/ytvideo.webm"
		fi

		
		if [[ $? -eq 0 ]];then
	
			echo -e "$green[✓] Stream downloaded $norm"
			echo -e "$blue[*] Converting stream $counter to $file $norm"

			if [[ $file == *"wav"* ]] || [[ $file == *"mp3"* ]];then
				ffmpeg -i "$dest_dir/ytvideo.webm" "$dest_dir/$file" -y 1> /dev/null 2>"$ERROR_LOG/$DATE-ffmpeg-multi-download.log" 
			else
				ffmpeg -i "$dest_dir/ytvideo.webm" -c copy "$dest_dir/$file" -y 1> /dev/null 2>"$ERROR_LOG/$DATE-ffmpeg-multi-download.log" 
			fi


			if [[ $? -eq 0  ]];then
				echo -e "$green[✓] Stream $file saved to filesystem$norm \n"
				rm "$dest_dir"/ytvideo.*
			else
				echo -e "$red[!] An error occured $norm"
				echo -e "$red[!] Error saved at $ERROR_LOG $norm"
				continue
			fi

		else
			echo -e "$red[!] Stream $counter not downloaded $norm"
			echo -e "$red[!] Error saved at $ERROR_LOG $norm \n"
			continue
		fi
		#counter=$(($counter+1))	
	done

}

download_meta(){
    URL_FOR_META="$1" 

    META_COMMAND=(
    yt-dlp
    -x
    --quiet
    --progress
    --no-warnings
    --audio-format flac
    --audio-quality 0
    --embed-metadata
    --embed-thumbnail
    --no-write-thumbnail
    --parse-metadata "title:%(title)s"
    --parse-metadata "artist:%(channel)s"
    -o "%(title)s.%(ext)s"
    )


    if [[ "$URL_FOR_META" == *list=* ]];then
        echo -e "$blue[*] Acquiring playlist data from YouTube$norm"
        json=$(yt-dlp --flat-playlist -J "$URL_FOR_META")
        echo -e "$green[✓]Playlist data aquired$norm"

        title=$(echo "$json" | jq -r '.title' | tr -cd '[:alnum:] ' |tr ' ' '_')
        mkdir $title
        cd $title

        list_urls=$(echo "$json" | jq -r '.entries[] | .url')
        counter=1
        
        for url in $list_urls;do
            echo -e "$blue[*] Downloading stream $counter$norm"
            "${META_COMMAND[@]}" "$url"
            
            if [[ $? -eq 0 ]];then
                echo -e "$green[✓] Stream $counter Downloaded $norm"
            fi

            counter=$(($counter+1))
        done
    
    else
        echo -e "$blue[*] Downloading stream from youtube$norm"
        "${META_COMMAND[@]}" "$URL_FOR_META"

        if [[ $? -eq 0 ]];then
            echo -e "$green[✓] Stream Downloaded and saved to $(pwd) $norm"
        fi

    fi
}

download_pl(){

	if [[ $opt_dest_dir_switch == true ]];then
		dest_dir=$opt_dest_dir
	else
		dest_dir=$PLAYLIST_DIR
	fi

	pl_url="$1"
	if [[ "$pl_url" != *list=* ]];then
		echo -e "$red[!] m2m: Error: Invalid playlist link$norm"
		exit 1
	fi
	echo -e "$blue[*] Acquiring playlist data from YouTube$norm"
	json=$(yt-dlp --flat-playlist -J "$pl_url")
    playlist_title="$(echo "$json" | jq -r '.title' | tr -cd '[:alnum:] ' |tr ' ' '_')"
	dest_dir="$dest_dir/$playlist_title"
	mkdir -p "$dest_dir"
	declare -A playlist_data
	
	# Getting the video titles and urls from youtube

	while IFS=$'\t' read -r vd_url title;do
		safe_title=$(echo "$title" | tr -cd '[:alnum:] ' | tr ' ' '_')
		playlist_data["$safe_title"]="$vd_url"
	done < <(echo "$json" | jq -r '.entries[] | [.url,.title] | @tsv') 	#<--- The core of the playlist method

	echo -e "$blue[*] Playlist data aquired, choose an extension (default: mkv)$norm"

	if ! read -t "$READ_TIMEOUT" -p ">>" filetype; then
		echo -e "$yellow[!] Extension time out, using default (mkv)$norm"
		filetype="mkv"
	elif [[ $filetype == "" ]];then
		filetype="mkv"
	fi
	
	counter=1
	for name in ${!playlist_data[@]};do
		url=${playlist_data[$name]}
		echo -e "$blue[*] Initiating downlaod for $yellow$name$norm"
		if [[ $filetype == *"wav"* ]] || [[ $filetype == *"mp3"* ]];then
			yt-dlp --quiet --progress --no-warnings -f bestaudio $url -o "$dest_dir/ytvideo.webm"
		else
			yt-dlp --quiet --progress --no-warnings -f best $url -o "$dest_dir/ytvideo.webm"
		fi


		if [[ $? -eq 0 ]];then
	
			echo -e "$green[✓] Stream $counter downloaded $norm"
			echo -e "$blue[*] Converting stream $counter $norm"
			
			if [[ $filetype == *"wav"* ]] || [[ $filetype == *"mp3"* ]];then
				ffmpeg -i "$dest_dir/ytvideo.webm" "$dest_dir/$name.$filetype" 1> /dev/null 2>"$ERROR_LOG/$DATE-ffmpeg-playlist-download.log" 
			else
				ffmpeg -i "$dest_dir/ytvideo.webm" -c copy "$dest_dir/$name.$filetype" 1> /dev/null 2>"$ERROR_LOG/$DATE-ffmpeg-playlist-download.log" 
			fi


			if [[ $? -eq 0  ]];then
				echo -e "$green[✓] Stream $counter saved to filesystem$norm \n"
				rm "$dest_dir"/ytvideo.*
			else
				echo -e "$red[!] An error occured $norm"
				echo -e "$red[!] Error saved at $ERROR_LOG $norm"
				continue
			fi

		else
			echo -e "$red[!] Stream $counter not downloaded $norm"
			echo -e "$red[!] Error saved at $ERROR_LOG $norm \n"
			continue
		fi
		counter=$(($counter+1))
	done
}

get_title(){
    video_url="$1"
    title=$(yt-dlp --no-warnings -J "$video_url" | jq -r '.title' | tr -cd '[:alnum:] ' | tr ' ' '_')
    echo "$title".wav
}

show_version(){
	echo -e "$blue[*] m2m: Version: $VERSION $norm"
	exit 0
}

show_help(){
	echo -e "
 __  __ ____  __  __ 		
|  \/  |___ \|  \/  |	
| |\/| | __) | |\/| |	m2m v"$VERSION"
| |  | |/ __/| |  | |	
|_|  |_|_____|_|  |_|           

Usage: For single downloads
$red[!] If no name is provided, the video will be downloaded in WAV format with its original name$norm
m2m [-d <destination_dir>] <url> <filename.ext>

For multiple downloads: (put number of downloads as 'n' for infinite downloads)
m2m [-d <destination_dir>] -m <number_of_files_to_download>

For downloading playlists:
m2m [-d <destination_dir>] -pl <playlist_url>

Flags:
	-h|--help|-? 		Show this help message
	-m|--multi-download	Use multi download mode (described above)
	-d|--destination	Use the provided destination directory rather than the default one
	-pl|--playlist|-PL 	Download an entire playlist not just a video
	-M|--meta           Download the track audio with all the metadata from youtube. (OFF by default)
    "
}

check_dependencies(){
	for cmd in yt-dlp ffmpeg jq;do
		if ! command -v $cmd >/dev/null 2>&1; then
			echo -e "$red[!] m2m: Error: $cmd not installed$norm"
			exit 1
		fi
	done
}

main(){

check_dependencies

for arg in "$@";do
	case $arg in
		-pl)
			set -- "${@/-pl/-p}";;
		--meta)
            set -- "${@/--meta/-M}";;
        --playlist)
			set -- "${@/--playlist/-p}";;
		--destination)
			set -- "${@/--destination/-d}";;
	esac
done

while getopts ":m:d:p:Mvh" arg;do
	case $arg in
		m)
			multiple_switch=true
			multiple_switch_counter="$OPTARG"
			;;
      
        d)
			opt_dest_dir_switch=true
			opt_dest_dir="$OPTARG"
			if [[ ! -d "$opt_dest_dir" ]]; then
                echo -e "$yellow[!] m2m: Error: Output directory ($red$opt_dest_dir$yellow) does not exist!$norm"
                exit 1
            fi
			;;
		p)
			playlist_switch=true
			playlist_url="$OPTARG"
			if [[ -z "$playlist_url" ]]; then
                echo -e "$yellow[!] m2m: Error: Missing playlist URL after $red-p$norm"
                exit 1
            fi
			;;
	    M)
            meta_switch=true
            ;;
        v)
			show_version
			exit 0
			;;
		h|\?)
			show_help
			exit 0
			;;
		:)
			echo -e "$red[! m2m: Error: Missing argument for -$OPTARG$norm"

	esac
done

shift $((OPTIND-1))

for arg in "$@";do
	case $arg in
		http*://*)
			LINK="$arg"
			;;
		*)
			file_name=$arg
	esac
done

if [[ -z "$LINK" && $playlist_switch == false && $multiple_switch == false && $meta_switch == false  ]]; then
    echo -e "$red[!] Usage: m2m [-d <destination_dir>] <url> <filename.ext> $norm"
    exit 1
fi

if [[ "$#" -eq 1 && -z "$LINK" ]];then
	show_help
	exit 1	
fi

if [[ "$file_name" == "placeholder" && $playlist_switch == false && $multiple_switch == false ]]; then
    file_name=$(get_title "$LINK")
fi

if [[ "$meta_switch" == true ]];then
    download_meta "$LINK"
    exit 0
fi

if [[ $multiple_switch != true  && $playlist_switch != true ]];then

	if [[ $opt_dest_dir_switch == true ]];then
		dest_dir=$opt_dest_dir
	else
		dest_dir=$YTDIR
	fi
	title=$(yt-dlp -J "$LINK" 2>/dev/null | jq '.title' | tr -cd '[:alnum:] ' | tr ' ' '_')
	
	echo -e "$blue[*] Initiating downlaod for $yellow$title$norm"
	
	if [[ $file_name == *"wav"* ]] || [[ $file_name == *"mp3"*  ]];then
		yt-dlp --quiet --progress --no-warnings -f bestaudio $LINK -o "$dest_dir/ytvideo.webm" 
	else
		yt-dlp --quiet --progress --no-warnings -f best $LINK -o "$dest_dir/ytvideo.webm"
	fi


	#Block telling the user whether the stream was downloaded or not
	if [[ $? -eq 0 ]];then
		echo -e "$green[✓] Stream downloaded $norm"
		
		if [[ $opt_dest_dir_switch == true ]];then
			file_save_location=$dest_dir
		else
			echo -e "These are the directories in $dest_dir \n$(ls $dest_dir)\nWhere do you want to save this one?"
			read -p ">> " file_save_location
			file_save_location="$dest_dir/$file_save_location"
		fi
	else
		echo -e "$red[!] Stream not downloaded $norm"
		echo -e "$red[!] Error saved at $ERROR_LOG $norm"
		exit 1
	fi
	
	echo -e "$blue[*] Converting the stream $norm"

	if [[ "$file_name" == *"wav"* ]] || [[ $file_name == *"mp3"* ]];then
		ffmpeg -i "$dest_dir/ytvideo.webm" "$file_save_location/$file_name" -y 1>/dev/null 2>"$ERROR_LOG/$DATE-ffmpeg.log" 
	else
		ffmpeg -i "$dest_dir/ytvideo.webm" -map 0:a:0 -map 0:v:0 -c copy "$file_save_location/$file_name" -y 1> /dev/null 2>"$ERROR_LOG/$DATE-ffmpeg.log" 
	fi


	#Block telling the user the final action and removing the ghost file.
	if [[ $? -eq 0  ]];then
		rm "$dest_dir"/ytvideo.web*
		echo -e "$green[*] Streams Saved to filesystem at $file_save_location !! $norm" 
	else
		echo -e "$red[!] An error occured $norm"
		echo -e "$red[!] Error saved at $ERROR_LOG $norm"
	fi

fi


if [[ $playlist_switch == true ]];then
	download_pl "$playlist_url"
fi


if [[ $multiple_switch == true && $multiple_switch_counter != "n" ]];then
	#Taking the multiple links and file names from the user
	declare -A multiple_download_dict

	for((i=1;i<=$multiple_switch_counter;i++));do
	read -p "Enter the URL: " url
	read -p "Enter the name to save it as: " save_file
	multiple_download_dict["$save_file"]="$url"
	done

    if [[ $opt_dest_dir_switch != true ]];then
		multi_dnc "$MULTI_DIR"
	else
		multi_dnc "$opt_dest_dir"
	fi
fi

if [[ $multiple_switch_counter == "n" ]];then
	declare -A multiple_download_dict
	declare url=""

	while true;do
		read -p "Enter the URL(type 'done' when you are done): " url
		if [[ "$url" == "done" ]];then break; fi
		read -p "Enter the name to save it as: " save_file
		multiple_download_dict["$save_file"]="$url"
	done

    if [[ $opt_dest_dir_switch != true ]];then
		multi_dnc "$MULTI_DIR"
	else
		multi_dnc "$opt_dest_dir"
	fi
fi
}


main "$@"
