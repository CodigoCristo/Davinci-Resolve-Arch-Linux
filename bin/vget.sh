#!/bin/bash

# ====================================================================
# vget.sh — Descargador de videos (migrado desde vget.ps1)
# Requiere: yt-dlp y ffmpeg en el PATH
# ====================================================================

set -euo pipefail

# ── Colores ──────────────────────────────────────────────────────────
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
M='\033[0;35m'
W='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

# ── Helpers de salida ─────────────────────────────────────────────────
sep()  { echo -e "${DIM}============================================${NC}"; }
ok()   { echo -e "${G}  [OK]  $1${NC}"; }
info() { echo -e "${C}  $1${NC}"; }
warn() { echo -e "${Y}  [!]  $1${NC}"; }
err()  { echo -e "${R}  [X]  $1${NC}"; }

# ── Caja de menú ─────────────────────────────────────────────────────
box_top() { echo -e "${C}╔══════════════════════════════════════════╗${NC}"; }
box_mid() { echo -e "${C}╠══════════════════════════════════════════╣${NC}"; }
box_bot() { echo -e "${C}╚══════════════════════════════════════════╝${NC}"; }
# brow_title: linea de titulo dentro de la caja
brow_title() {
    local text="$1"
    printf "${C}║${NC}${W}%-42s${NC}${C}║${NC}\n" "  $text"
}
# brow_item <num_color> <num> <texto>
brow_item() {
    local nc="$1" num="$2" txt="$3"
    printf "${C}║  ${NC}${nc}%s${NC}  %-38s${C}║${NC}\n" "$num)" "$txt"
}

# ── Limpiar título para nombre de archivo ────────────────────────────
limpiar_titulo() {
    local titulo="$1"
    local maxlen="${2:-25}"

    # Transliterar acentos y caracteres especiales
    titulo=$(echo "$titulo" | sed \
        -e 's/[áàâäãå]/a/g' -e 's/[ÁÀÂÄÃÅ]/A/g' \
        -e 's/[éèêë]/e/g'   -e 's/[ÉÈÊË]/E/g' \
        -e 's/[íìîï]/i/g'   -e 's/[ÍÌÎÏ]/I/g' \
        -e 's/[óòôöõø]/o/g' -e 's/[ÓÒÔÖÕØ]/O/g' \
        -e 's/[úùûü]/u/g'   -e 's/[ÚÙÛÜ]/U/g' \
        -e 's/[ñ]/n/g'      -e 's/[Ñ]/N/g' \
        -e 's/[ç]/c/g'      -e 's/[Ç]/C/g' \
        -e 's/[ý]/y/g'      -e 's/[Ý]/Y/g')

    # Eliminar no-ASCII (emojis, símbolos raros)
    titulo=$(echo "$titulo" | LC_ALL=C sed 's/[^[:print:]]//g' | \
             tr -dc '[:alnum:][:space:]_.,!()-')

    # Eliminar caracteres inválidos en nombres de archivo
    titulo=$(echo "$titulo" | sed 's/[\/:\\*?"<>|#@]//g')

    # Espacios y guiones bajos múltiples -> uno solo
    titulo=$(echo "$titulo" | sed 's/[[:space:]_]\+/_/g')

    # Quitar guiones bajos al inicio y final
    titulo=$(echo "$titulo" | sed 's/^_//;s/_$//')

    [[ -z "$titulo" ]] && titulo="video"

    # Truncar
    titulo="${titulo:0:$maxlen}"
    titulo="${titulo%_}"

    echo "$titulo"
}

# ── Actualizar yt-dlp ─────────────────────────────────────────────────
actualizar_ytdlp() {
    clear
    echo
    box_top
    brow_title "       ACTUALIZANDO YT-DLP"
    box_bot
    echo
    info "Buscando actualizaciones..."
    echo

    local output
    output=$(yt-dlp -U 2>&1 || true)

    if echo "$output" | grep -qi "up.to.date"; then
        ok "yt-dlp ya esta en la version mas reciente"
    elif echo "$output" | grep -qi "updated"; then
        ok "yt-dlp actualizado correctamente!"
    else
        warn "No se pudo verificar la actualizacion"
    fi

    sleep 1
    clear
}

