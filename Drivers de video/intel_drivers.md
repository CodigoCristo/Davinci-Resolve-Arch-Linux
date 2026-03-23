# Guía de drivers Intel en Arch Linux

Fuentes:
[Intel graphics](https://wiki.archlinux.org/title/Intel_graphics) ·
[Hybrid graphics](https://wiki.archlinux.org/title/Hybrid_graphics) ·
[NVIDIA Optimus](https://wiki.archlinux.org/title/NVIDIA_Optimus) ·
[PRIME](https://wiki.archlinux.org/title/PRIME) ·
[Vulkan](https://wiki.archlinux.org/title/Vulkan) ·
[OpenGL](https://wiki.archlinux.org/title/OpenGL) ·
[Hardware video acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration) ·
[GPGPU / OpenCL](https://wiki.archlinux.org/title/General-purpose_computing_on_graphics_processing_units)

---

## Resumen rápido

| Familia GPU | Generación GPU | Driver 3D | Vulkan | VA-API | OpenCL |
|---|---|---|---|---|---|
| Intel Arc (Alchemist/Battlemage) | Xe HPG / Xe2 | `mesa` | `vulkan-intel` | `intel-media-driver` | `intel-compute-runtime` |
| Core Ultra / Raptor Lake / Alder Lake | Gen 12 | `mesa` | `vulkan-intel` | `intel-media-driver` | `intel-compute-runtime` + `vpl-gpu-rt` |
| Tiger Lake / Rocket Lake | Gen 12 | `mesa` | `vulkan-intel` | `intel-media-driver` | `intel-compute-runtime` + `vpl-gpu-rt` |
| Ice Lake | Gen 11 | `mesa` | `vulkan-intel` | `intel-media-driver` | `intel-compute-runtime-legacy` (AUR) |
| Coffee Lake / Whiskey Lake / Comet Lake | Gen 9.5 | `mesa` | `vulkan-intel` | `intel-media-driver` + `libva-intel-driver` | `intel-compute-runtime-legacy` (AUR) |
| Skylake / Kaby Lake | Gen 9 | `mesa` | `vulkan-intel` | `intel-media-driver` + `libva-intel-driver` | `intel-compute-runtime-legacy` (AUR) |
| Broadwell / Haswell / Ivy Bridge | Gen 8 / 7 | `mesa` | parcial (Gen 8) | `libva-intel-driver` | `beignet` (AUR, deprecado) |
| Sandy Bridge / Ironlake | Gen 6 / 5 | `mesa` | No | `libva-intel-driver` | No |
| GMA 4500 y anterior (pre-Gen 6) | Gen 4 y anterior | `mesa-amber` | No | No | No |

> Intel Gen N hace referencia a la generación de la GPU, **no** del procesador. Un Intel de 12ª gen de CPU puede tener GPU Gen 12.
> PowerVR (GMA 3600) no tiene soporte en drivers open source.

---

## Instalación

### 1. Driver base — aceleración 3D (OpenGL)

```bash
# Gen 3 y posterior — recomendado para la inmensa mayoría
sudo pacman -S mesa lib32-mesa mesa-utils lib32-mesa-utils

# Gen 2 a Gen 7 (Ivy Bridge) o si se prefiere driver clásico
sudo pacman -S mesa-amber lib32-mesa-amber
```

#### DDX driver para Xorg

```bash
# Opción recomendada: el driver modesetting incluido en xorg-server
# No necesita instalación adicional — funciona automáticamente.

# Alternativa legacy (Gen 2 a Gen 9) — generalmente NO recomendado
# Puede causar tearing, freezes y problemas en Gen 10+
sudo pacman -S xf86-video-intel
```

> **Nota:** La mayoría de distros (Debian, Fedora, KDE, Mozilla) desaconsejan instalar `xf86-video-intel` y recomiendan usar el `modesetting` genérico. En Gen 11 y posterior `xf86-video-intel` directamente no tiene soporte y causa problemas graves.

### 2. Firmware del kernel

```bash
sudo pacman -S linux-firmware-intel
```

### 3. Vulkan

```bash
# Broadwell (Gen 8) y posterior
sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader
sudo pacman -S vulkan-intel lib32-vulkan-intel
```

### 4. Aceleración de vídeo por hardware (VA-API)

```bash
sudo pacman -S libva lib32-libva                 # biblioteca VA-API base
sudo pacman -S libva-utils                        # proporciona vainfo
sudo pacman -S vdpauinfo                          # verificar VDPAU
sudo pacman -S libvdpau-va-gl                     # capa de traducción VDPAU → VA-API
```

Elegir el driver VA-API según generación:

```bash
# intel-media-driver (iHD) — Broadwell (Gen 8) y posterior — RECOMENDADO para Gen 8+
sudo pacman -S intel-media-driver

# libva-intel-driver (i965) — GMA 4500 hasta Coffee Lake (Gen 4.5 a Gen 9.5)
# También sirve como fallback para modelos más viejos en sistemas Gen 8+
sudo pacman -S libva-intel-driver
```

**Soporte VA-API por generación:**

| Driver VA-API | Generación | Decodificación |
|---|---|---|
| `intel-media-driver` (iHD) | Broadwell y posterior | H.264, H.265, VP8, VP9, AV1 (Tiger Lake+) |
| `libva-intel-driver` (i965) | GMA 4500 — Coffee Lake | H.264, MPEG-2, VC-1, JPEG, VP8, VP9 (parcial) |

Variable de entorno para forzar el driver (solo si no se detecta automáticamente):

```bash
# Para intel-media-driver
export LIBVA_DRIVER_NAME=iHD

# Para libva-intel-driver (legacy)
export LIBVA_DRIVER_NAME=i965
```

### 5. OpenCL

```bash
sudo pacman -S ocl-icd      # ICD loader
sudo pacman -S clinfo        # listar dispositivos OpenCL
```

| Implementación | Paquete | Generación |
|---|---|---|
| **NEO** (open source) | `intel-compute-runtime` | Gen 12 (Rocket/Tiger Lake) y posterior + Arc |
| **NEO legacy** (open source) | `intel-compute-runtime-legacy` (AUR) | Gen 8 (Broadwell) a Gen 11 (Ice Lake) |
| **Beignet** (deprecado) | `beignet` (AUR) | Gen 7 (Ivy Bridge) y posterior |

```bash
# Gen 12 y posterior / Intel Arc — recomendado
sudo pacman -S intel-compute-runtime

# Gen 8 a Gen 11 (Broadwell, Skylake, Kaby Lake, Ice Lake)
yay -S intel-compute-runtime-legacy
```

### 6. Intel VPL (Video Processing Library)

Intel VPL reemplaza a Intel Media SDK para Tiger Lake y posterior:

```bash
sudo pacman -S vpl-gpu-rt   # Tiger Lake y posterior
```

### 7. GuC / HuC — firmware de microcontroladores (Gen 9+)

GuC y HuC ofrecen offloading de tareas multimedia y scheduling a la GPU. El driver `xe` (Gen 12 nuevo) los activa por defecto. Para el driver `i915`:

```bash
# Asegurarse de tener el firmware instalado
sudo pacman -S linux-firmware-intel

# Activar GuC + HuC en /etc/modprobe.d/i915.conf:
# enable_guc=3  →  GuC submission + HuC firmware (Gen 9.5+ recomendado)
# enable_guc=2  →  Solo HuC (Alder Lake-S Desktop por defecto)
# enable_guc=1  →  Solo GuC submission
```

```
/etc/modprobe.d/i915.conf
options i915 enable_guc=3
```

Regenerar initramfs tras el cambio:

```bash
sudo mkinitcpio -P
```

Verificar tras reiniciar:

```bash
dmesg | grep -i -e 'huc' -e 'guc'
```

> **Aviso:** Activar GuC/HuC manualmente tainta el kernel. Desactivarlo si experimentas freezes al salir de hibernación.

---

## Verificación

```bash
# Verificar driver en uso
lspci -k -d ::03xx

# Verificar VA-API
vainfo

# Verificar Vulkan
vulkaninfo | grep -i "GPU\|intel\|device" | head -10

# Verificar OpenCL
clinfo | head -30

# Verificar OpenGL
glxinfo | grep "OpenGL renderer"
```

---

## Gráficos híbridos — Intel + NVIDIA (Optimus)

Los portátiles con gráficos híbridos tienen la iGPU Intel siempre activa y la dGPU NVIDIA encendida solo cuando se necesita. La solución recomendada en Linux es **PRIME** con los drivers open source o el driver propietario NVIDIA.

> Para configuración detallada de NVIDIA Optimus ver `nvidia_drivers.md`. Esta sección cubre solo el contexto Intel.

### Instalar los drivers de ambas GPUs

```bash
# Lado Intel (iGPU — ver secciones anteriores de esta guía)
sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver

# Lado NVIDIA (dGPU — instalar el driver correspondiente)
# Ejemplo con driver open source (Turing/Ampere/Ada/Blackwell):
sudo pacman -S nvidia-open nvidia-utils lib32-nvidia-utils
```

### Ejecutar aplicaciones en la GPU NVIDIA (PRIME offload)

```bash
# Variable de entorno para forzar la GPU NVIDIA en una aplicación concreta
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia aplicacion

# O para Vulkan
__NV_PRIME_RENDER_OFFLOAD=1 VK_DRIVER_FILES=/usr/share/vulkan/icd.d/nvidia_icd.json aplicacion
```

### Apagar la GPU NVIDIA completamente (ahorro de batería)

La GPU discreta se puede apagar para ahorrar batería cuando no se usa. Opciones:

**1. Desde BIOS/UEFI** — algunos fabricantes permiten desactivar la dGPU directamente. Es la opción más limpia.

**2. Con udev rules** — elimina el dispositivo NVIDIA del bus PCI al arrancar:

```bash
# /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
options nouveau modeset=0
```

```bash
# /etc/udev/rules.d/00-remove-nvidia.rules
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
```

Reiniciar y verificar con `lspci` que la GPU NVIDIA ya no aparece.

> **Nota:** Si tras desactivar la GPU el consumo sigue alto, comprobar que el módulo `nouveau` está cargado (`lsmod | grep nouveau`). El módulo nouveau gestiona el power management del dispositivo aunque no se use para renderizar.

**3. Con bbswitch** (AUR) — para kernels y hardware más antiguos:

```bash
yay -S bbswitch-dkms
```

> `bbswitch` no funciona correctamente con gestión de energía PCIe desde kernel 4.8.

### Problema: arranque de apps retardado 30 segundos (Vulkan)

Si la GPU NVIDIA está desactivada pero `nvidia-utils` está instalado, Vulkan intenta inicializar el driver NVIDIA y falla, causando un timeout de 30 segundos en apps basadas en Chromium/Electron. Solución:

```bash
# Desactivar el ICD de NVIDIA para Vulkan cuando la GPU está apagada
export VK_DRIVER_FILES=
```

Añadir al perfil del shell (`~/.bashrc` / `~/.zshrc`) si la GPU NVIDIA permanece siempre apagada.

---

## Herramientas de monitorización

```bash
# Monitor de actividad de GPU Intel (Video, Render, etc.)
sudo pacman -S intel-gpu-tools       # proporciona intel_gpu_top (ejecutar como root)

# Monitor interactivo general (AMD, Intel, NVIDIA)
sudo pacman -S nvtop

# Herramientas de verificación
sudo pacman -S vulkan-tools          # vulkaninfo, vkcube
sudo pacman -S mesa-utils            # glxinfo, eglinfo, glxgears
sudo pacman -S clinfo                # información detallada de OpenCL
```
