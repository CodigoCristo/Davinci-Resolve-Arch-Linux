# to-resolve

Script para convertir videos con audio AAC (y otros codecs no soportados) a formatos compatibles con DaVinci Resolve en Linux.

## Instalación

```bash
sudo nano /bin/to-resolve
```

Pega el siguiente contenido:

```bash
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
```

Guarda y da permisos:

```bash
sudo chmod +x /bin/to-resolve
```

---

## Uso

### Básico (mp3 por defecto)
```bash
to-resolve video.mp4
```

### Especificar formato de audio

| Argumento | Audio | Contenedor |
|-----------|-------|------------|
| (ninguno) | MP3   | MP4        |
| `-a:mp3`  | MP3   | MP4        |
| `-a:wav`  | PCM s16le (lossless) | MOV |
| `-a:flac` | FLAC (lossless) | MKV |
| `-a:alac` | ALAC (lossless) | MOV |

```bash
to-resolve -a:wav video.mp4
to-resolve -a:flac video.mp4
to-resolve -a:alac video.mp4
```

### Eliminar el archivo original con `-r`
```bash
to-resolve -r video.mp4
to-resolve -r *.mp4
to-resolve -r -a:wav *.mp4
to-resolve -r -a:flac video.mkv
```

---

## Notas

- El video **no se recodifica** (`-c:v copy`), solo el audio. La conversión es rápida y no pierde calidad de imagen.
- El archivo de salida se genera en el mismo directorio con el sufijo `_resolve`.
- Requiere `ffmpeg` instalado en el sistema.