# ── Menú principal ────────────────────────────────────────────────────
show_header() {
    clear
    echo
    box_top
    brow_title "      DESCARGADOR DE VIDEO"
    box_mid
    brow_item "$M" "1" "Descargar videos de TikTok"
    brow_item "$M" "2" "Descargar videos de YouTube"
    brow_item "$M" "3" "Descargar videos de Facebook"
    brow_item "$R" "0" "Salir"
    box_bot
    echo
}

# ====================================================================
# TIKTOK
# ====================================================================
descargar_tiktok() {
    clear
    echo
    box_top
    brow_title "        TIKTOK DOWNLOADER"
    box_mid
    brow_item "$M" "1" "Descargar video (MP4)"
    brow_item "$M" "2" "Descargar solo audio (MP3)"
    brow_item "$R" "0" "Volver al menu"
    box_bot
    echo
    echo -en "${Y}  Elige una opcion: ${NC}"
    read -r modo_tiktok

    if [[ "$modo_tiktok" == "0" ]]; then
        info "Volviendo al menu..."
        sleep 1
        return
    fi

    if [[ "$modo_tiktok" != "1" && "$modo_tiktok" != "2" ]]; then
        err "Opcion invalida."
        sleep 1
        return
    fi

    echo
    info "Pega la URL del video de TikTok"
    echo -en "${Y}  URL: ${NC}"
    read -r url

    # Limpiar parámetros de la URL
    local url_limpia
    url_limpia="${url%%\?*}"

    # Detectar slideshow (photo) y convertir a video
    local es_photo=false
    if echo "$url_limpia" | grep -q "/photo/"; then
        es_photo=true
        url_limpia="${url_limpia/\/photo\///video/}"
    fi

    echo
    sep
    echo -en "${G}  [OK] URL limpia: ${NC}"
    echo -e "${W}$url_limpia${NC}"
    sep
    echo

    # Obtener título limpio
    local titulo_raw titulo_limpio
    titulo_raw=$(yt-dlp --get-title "$url_limpia" 2>/dev/null || echo "video")
    titulo_limpio=$(limpiar_titulo "$titulo_raw" 25)

    # ── Modo MP3 ──────────────────────────────────────────────────────
    if [[ "$modo_tiktok" == "2" || "$es_photo" == "true" ]]; then
        if [[ "$es_photo" == "true" ]]; then
            warn "Slideshow detectado -> descargando solo audio (MP3)..."
        else
            info "Extrayendo audio en MP3..."
        fi
        echo
        yt-dlp -x --audio-format mp3 --audio-quality 0 \
               --output "${titulo_limpio}.%(ext)s" "$url_limpia"
        echo
        sep
        ok "Descarga completada exitosamente!"
        echo -e "  Archivo: ${W}${titulo_limpio}.mp3${NC}"
        sep
        echo
        echo -en "${DIM}  Presiona Enter para volver al menu${NC}"
        read -r
        return
    fi

    # ── Modo VIDEO ────────────────────────────────────────────────────
    info "Analizando formatos disponibles..."
    echo

    local formatos_raw
    formatos_raw=$(yt-dlp -F "$url_limpia" 2>/dev/null || true)

    # Buscar mejor formato: primero bytevc1, si no el último disponible
    local formato
    formato=$(echo "$formatos_raw" | grep "bytevc1" | tail -1 | awk '{print $1}')

    if [[ -z "$formato" ]]; then
        formato=$(echo "$formatos_raw" | grep -v "^\s*ID\s" | \
                  grep -v "^-\{3\}" | grep -v "^download" | \
                  grep '\S' | tail -1 | awk '{print $1}')
    fi

    if [[ -z "$formato" ]]; then
        err "No se encontro ningun formato de video."
        info "Verifica que la URL sea correcta."
        echo
        echo -en "${DIM}  Presiona Enter para volver${NC}"
        read -r
        return
    fi

    sep
    echo -en "${G}  [OK] Mejor formato: ${NC}"
    echo -e "${M}${formato}${NC}"
    sep
    echo
    info "Iniciando descarga..."
    echo

    # Descargar en archivo temporal
    local tmp_name="tiktok_tmp_dl"
    yt-dlp -f "$formato" --output "${tmp_name}.%(ext)s" "$url_limpia"

    # Detectar extensión del archivo descargado
    local archivo_tmp ext_real=""
    archivo_tmp=""
    for ext in mp4 webm mkv mov avi; do
        if [[ -f "${tmp_name}.${ext}" ]]; then
            archivo_tmp="${tmp_name}.${ext}"
            ext_real="$ext"
            break
        fi
    done

    echo
    sep
    ok "Descarga completada exitosamente!"
    sep
    echo

    if [[ -z "$archivo_tmp" ]]; then
        echo -en "${DIM}  Presiona Enter para volver al menu${NC}"
        read -r
        return
    fi

    # ── Preguntar conversión para DaVinci Resolve ─────────────────────
    _menu_conversion_tiktok "$archivo_tmp" "$ext_real" "$titulo_limpio"
}

