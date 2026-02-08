# Real-ESRGAN ncnn Vulkan plugin for AviSynth+

![CI](https://github.com/dimag0g/Real-ESRGAN-ncnn-vulkan/actions/workflows/CI.yml/badge.svg?branch=avisynth)

ncnn implementation of Real-ESRGAN converter. Runs fast on Intel / AMD / Nvidia / Apple-Silicon with Vulkan API.
This repo provides AviSynth+ plugin implementing Real-ESRGAN in `avisyth` branch.

## [Download](https://github.com/dimag0g/Real-ESRGAN-ncnn-vulkan/releases)

Download Windows/Linux/MacOS Executable for Intel/AMD/Nvidia/Apple-Silicon GPU

This package includes all the binaries and models required. It is portable, so no CUDA or PyTorch runtime environment is needed :)


## Usages

### Example avs script

```avs
LoadPlugin("AviSynthPlus-realesrgan-x64.dll")
FFVideoSource("test.mkv") # or AviSource("test.avi")
ConvertToRGB32()
realesrgan(scale=2, gpu_thread=1)
ConvertToYV12(matrix="PC.709")
```

### Supported parameters

- `scale` = upscale level, should be between 2 and 4, default = 2.
- `model` = model to use, 0: "realesr-general-wdn", 1: "upscayl-lite" 2: "realesr-animevideo", default = 2.
- `tilesize` = tile size (min = 32), use smaller value to reduce GPU memory usage, default - try to fit a frame in one tile.
- `gpu_id` = ID of GPU to use, default is zero (first available).
- `gpu_thread` = thread count for the realcugan upscaling, using larger values increases GPU usage and consumes more GPU memory, default = 1.
- `list_gpu` = simply prints a list of available GPU devices on the frame and does nothing else.


### Troubleshooting

`vkAllocateMemory failed` means `tilesize` * `gpu_thread` is set too high, and
you need to reduce either number to get the model fit in GPU memory.

`vkQueueSubmit failed` means the GPU is already in error state due to a previous
failure, and you need to check earlier messages to find the actual failure.

In case of any other crash or error, before anything else, try upgrading your GPU driver:

- Intel: https://downloadcenter.intel.com/product/80939/Graphics-Drivers
- AMD: https://www.amd.com/en/support
- NVIDIA: https://www.nvidia.com/Download/index.aspx

If increasing `gpu_thread` doesn't result in faster processing,
consider telling AviSynth+ to spawn several threads for your filter:

```avs
realesrgan(scale=2, gpu_thread=2)
SetFilterMTMode("realcugan", MT_MULTI_INSTANCE)
Prefetch(2)
```

If the GPU memory usage is above 70%, setting `tilesize=<frame width>` or `tilesize=<frame height>`
sometimes improves performance by making sure the frame fits in either one or two tiles, when
automatic tile size detection may result in splitting the frame in 4 or more tiles.

Of course, manually increasing the tile size only helps if the resulting GPU memory usage is below 100%,
otherwise the processing will either crash or get much slower if system memory is used as
as substitute for GPU memory.


## Build from Source

1. Download and setup the Vulkan SDK from https://vulkan.lunarg.com/
  - For Linux distributions, you can either get the essential build requirements from package manager
```shell
dnf install vulkan-headers vulkan-loader-devel
```
```shell
apt-get install libvulkan-dev
```
```shell
pacman -S vulkan-headers vulkan-icd-loader
```

2. Clone this project with all submodules

```shell
git clone --recurse-submodules https://github.com/dimag0g/Real-ESRGAN-ncnn-vulkan
cd Real-ESRGAN-ncnn-vulkan
git switch avisynth
```

3. Build with CMake
  - You can pass -DUSE_STATIC_MOLTENVK=ON option to avoid linking the vulkan loader library on MacOS

```shell
mkdir build
cd build
cmake ../src
cmake --build . -j 4
```

On Windows, you can build with Visual Studio by simply opening the `src` directory.
CMake should automatically configure the project when you do.
Once the project is configured, right-click on CMakeLists.txt and pick "Build".

## Sample Images

### Original Image

![origin](images/input.jpg)

### Upscale 2x Lanczos Filter

```avs
LanczosResize(width * 2, height * 2)
```

![browser](images/out_lanczosx2.png)

### Upscale 2x with Real-ESRGAN

```shell
realesrgan(scale=2, gpu_thread=1)
```

![realcugan](images/out_esrx2.jpg)

## Original Projects

Real-ESRGAN (Real Cascade U-Nets for Anime Image Super Resolution)

- https://github.com/xinntao/Real-ESRGAN
- https://github.com/nihui/Real-ESRGAN-ncnn-vulkan

Waifu2x AviSynth+ plugin used as a base

- https://github.com/Asd-g/AviSynthPlus-w2xncnnvk

## Other Open-Source Code Used

- https://github.com/Tencent/ncnn for fast neural network inference on ALL PLATFORMS
- https://github.com/webmproject/libwebp for encoding and decoding Webp images on ALL PLATFORMS
- https://github.com/nothings/stb for decoding and encoding image on Linux / MacOS
- https://github.com/tronkko/dirent for listing files in directory on Windows
