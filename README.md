# 🎬 Instalación de DaVinci Resolve en Arch Linux

> Guía completa para instalar DaVinci Resolve (Free o Studio) en Arch Linux con soporte para AMD, NVIDIA e Intel.

---

## 📋 Requisitos previos

- Arch Linux actualizado (`sudo pacman -Syu`)
- `yay` u otro AUR helper instalado
- [https://aur.archlinux.org/packages/davinci-resolve-studio](https://aur.archlinux.org/packages/davinci-resolve-studio)

---

## Paso 1 — Instalar dependencias desde los repositorios oficiales

```bash
sudo pacman -S \
  apr-util \
  ffmpeg4.4 \
  fuse2 \
  glu \
  gst-plugins-bad-libs \
  jdk-openjdk \
  libc++ \
  libc++abi \
  libxcrypt \
  libxcrypt-compat \
  luajit \
  qt5-multimedia \
  qt5-quickcontrols2 \
  qt5-svg \
  qt5-x11extras \
  tbb \
  xmlsec \
  libarchive \
  patchelf \
  xdg-user-dirs
```

---

## Paso 2 — Instalar dependencias desde el archivo histórico de Arch

Algunos paquetes requeridos ya no están en los repositorios actuales. Se instalan directamente desde el archivo:

```bash
sudo pacman -U \
  https://archive.archlinux.org/packages/g/gtk2/gtk2-2.24.33-5-x86_64.pkg.tar.zst \
  https://archive.archlinux.org/packages/l/libpng12/libpng12-1.2.59-2-x86_64.pkg.tar.zst \
  https://archive.archlinux.org/packages/q/qt5-location/qt5-location-5.15.9+kde+r4-1-x86_64.pkg.tar.zst \
  https://archive.archlinux.org/packages/q/qt5-webengine/qt5-webengine-5.15.19-4-x86_64.pkg.tar.zst \
  https://archive.archlinux.org/packages/q/qt5-websockets/qt5-websockets-5.15.18+kde+r2-1-x86_64.pkg.tar.zst \
  https://archive.archlinux.org/packages/q/qt5-webchannel/qt5-webchannel-5.15.18+kde+r3-1-x86_64.pkg.tar.zst
```

Respaldo:

🔗 **[https://sourceforge.net/projects/fabiololix-os-archive/files/Packages/](https://sourceforge.net/projects/fabiololix-os-archive/files/Packages/)**

---

## Paso 3 — Instalar drivers de GPU con soporte OpenCL

DaVinci Resolve requiere drivers **OpenGL y OpenCL** funcionales. Instala **solo** el bloque correspondiente a tu hardware.

> 💡 Puedes verificar qué implementaciones OpenCL están activas con: `ls /etc/OpenCL/vendors`

### 🔴 AMD

DaVinci Resolve funciona con varias implementaciones OpenCL en AMD. Se recomiendan las siguientes según tu GPU:

#### RX 500 (Polaris) y más nuevos — ROCm (recomendado)

```bash
# Opción A: opencl-amd desde AUR (incluye ROCm + ORCA legacy, más compatible con DR)
yay -S opencl-amd

# Opción B: rocm-opencl-runtime desde repos oficiales
sudo pacman -S rocm-opencl-runtime
```

> ⚠️ Para GPUs anteriores a Vega (RX 580, etc.), agrega la variable de entorno al lanzar Resolve:
> ```bash
> ROC_ENABLE_PRE_VEGA=1 /opt/resolve/bin/resolve
> ```

> ⚠️ Si usas RX 580 con `opencl-amd` y mesa y DaVinci crashea, prueba con `rocm-opencl-runtime` y `ROC_ENABLE_PRE_VEGA=1`.

#### Alternativa: OpenCL via Mesa (Rusticl) — cualquier GPU AMD soportada por Mesa

```bash
sudo pacman -S opencl-mesa
```

> Para activar Rusticl en AMD: `RUSTICL_ENABLE=radeonsi /opt/resolve/bin/resolve`


Si tienes `rocm-opencl-runtime` o `opencl-amd` debes borrar `opencl-mesa`, solo funciona con un paquete de openCL

---

### 🟢 NVIDIA

Desde diciembre 2025, Arch Linux usa **módulos open source de NVIDIA por defecto** (driver 590+). El paquete varía según la antigüedad de tu GPU:

#### RTX 20xx / GTX 1650 (Turing) y más nuevos — open kernel modules

```bash
sudo pacman -S nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings opencl-nvidia lib32-opencl-nvidia
```

#### GTX 10xx (Pascal) y GTX 900 (Maxwell) — legacy desde AUR

```bash
yay -S nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils
sudo pacman -S opencl-nvidia lib32-opencl-nvidia
```

> ⚠️ Pascal (GTX 10xx) y Maxwell (GTX 900) ya no están soportados en los repositorios oficiales desde el driver 590. Usa el paquete legacy `nvidia-580xx-dkms` del AUR.

> ⚠️ Si tienes configuración híbrida Intel/NVIDIA en modo on-demand, necesitas lanzar Resolve con:
> ```bash
> __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia /opt/resolve/bin/resolve
> ```

---

### 🔵 Intel

#### Gen12 (Tiger/Rocket Lake) en adelante — intel-compute-runtime (recomendado, probado y funcional con DR)

```bash
sudo pacman -S intel-compute-runtime vulkan-intel lib32-vulkan-intel intel-media-driver
```

#### Gen8–Gen11 (Broadwell, Skylake, Ice Lake) — runtime legacy

```bash
yay -S intel-compute-runtime-legacy vulkan-intel lib32-vulkan-intel
```

#### Alternativa: OpenCL via Mesa (Rusticl) — iGPU Intel soportadas por Mesa

```bash
sudo pacman -S opencl-mesa
```

> Para activar Rusticl en Intel: `RUSTICL_ENABLE=iris /opt/resolve/bin/resolve`

> ❌ **No usar:** `beignet`, `intel-opencl` ni `intel-opencl-runtime` — están deprecados y causan core dump con DaVinci Resolve.

---

### Verificar que OpenCL funciona correctamente

```bash
# Instalar clinfo si no está disponible
sudo pacman -S clinfo

# Ver dispositivos OpenCL detectados
clinfo -l

# Ver todas las propiedades detalladas
clinfo
```

---

## Paso 4 — Clonar los paquetes del AUR

```bash
git clone https://aur.archlinux.org/davinci-resolve.git        # Versión gratuita
git clone https://aur.archlinux.org/davinci-resolve-studio.git # Versión Studio (paga)
```

---

## Paso 5 — Descargar el instalador de DaVinci Resolve

Descarga el instalador oficial desde la página de soporte de Blackmagic Design:

🔗 **https://www.blackmagicdesign.com/mx/support/**

1. Busca **DaVinci Resolve** en la lista de productos
2. Selecciona la versión para **Linux** (`.run`)
3. Completa el formulario de registro y descarga el archivo
4. Mueve el `.run` descargado dentro de la carpeta clonada del AUR correspondiente:

```bash
# Ejemplo para la versión gratuita:
mv DaVinci_Resolve_*.run davinci-resolve/

# Para Studio:
mv DaVinci_Resolve_Studio_*.run davinci-resolve-studio/
```

---

## Paso 6 — Compilar e instalar con makepkg

```bash
# Versión gratuita
cd davinci-resolve
makepkg -fsi

# O versión Studio
cd davinci-resolve-studio
makepkg -fsi
```

| Flag | Descripción |
|------|-------------|
| `-f` | Fuerza la recompilación aunque ya exista el paquete |
| `-s` | Instala dependencias faltantes automáticamente |
| `-i` | Instala el paquete resultante con pacman |

---

## Paso 7 — Plugins adicionales (opcionales)

Estos plugins amplían el soporte de codecs en Linux:

- 🔗 [ffmpeg_encoder_plugin](https://github.com/EdvinNilsson/ffmpeg_encoder_plugin) — Encoder FFMPEG adicional
```bash
git clone https://github.com/EdvinNilsson/ffmpeg_encoder_plugin.git

cd ffmpeg_encoder_plugin ; mkdir build ; cd build

cmake .. ; make

mkdir -p /opt/resolve/IOPlugins/ffmpeg_encoder_plugin.dvcp.bundle/Contents/Linux-x86-64/ && \
  cp -rf ffmpeg_encoder_plugin.dvcp /opt/resolve/IOPlugins/ffmpeg_encoder_plugin.dvcp.bundle/Contents/Linux-x86-64/
```

- 🔗 [davinci-linux-aac-codec](https://github.com/Toxblh/davinci-linux-aac-codec) — Soporte de codec AAC
```bash
sudo pacman -S clang --noconfirm ; git clone https://github.com/Toxblh/davinci-linux-aac-codec.git

cd davinci-linux-aac-codec ; ./build.sh ; sudo ./install.sh 
```

---

### MP4 / H.264 / H.265 / AAC — resumen de soporte

| Formato | Free | Studio |
|---|---|---|
| MP4 (con codecs soportados) | ✅ | ✅ |
| H.264 / H.265 | ❌ | ✅ |
| AAC | ❌ | ❌ |

Alternativa para convertir a formato compatible con la versión Free:

```bash
# MPEG-4 (muy ligero, DR Free lo soporta, algo de pérdida): MPEG-4 -q:v 2 ~ 2–5 GB Media
ffmpeg -i input.mp4 -c:v mpeg4 -q:v 2 -c:a alac output.mp4

# AV1 con audio PCM (moderno, buena compresión, compatible con DR Free): AV1 CRF 30 ~ 1–3 GB Buena
ffmpeg -i input.mp4 -c:v libsvtav1 -crf 30 -preset 6 -c:a pcm_s32le output.mp4

# DNxHR LB (versión ligera de DNxHR, la que ya tienes pero más pequeña): DNxHR LB ~ 10–15 GB Buena
ffmpeg -i input.mp4 -c:v dnxhd -profile:v dnxhr_lb -pix_fmt yuv422p -c:a alac output.mov
```


## 📚 Referencias

- [ArchWiki — DaVinci Resolve](https://wiki.archlinux.org/title/DaVinci_Resolve)
- [Blackmagic Design — Soporte oficial](https://www.blackmagicdesign.com/mx/support/)
- [ffmpeg_encoder_plugin](https://github.com/EdvinNilsson/ffmpeg_encoder_plugin)
- [davinci-linux-aac-codec](https://github.com/Toxblh/davinci-linux-aac-codec)

---

## 🔧 Solución de problemas comunes

### No abre / crash al iniciar — error de libglib

```bash
# Eliminar o mover las librerías internas de Resolve que conflictúan con las del sistema:
sudo rm /opt/resolve/libs/libglib-2.0.so*
sudo rm /opt/resolve/libs/libgio-2.0.so*
sudo rm /opt/resolve/libs/libgmodule-2.0.so*
# O forzar uso de las librerías del sistema al lanzar:
LD_PRELOAD="/usr/lib/libglib-2.0.so /usr/lib/libgio-2.0.so /usr/lib/libgmodule-2.0.so" /opt/resolve/bin/resolve
```

### No abre en Wayland

DaVinci Resolve no soporta Wayland nativamente. Si `QT_QPA_PLATFORM=wayland` está activo, forzar XCB:

```bash
QT_QPA_PLATFORM=xcb /opt/resolve/bin/resolve
```

### Error OpenCL -1001 (NVIDIA)

Asegúrate de que la versión de `opencl-nvidia` coincida con la del driver instalado. 
Si traes instalado `opencl-mesa` para que no genere conflictos opencl de tu grafica
Verifica con `clinfo -l` que el dispositivo NVIDIA aparece listado.

### Sin audio en la previsualización

DaVinci Resolve usa ALSA directamente

Si usas PipeWire:
```bash
yay -S pipewire pipewire-pulse pipewire-alsa lib32-pipewire lib32-pipewire-jack lib32-pipewire-v4l2 
```

Si usas PulseAudio:
```bash
yay -S pulse pulseaudio-alsa
sudo su
echo pcm.!default pulse > /etc/asound.conf
echo ctl.!default pulse >> /etc/asound.conf
exit
```

### Resolve se bloquea al poner acentos 

Lo solución fue muy sencilla fue agregar el idioma Ingles al locale
Fuente : https://youtu.be/5Mo-GaBIpT4?si=oSeBf7WDO-CZTjI6 [[https://youtu.be/5Mo-GaBIpT4?si=oSeBf7WDO-CZTjI6](https://youtu.be/5Mo-GaBIpT4?si=oSeBf7WDO-CZTjI6)

```bash
sudo su
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen ; locale-gen
exit
```

### Resolve no escribe acentos

Xmodmap es una herramienta de X11 que te permite reasignar las teclas del teclado a nivel del servidor gráfico y funciona bien wayland gracias a Xwayland

```bash
cat >> ~/.Xmodmap << 'EOF'
keycode  26 = e E e E eacute Eacute EuroSign cent
keycode  38 = a A a A aacute Aacute ae AE
keycode  31 = i I i I iacute Iacute rightarrow idotless
keycode  32 = o O o O oacute Oacute oslash Oslash
keycode  30 = u U u U uacute Uacute downarrow uparrow
keycode  32 = o O o O oacute Oacute oslash Oslash
EOF
```

Y para aplicarlo sin reiniciar:
```bash
xmodmap ~/.Xmodmap
```

Y lo puedes agregar a tu archivo de shell, .zshrc .bashrc

### No reconoce las Tipografias instaladas en ~/.local/share/fonts

| Pestaña de Fusion | Menú de Fusion | Ajustes de Fusion | Mapa de Ruta | Defaults > Fonts > Select folder | 
|-------------------|----------------|-------------------|--------------|----------------------------------|

### La app dice que ya hay otra instancia corriendo (lock file)

```bash
# Eliminar el lock file huérfano:
rm /tmp/qtsingleapp-DaVinc-*-lockfile
```

### No descarga extras / AI models (error TLS)

```bash
sudo mkdir -p /etc/pki/
sudo ln -s /etc/ssl /etc/pki/tls
```

### Falla al activar licencia Studio

```bash
sudo chmod -R 7777 /opt/resolve/.license/
```

## 📚 Davinci Resolve Studio Full

- [https://pastebin.com/raw/vMwatbqi](https://pastebin.com/raw/vMwatbqi)

---

### Revisar logs de DaVinci Resolve

```bash
cat ~/.local/share/DaVinciResolve/logs/ResolveDebug.txt
```

---

> 📌 Esta guía está basada en Arch Linux. Para distros derivadas (Manjaro, EndeavourOS) los pasos son similares pero algunos paquetes pueden diferir.