# Submenú de conversión (reutilizable para TikTok y Facebook)
_menu_conversion_davinci() {
    local archivo_tmp="$1"
    local ext_real="$2"
    local titulo="$3"

    box_top
    brow_title "  CONVERTIR PARA DAVINCI RESOLVE"
    box_bot
    echo
    echo -e "  Titulo: ${M}${titulo}${NC}"
    echo
    echo -e "  ${G}S)${NC}  Convertir  ->  [nombre]_convert.mp4 (audio PCM) y borrar original"
    echo -e "  ${R}N)${NC}  No convertir, guardar original con nombre del video"
    echo
    echo -en "${Y}  Elige una opcion [S/N]: ${NC}"
    read -r conv

    if [[ "$conv" =~ ^[sS]$ ]]; then
        local out_final="${titulo}_convert.mp4"
        echo
        info "Convirtiendo a MP4 con audio PCM..."
        echo
        ffmpeg -i "$archivo_tmp" -c:v copy -c:a pcm_s16le "$out_final" -y
        rm -f "$archivo_tmp"
        echo
        sep
        ok "Conversion completada!"
        sep
        echo
        echo -e "  Archivo final: ${W}${out_final}${NC}"
    else
        local out_final="${titulo}.${ext_real}"
        mv "$archivo_tmp" "$out_final"
        echo
        sep
        ok "Archivo guardado como:"
        echo -e "  ${W}${out_final}${NC}"
        sep
    fi

    echo
    echo -en "${DIM}  Presiona Enter para volver al menu${NC}"
    read -r
}

_menu_conversion_tiktok() {
    _menu_conversion_davinci "$1" "$2" "$3"
}

