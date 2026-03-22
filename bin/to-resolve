#!/bin/bash
REMOVE=false
AUDIO_CODEC="libmp3lame"
CONTAINER="mp4"

while getopts "ra:" opt; do
    case $opt in
        r) REMOVE=true ;;
        a) case $OPTARG in
            mp3)  AUDIO_CODEC="libmp3lame" ; CONTAINER="mp4" ;;
            wav)  AUDIO_CODEC="pcm_s16le"  ; CONTAINER="mov" ;;
            flac) AUDIO_CODEC="flac"       ; CONTAINER="mkv" ;;
            alac) AUDIO_CODEC="alac"       ; CONTAINER="mov" ;;
            *) echo "Audio no válido: $OPTARG. Usa mp3, wav, flac, alac" ; exit 1 ;;
           esac ;;
    esac
done
shift $((OPTIND-1))

for f in "$@"; do
    out="${f%.*}_resolve.$CONTAINER"
    if ffmpeg -i "$f" -c:v copy -c:a $AUDIO_CODEC "$out"; then
        echo "✓ $out"
        $REMOVE && rm "$f" && echo "🗑 eliminado: $f"
    else
        echo "✗ error: $f"
    fi
done
