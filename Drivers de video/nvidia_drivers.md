# Guía de drivers Nvidia en Arch Linux

Fuente: [Arch Wiki — NVIDIA](https://wiki.archlinux.org/title/NVIDIA)

---

## Resumen rápido

| Familia GPU | Arquitectura | Driver principal | Alternativa | Estado |
|---|---|---|---|---|
| RTX 50xx / PRO 5000 | Blackwell (GB) | `nvidia-open` | — | Recomendado por upstream |
| RTX 40xx / 30xx / 20xx / GTX 16xx | Ada / Ampere / Turing | `nvidia-580xx-dkms` (AUR) | `nvidia-open`* | Soportado |
| GTX 10xx / GTX 900 / GTX 750 / Titan V | Pascal / Maxwell / Volta | `nvidia-580xx-dkms` (AUR) | — | Legacy, soportado |
| GTX 700 / GTX 600 | Kepler (GK) | `nvidia-470xx-dkms` (AUR) | — | Legacy, sin soporte |
| GTX 500 / GTX 400 | Fermi (GF) | `nvidia-390xx-dkms` (AUR) | — | Legacy |
| 300/200/100/9xx/8xx | Tesla (G80-GT200) | `nvidia-340xx-dkms` (AUR) | `nouveau` | Legacy |
| Curie (G70) y anterior | — | sin driver propietario | `nouveau` | Sin soporte |

> *`nvidia-open` en Turing: sin RTD3 Power Management. En laptops Ampere: posibles cuelgues.

---

## Instalación por driver

```bash
# Blackwell — linux estándar
sudo pacman -S nvidia-open nvidia-utils nvidia-settings

# Blackwell — linux-lts
sudo pacman -S nvidia-open-lts nvidia-utils nvidia-settings

# Blackwell — cualquier kernel (necesita linux-headers)
sudo pacman -S nvidia-open-dkms nvidia-utils nvidia-settings

# Ada / Ampere / Turing — driver principal
yay -S nvidia-580xx-dkms nvidia-580xx-utils nvidia-settings

# Maxwell / Pascal / Volta — legacy
yay -S nvidia-580xx-dkms nvidia-580xx-utils nvidia-settings

# Kepler — legacy sin soporte
yay -S nvidia-470xx-dkms nvidia-470xx-utils

# Fermi — legacy
yay -S nvidia-390xx-dkms nvidia-390xx-utils

# Tesla — legacy
yay -S nvidia-340xx-dkms

# Curie y anterior — open source
sudo pacman -S xf86-video-nouveau
```

---

## Paquetes completos para CUDA y aceleración GPU

### Driver + utilidades base
```bash
# Con nvidia-open (Blackwell)
sudo pacman -S nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings

# Con nvidia-580xx-dkms (Turing → Ada, Maxwell → Volta)
yay -S nvidia-580xx-dkms nvidia-580xx-utils
sudo pacman -S nvidia-settings
```

### CUDA Toolkit
```bash
# CUDA completo (compilador nvcc, bibliotecas, cabeceras)
sudo pacman -S cuda

# Verificar instalación
nvcc --version
nvidia-smi
```

### CUDA — Bibliotecas adicionales
```bash
# cuDNN — redes neuronales (TensorFlow, PyTorch)
sudo pacman -S cudnn

# NCCL — comunicación multi-GPU
sudo pacman -S nccl

# OpenCL — cómputo paralelo genérico
sudo pacman -S opencl-nvidia ocl-icd

# 32-bit OpenCL (compatibilidad)
sudo pacman -S lib32-opencl-nvidia

# clinfo — verificar OpenCL
sudo pacman -S clinfo
clinfo
```

### Herramientas de monitorización y desarrollo
```bash
# nvidia-smi — monitorización GPU (incluido en nvidia-utils)
nvidia-smi

# nvtop — monitor interactivo de GPU en terminal
sudo pacman -S nvtop

# NVML — biblioteca de gestión (incluida en nvidia-utils)

# Vulkan — renderizado moderno
sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader

# Mesa utils — diagnóstico OpenGL/Vulkan
sudo pacman -S mesa-utils vulkan-tools
```

### Machine Learning / Deep Learning
```bash
# PyTorch con CUDA (instalar con pip en entorno virtual)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

# TensorFlow con CUDA
pip install tensorflow[and-cuda]

# JAX con CUDA
pip install "jax[cuda12]"
```

### Instalación completa recomendada (Blackwell / Ada / Ampere)
```bash
# Driver + utilidades + CUDA + cuDNN + OpenCL + Vulkan
sudo pacman -S nvidia-open nvidia-utils lib32-nvidia-utils \
               nvidia-settings cuda cudnn nccl \
               opencl-nvidia ocl-icd lib32-opencl-nvidia \
               vulkan-icd-loader lib32-vulkan-icd-loader \
               nvtop mesa-utils vulkan-tools
```

---

## Blackwell (GB) — `nvidia-open`

> RTX 50xx Series · 2025 · Recomendado por upstream

### Desktop
| Modelo | Chip |
|---|---|
| GeForce RTX 5090 | GB202 |
| GeForce RTX 5090 D | GB202 |
| GeForce RTX 5080 | GB203 |
| GeForce RTX 5070 Ti | GB203 |
| GeForce RTX 5070 | GB205 |
| GeForce RTX 5060 Ti | GB206 |
| GeForce RTX 5060 | GB206 |
| GeForce RTX 5050 | GB207 |

### Laptop
| Modelo | Chip |
|---|---|
| GeForce RTX 5090 Laptop GPU | GB203 |
| GeForce RTX 5080 Laptop GPU | GB203 |
| GeForce RTX 5070 Ti Laptop GPU | GB205 |
| GeForce RTX 5070 Laptop GPU | GB205 |
| GeForce RTX 5060 Laptop GPU | GB206 |
| GeForce RTX 5050 Laptop GPU | GB207 |

### Workstation Desktop
| Modelo | Chip |
|---|---|
| RTX PRO 6000 Blackwell | GB202 |
| RTX PRO 5000 Blackwell | GB203 |
| RTX PRO 4500 Blackwell | GB205 |
| RTX PRO 4000 Blackwell | GB206 |
| DGX Spark GB20B | GB20B |

### Workstation Mobile
| Modelo |
|---|
| RTX PRO 3000 Mobile |
| RTX PRO 2000 Mobile |
| RTX PRO 1000 Mobile |
| RTX PRO 500 Mobile |

---

## Ada Lovelace (AD) — `nvidia-580xx-dkms` (AUR)

> RTX 40xx Series · 2022–2024
> Alternativa: `nvidia-open` (sin RTD3 Power Management)

### Desktop
| Modelo | Chip |
|---|---|
| GeForce RTX 4090 | AD102 |
| GeForce RTX 4080 Super | AD103 |
| GeForce RTX 4080 | AD103 |
| GeForce RTX 4070 Ti Super | AD103 |
| GeForce RTX 4070 Ti | AD104 |
| GeForce RTX 4070 Super | AD104 |
| GeForce RTX 4070 | AD104 |
| GeForce RTX 4060 Ti | AD106 |
| GeForce RTX 4060 | AD107 |

### Laptop
| Modelo |
|---|
| GeForce RTX 4090 Laptop GPU |
| GeForce RTX 4080 Laptop GPU |
| GeForce RTX 4070 Ti Laptop GPU |
| GeForce RTX 4070 Laptop GPU |
| GeForce RTX 4060 Laptop GPU |
| GeForce RTX 4050 Laptop GPU |

### Workstation
| Modelo |
|---|
| RTX 6000 Ada Generation |
| RTX 5000 Ada Generation |
| RTX 4500 Ada Generation |
| RTX 4000 Ada Generation |
| RTX 4000 SFF Ada Generation |
| RTX 3500 Ada Generation |
| RTX 3000 Ada Generation |
| RTX 2000 Ada Generation |
| RTX 1000 Ada Generation |
| RTX 500 Ada Generation |

---

## Ampere (GA) — `nvidia-580xx-dkms` (AUR)

> RTX 30xx Series · 2020–2022
> Alternativa: `nvidia-open` (posibles cuelgues en laptops)

### Desktop
| Modelo | Chip |
|---|---|
| GeForce RTX 3090 Ti | GA102 |
| GeForce RTX 3090 | GA102 |
| GeForce RTX 3080 Ti | GA102 |
| GeForce RTX 3080 12GB | GA102 |
| GeForce RTX 3080 | GA102 |
| GeForce RTX 3070 Ti | GA104 |
| GeForce RTX 3070 | GA104 |
| GeForce RTX 3060 Ti | GA104 |
| GeForce RTX 3060 | GA106 |
| GeForce RTX 3050 8GB | GA106 |
| GeForce RTX 3050 6GB | GA107 |

### Laptop
| Modelo |
|---|
| GeForce RTX 3080 Ti Laptop GPU |
| GeForce RTX 3080 Laptop GPU |
| GeForce RTX 3070 Ti Laptop GPU |
| GeForce RTX 3070 Laptop GPU |
| GeForce RTX 3060 Laptop GPU |
| GeForce RTX 3050 Ti Laptop GPU |
| GeForce RTX 3050 Laptop GPU |

### Workstation
| Modelo |
|---|
| RTX A6000 |
| RTX A5000 |
| RTX A4000 |
| RTX A3000 |
| RTX A2000 |
| RTX A1000 |
| RTX A500 |

---

## Turing (TU) / Ampere (GA) / Ada Lovelace (AD) — `nvidia-580xx-dkms` (AUR)

> RTX 40xx / RTX 30xx / RTX 20xx / GTX 16xx · 2018–2024
> Driver principal: `nvidia-580xx-dkms`
> Alternativa: `nvidia-open`* (sin RTD3 en Turing, posibles cuelgues en laptops Ampere)

---

## Turing (TU) — `nvidia-580xx-dkms` (AUR)

> RTX 20xx / GTX 16xx Series · 2018–2020

### Desktop RTX
| Modelo | Chip |
|---|---|
| GeForce RTX 2080 Ti | TU102 |
| GeForce RTX 2080 Super | TU104 |
| GeForce RTX 2080 | TU104 |
| GeForce RTX 2070 Super | TU104 |
| GeForce RTX 2070 | TU106 |
| GeForce RTX 2060 Super | TU106 |
| GeForce RTX 2060 | TU106 |

### Desktop GTX
| Modelo | Chip |
|---|---|
| GeForce GTX 1660 Ti | TU116 |
| GeForce GTX 1660 Super | TU116 |
| GeForce GTX 1660 | TU116 |
| GeForce GTX 1650 Super | TU116 |
| GeForce GTX 1650 | TU117 |

### Laptop RTX
| Modelo |
|---|
| GeForce RTX 2080 Super Laptop GPU |
| GeForce RTX 2080 Laptop GPU |
| GeForce RTX 2070 Super Laptop GPU |
| GeForce RTX 2070 Laptop GPU |
| GeForce RTX 2060 Laptop GPU |

### Laptop GTX
| Modelo |
|---|
| GeForce GTX 1660 Ti Laptop GPU |
| GeForce GTX 1650 Ti Laptop GPU |
| GeForce GTX 1650 Laptop GPU |

### MX Series (Turing)
| Modelo |
|---|
| GeForce MX550 |
| GeForce MX450 |

---

## Volta (GV) — `nvidia-580xx-dkms` (AUR · Legacy)

> 2017–2018

| Modelo | Chip |
|---|---|
| Titan V | GV100 |
| Titan V CEO Edition | GV100 |
| Quadro GV100 | GV100 |

---

## Pascal (GP) — `nvidia-580xx-dkms` (AUR · Legacy)

> GTX 10xx Series · 2016–2018

### Desktop
| Modelo | Chip |
|---|---|
| GeForce GTX 1080 Ti | GP102 |
| GeForce GTX 1080 | GP104 |
| GeForce GTX 1070 Ti | GP104 |
| GeForce GTX 1070 | GP104 |
| GeForce GTX 1060 6GB | GP106 |
| GeForce GTX 1060 3GB | GP106 |
| GeForce GTX 1050 Ti | GP107 |
| GeForce GTX 1050 | GP107 |
| GeForce GT 1030 | GP108 |
| Titan Xp | GP102 |
| Titan X (Pascal) | GP102 |

### Laptop
| Modelo |
|---|
| GeForce GTX 1080 Laptop GPU |
| GeForce GTX 1070 Laptop GPU |
| GeForce GTX 1060 Laptop GPU |
| GeForce GTX 1050 Ti Laptop GPU |
| GeForce GTX 1050 Laptop GPU |

### MX Series (Pascal)
| Modelo | Chip |
|---|---|
| GeForce MX350 | GP107 |
| GeForce MX330 | GP108 |
| GeForce MX250 | GP108 |
| GeForce MX230 | GP108 |
| GeForce MX150 | GP108 |
| GeForce MX130 | GP108 |

---

## Maxwell 2 (GM2xx) — `nvidia-580xx-dkms` (AUR · Legacy)

> GTX 900 Series · 2014–2016

### Desktop
| Modelo | Chip |
|---|---|
| GeForce GTX 980 Ti | GM200 |
| GeForce GTX 980 | GM204 |
| GeForce GTX 970 | GM204 |
| GeForce GTX 960 | GM206 |
| GeForce GTX 950 | GM206 |
| Titan X (Maxwell) | GM200 |

### Laptop
| Modelo |
|---|
| GeForce GTX 980M |
| GeForce GTX 970M |
| GeForce GTX 965M |
| GeForce GTX 960M |
| GeForce GTX 950M |
| GeForce GTX 940M |
| GeForce GTX 930M |
| GeForce GTX 920M |

---

## Maxwell 1 (GM1xx) — `nvidia-580xx-dkms` (AUR · Legacy)

> GTX 750 Series · 2014

| Modelo | Chip |
|---|---|
| GeForce GTX 750 Ti | GM107 |
| GeForce GTX 750 | GM107 |
| GeForce GTX 745 | GM107 |

### Laptop Maxwell 1
| Modelo |
|---|
| GeForce GTX 860M (GM107) |
| GeForce GTX 850M |
| GeForce GTX 840M |
| GeForce GTX 830M |

---

## Kepler (GK) — `nvidia-470xx-dkms` (AUR · Legacy · Sin soporte oficial)

> GTX 700 / GTX 600 Series · 2012–2014

### Desktop GTX 700 (Kepler)
| Modelo | Chip |
|---|---|
| GeForce GTX 780 Ti | GK110 |
| GeForce GTX 780 | GK110 |
| GeForce GTX 770 | GK104 |
| GeForce GTX 760 Ti | GK104 |
| GeForce GTX 760 | GK104 |
| GeForce GTX 740 | GK107 |
| GeForce GTX 730 (GDDR5) | GK208 |
| GeForce GTX 720 | GK208 |
| GeForce GT 730 | GK208 |
| GeForce GT 720 | GK208 |
| GeForce GT 710 | GK208 |
| Titan (Kepler) | GK110 |
| Titan Black | GK110 |
| Titan Z | GK110 |

### Desktop GTX 600
| Modelo | Chip |
|---|---|
| GeForce GTX 690 | GK104 |
| GeForce GTX 680 | GK104 |
| GeForce GTX 670 | GK104 |
| GeForce GTX 660 Ti | GK104 |
| GeForce GTX 660 | GK106 |
| GeForce GTX 650 Ti Boost | GK106 |
| GeForce GTX 650 Ti | GK106 |
| GeForce GTX 650 | GK107 |
| GeForce GTX 645 | GK107 |
| GeForce GT 640 (GDDR5) | GK107 |
| GeForce GT 630 (GK208) | GK208 |

### Laptop Kepler
| Modelo |
|---|
| GeForce GTX 780M |
| GeForce GTX 770M |
| GeForce GTX 765M |
| GeForce GTX 760M |
| GeForce GTX 680MX |
| GeForce GTX 675MX |
| GeForce GTX 670MX |
| GeForce GTX 660M |

---

## Fermi (GF) — `nvidia-390xx-dkms` (AUR · Legacy)

> GTX 500 / GTX 400 Series · 2010–2012

### Desktop GTX 500
| Modelo | Chip |
|---|---|
| GeForce GTX 590 | GF110 |
| GeForce GTX 580 | GF110 |
| GeForce GTX 570 | GF110 |
| GeForce GTX 560 Ti | GF114 |
| GeForce GTX 560 | GF116 |
| GeForce GTX 550 Ti | GF116 |
| GeForce GTX 530 | GF108 |
| GeForce GT 520 | GF119 |

### Desktop GTX 400
| Modelo | Chip |
|---|---|
| GeForce GTX 480 | GF100 |
| GeForce GTX 470 | GF100 |
| GeForce GTX 465 | GF100 |
| GeForce GTX 460 | GF104 |
| GeForce GTS 450 | GF106 |
| GeForce GT 440 | GF108 |
| GeForce GT 430 | GF108 |
| GeForce GT 420 | GF108 |

---

## Tesla (G80/GT200) — `nvidia-340xx-dkms` (AUR · Legacy)

> Serie 300 / 200 / 100 / 9xxx / 8xxx · 2006–2010
> Alternativa open-source: `xf86-video-nouveau`

| Serie | Ejemplos |
|---|---|
| GeForce 300 | GT 340, GT 330, GT 320, 315, 310 |
| GeForce 200 | GTX 295, GTX 285, GTX 280, GTX 275, GTX 260, GTS 250, GTS 240, GT 240, GT 220, G210 |
| GeForce 100 | GT 130, GT 120, G100 |
| GeForce 9xxx | 9800 GTX+, 9800 GTX, 9800 GT, 9600 GSO, 9600 GT, 9500 GT, 9400 GT |
| GeForce 8xxx | 8800 Ultra, 8800 GTX, 8800 GTS, 8800 GT, 8600 GTS, 8600 GT, 8500 GT, 8400 GS |

---

## Curie (NV40/G70) y anterior — Sin driver propietario

> Usar `nouveau` (open-source, módulo del kernel Linux)

```bash
sudo pacman -S xf86-video-nouveau
```

| Serie | Ejemplos |
|---|---|
| GeForce 7xxx | 7900 GTX, 7800 GTX, 7600 GT, 7300 GT |
| GeForce 6xxx | 6800 Ultra, 6800 GT, 6600 GT |
| GeForce FX (5xxx) | FX 5950 Ultra, FX 5900, FX 5800 |

---

## Notas importantes

### El paquete `nvidia` ya no existe en Arch Linux
El paquete `nvidia` de los repos oficiales fue reemplazado. La distribución actual es:
- **Blackwell** → `nvidia-open` (repos oficiales)
- **Turing → Ada Lovelace** → `nvidia-580xx-dkms` (AUR) como principal
- **Maxwell → Volta** → `nvidia-580xx-dkms` (AUR) como legacy

### nvidia-open como alternativa en Turing/Ampere
- En **Turing**: sin RTD3 Power Management (gestión de energía limitada)
- En **laptops Ampere**: posibles cuelgues, preferir `nvidia-580xx-dkms`
- En **Ada Lovelace**: funciona bien como alternativa

### Conflicto de módulos — blacklist nouveau
Obligatorio cuando se usa cualquier driver propietario:

```bash
# Crear /etc/modprobe.d/blacklist-nouveau.conf
echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
echo "options nouveau modeset=0" | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf

# Regenerar initramfs
sudo mkinitcpio -P
```

### Kernel headers — requeridos para todos los paquetes -dkms
```bash
# linux estándar
sudo pacman -S linux-headers

# linux-lts
sudo pacman -S linux-lts-headers

# linux-zen
sudo pacman -S linux-zen-headers

# linux-hardened
sudo pacman -S linux-hardened-headers
```

### DKMS — verificar compilación del módulo
```bash
# Ver estado de todos los módulos dkms
dkms status

# Recompilar manualmente si falla
sudo dkms autoinstall
```

### Variables de entorno útiles para CUDA
```bash
# Añadir a ~/.bashrc o ~/.zshrc
export CUDA_HOME=/opt/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
```

### Verificar instalación completa
```bash
# Ver GPU y driver cargado
nvidia-smi

# Ver versión CUDA
nvcc --version

# Ver dispositivos OpenCL
clinfo | grep "Device Name"

# Ver info Vulkan
vulkaninfo --summary
```