# ====================================================================
# YOUTUBE
# ====================================================================
descargar_youtube() {
    clear
    echo
    box_top
    brow_title "       YOUTUBE DOWNLOADER"
    box_bot
    echo
    info "Pega la URL del video de YouTube"
    echo -en "${Y}  URL: ${NC}"
    read -r url

    # Limpiar parámetros extra (&list=, &index=, etc.)
    local url_limpia
    if echo "$url" | grep -q "v="; then
        local vid="${url#*v=}"
        vid="${vid%%&*}"
        vid="${vid%%\?*}"
        vid="${vid%%\#*}"
        url_limpia="https://www.youtube.com/watch?v=${vid}"
    else
        url_limpia="${url%%\&*}"
        url_limpia="${url_limpia%%\#*}"
    fi

    echo
    sep
    echo -en "${G}  [OK] URL limpia: ${NC}"
    echo -e "${W}$url_limpia${NC}"
    sep
    echo
    info "Detectando calidades disponibles..."
    echo

    local formatos_raw
    formatos_raw=$(yt-dlp -F "$url_limpia" 2>/dev/null || true)

    local res_pats=("4320" "2160" "1440" "1080" "720" "480" "360" "240" "144")
    local res_icos=("8K (4320p)" "4K (2160p)" "2K (1440p)" "1080p" "720p" "480p" "360p" "240p" "144p")

    declare -A alturas
    local contador=1

    box_top
    brow_title "         CALIDAD DE VIDEO"
    box_mid
    brow_item "$R" "0" "Cancelar y volver al menu"

    for i in "${!res_pats[@]}"; do
        local pat="${res_pats[$i]}"
        local found
        found=$(echo "$formatos_raw" | grep "$pat" | grep -v "audio only" | head -1 || true)
        if [[ -n "$found" ]]; then
            brow_item "$M" "$contador" "${res_icos[$i]}"
            alturas[$contador]="$pat"
            ((contador++))
        fi
    done

    local audio_opcion=$contador
    ((contador++))
    brow_item "$M" "$audio_opcion" "Solo audio (MP3 via ffmpeg)"
    box_bot
    echo

    local eleccion
    while true; do
        echo -en "${Y}  Elige una opcion: ${NC}"
        read -r eleccion
        [[ "$eleccion" =~ ^[0-9]+$ ]] && break
        warn "Opcion invalida"
    done

    if [[ "$eleccion" == "0" ]]; then
        info "Volviendo al menu..."
        sleep 1
        return
    fi

    echo
    info "Iniciando descarga..."
    echo

    local titulo_raw titulo_yt
    titulo_raw=$(yt-dlp --get-title "$url_limpia" 2>/dev/null || echo "video")
    titulo_yt=$(limpiar_titulo "$titulo_raw" 25)

    if [[ "$eleccion" == "$audio_opcion" ]]; then
        # ── Submenú: formato de audio ─────────────────────────────────
        echo
        box_top
        brow_title "      FORMATO DE AUDIO"
        box_mid
        brow_item "$M" "1" "MP3  (compatible, ~320kbps)"
        brow_item "$M" "2" "FLAC (sin perdida)"
        brow_item "$M" "3" "WAV  (sin compresion, PCM)"
        brow_item "$M" "4" "OGG  (Vorbis, codigo abierto)"
        brow_item "$M" "5" "M4A  (AAC, Apple/Android)"
        brow_item "$M" "6" "OPUS (mejor calidad/tamano)"
        brow_item "$R" "0" "Cancelar"
        box_bot
        echo
        local fmt_audio
        while true; do
            echo -en "${Y}  Elige formato de audio: ${NC}"
            read -r fmt_audio
            [[ "$fmt_audio" =~ ^[0-6]$ ]] && break
            warn "Opcion invalida"
        done

        if [[ "$fmt_audio" == "0" ]]; then
            info "Cancelado."
            echo -en "${DIM}  Presiona Enter para volver${NC}"
            read -r
            return
        fi

        local audio_fmt audio_ext audio_args
        case "$fmt_audio" in
            1) audio_fmt="mp3";  audio_ext="mp3";  audio_args="--audio-quality 0 --postprocessor-args \"-ar 44100\"" ;;
            2) audio_fmt="flac"; audio_ext="flac"; audio_args="--audio-quality 0" ;;
            3) audio_fmt="wav";  audio_ext="wav";  audio_args="--audio-quality 0" ;;
            4) audio_fmt="vorbis"; audio_ext="ogg"; audio_args="--audio-quality 0" ;;
            5) audio_fmt="m4a"; audio_ext="m4a";  audio_args="--audio-quality 0" ;;
            6) audio_fmt="opus"; audio_ext="opus"; audio_args="--audio-quality 0" ;;
        esac

        echo
        info "Extrayendo audio en ${audio_ext^^}..."
        echo
        eval yt-dlp -f "bestaudio" --extract-audio \
               --audio-format "$audio_fmt" $audio_args \
               --output "${titulo_yt}.%(ext)s" "$url_limpia"
        echo
        sep
        ok "Audio descargado exitosamente!"
        echo -e "  Archivo: ${W}${titulo_yt}.${audio_ext}${NC}"
        sep
        echo
        echo -en "${DIM}  Presiona Enter para volver al menu${NC}"
        read -r
        return
    elif [[ -n "${alturas[$eleccion]+x}" ]]; then
        local altura="${alturas[$eleccion]}"
        yt-dlp -f "bestvideo[height=${altura}]+bestaudio/best[height=${altura}]" \
               --merge-output-format mp4 \
               --output "${titulo_yt}.%(ext)s" "$url_limpia"
    else
        err "Opcion invalida."
        echo -en "${DIM}  Presiona Enter para volver${NC}"
        read -r
        return
    fi

    echo
    sep
    ok "Descarga completada exitosamente!"
    sep
    echo
    echo -en "${DIM}  Presiona Enter para volver al menu${NC}"
    read -r
}

# ====================================================================
# FACEBOOK
# ====================================================================
descargar_facebook() {
    clear
    echo
    box_top
    brow_title "       FACEBOOK DOWNLOADER"
    box_mid
    brow_item "$M" "1" "Descargar video HD (mejor calidad)"
    brow_item "$M" "2" "Descargar video SD (menor calidad)"
    brow_item "$M" "3" "Descargar solo audio (MP3)"
    brow_item "$R" "0" "Volver al menu"
    box_bot
    echo

    local modo_fb
    echo -en "${Y}  Elige una opcion: ${NC}"
    read -r modo_fb

    if [[ "$modo_fb" == "0" ]]; then
        info "Volviendo al menu..."
        sleep 1
        return
    fi

    if [[ "$modo_fb" != "1" && "$modo_fb" != "2" && "$modo_fb" != "3" ]]; then
        err "Opcion invalida."
        sleep 1
        return
    fi

    echo
    info "Pega la URL del video de Facebook"
    echo -en "${Y}  URL: ${NC}"
    read -r url

    # Limpiar URL: quitar parámetros de tracking
    local url_limpia
    url_limpia="${url%%\?*}"

    echo
    sep
    echo -en "${G}  [OK] URL limpia: ${NC}"
    echo -e "${W}$url_limpia${NC}"
    sep
    echo

    # Obtener lista de formatos
    info "Analizando formatos disponibles..."
    echo

    local formatos_raw
    formatos_raw=$(yt-dlp -F "$url_limpia" 2>/dev/null || true)

    if [[ -z "$formatos_raw" ]]; then
        err "No se pudo obtener informacion del video."
        info "Verifica que la URL sea correcta y el video sea publico."
        echo
        echo -en "${DIM}  Presiona Enter para volver${NC}"
        read -r
        return
    fi

    # Mostrar formatos detectados (debug ligero)
    echo "$formatos_raw"
    echo

    local titulo_raw titulo_limpio
    titulo_raw=$(yt-dlp --get-title "$url_limpia" 2>/dev/null || echo "video")
    titulo_limpio=$(limpiar_titulo "$titulo_raw" 25)

    local tmp_name="fb_tmp_dl"

    # ── Modo MP3 ──────────────────────────────────────────────────────
    if [[ "$modo_fb" == "3" ]]; then
        info "Extrayendo audio en MP3..."
        echo
        yt-dlp -x --audio-format mp3 --audio-quality 0 \
               --output "${titulo_limpio}.%(ext)s" "$url_limpia"
        echo
        sep
        ok "Descarga completada exitosamente!"
        echo -e "  Archivo: ${W}${titulo_limpio}.mp3${NC}"
        sep
        echo
        echo -en "${DIM}  Presiona Enter para volver al menu${NC}"
        read -r
        return
    fi

    # ── Seleccionar formato de video (HD o SD) ────────────────────────
    local formato_video

    if [[ "$modo_fb" == "1" ]]; then
        # HD: buscar el formato de mayor resolución con video
        # Preferir dash video + dash audio por separado; si no, bestvideo
        local fmt_hd_video fmt_hd_audio

        # Buscar el último formato mp4_dash con video (mayor resolución)
        fmt_hd_video=$(echo "$formatos_raw" | \
                       grep -i "mp4_dash\|dash" | \
                       grep -iv "audio only" | \
                       tail -1 | awk '{print $1}' || true)

        # Buscar audio dash
        fmt_hd_audio=$(echo "$formatos_raw" | \
                       grep -i "m4a_dash\|audio" | \
                       grep -i "audio only" | \
                       head -1 | awk '{print $1}' || true)

        if [[ -n "$fmt_hd_video" && -n "$fmt_hd_audio" ]]; then
            formato_video="${fmt_hd_video}+${fmt_hd_audio}"
            sep
            echo -en "${G}  [OK] Formato HD: ${NC}"
            echo -e "${M}video=${fmt_hd_video}  audio=${fmt_hd_audio}${NC}"
            sep
        else
            # Fallback: bestvideo+bestaudio
            formato_video="bestvideo+bestaudio"
            sep
            warn "No se encontro DASH especifico, usando bestvideo+bestaudio"
            sep
        fi

    else
        # SD: buscar el primer formato mp4_dash con video (menor resolución)
        local fmt_sd_video fmt_sd_audio

        fmt_sd_video=$(echo "$formatos_raw" | \
                       grep -i "mp4_dash\|dash" | \
                       grep -iv "audio only" | \
                       head -1 | awk '{print $1}' || true)

        fmt_sd_audio=$(echo "$formatos_raw" | \
                       grep -i "m4a_dash\|audio" | \
                       grep -i "audio only" | \
                       head -1 | awk '{print $1}' || true)

        if [[ -n "$fmt_sd_video" && -n "$fmt_sd_audio" ]]; then
            formato_video="${fmt_sd_video}+${fmt_sd_audio}"
            sep
            echo -en "${G}  [OK] Formato SD: ${NC}"
            echo -e "${M}video=${fmt_sd_video}  audio=${fmt_sd_audio}${NC}"
            sep
        else
            formato_video="worstvideo+worstaudio/worst"
            sep
            warn "No se encontro DASH especifico, usando calidad minima"
            sep
        fi
    fi

    echo
    info "Iniciando descarga..."
    echo

    yt-dlp -f "$formato_video" \
           --merge-output-format mp4 \
           --output "${tmp_name}.%(ext)s" \
           "$url_limpia"

    # Detectar archivo descargado
    local archivo_tmp ext_real=""
    archivo_tmp=""
    for ext in mp4 webm mkv mov avi; do
        if [[ -f "${tmp_name}.${ext}" ]]; then
            archivo_tmp="${tmp_name}.${ext}"
            ext_real="$ext"
            break
        fi
    done

    echo
    sep
    ok "Descarga completada exitosamente!"
    sep
    echo

    if [[ -z "$archivo_tmp" ]]; then
        echo -en "${DIM}  Presiona Enter para volver al menu${NC}"
        read -r
        return
    fi

    # ── Preguntar conversión para DaVinci Resolve (igual que TikTok) ──
    _menu_conversion_davinci "$archivo_tmp" "$ext_real" "$titulo_limpio"
}

# ====================================================================
# MAIN
# ====================================================================
actualizar_ytdlp
show_header

while true; do
    echo -en "${Y}  Elige una opcion: ${NC}"
    read -r opcion

    case "$opcion" in
        1)
            descargar_tiktok
            show_header
            ;;
        2)
            descargar_youtube
            show_header
            ;;
        3)
            descargar_facebook
            show_header
            ;;
        0)
            echo
            echo -e "${C}  Hasta luego!${NC}"
            echo
            exit 0
            ;;
        *)
            err "Opcion invalida"
            sleep 1
            show_header
            ;;
    esac
done
