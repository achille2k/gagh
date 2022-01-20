#!/bin/bash
# Taken from: https://red-full-moon.com/make-hevc-qsv-env-first-half/

# 環境の最新化
sudo apt update
sudo apt dist-upgrade
# 必要パッケージのインストール
sudo apt install cmake make autoconf automake libtool g++ bison libpcre3-dev pkg-config libtool libdrm-dev xorg xorg-dev openbox \
libx11-dev libgl1-mesa-glx libgl1-mesa-dev libpciaccess-dev libfdk-aac-dev libvorbis-dev libvpx-dev libx264-dev libx265-dev \
ocl-icd-opencl-dev pkg-config yasm libx11-xcb-dev libxcb-dri3-dev libxcb-present-dev libva-dev libmfx-dev intel-media-va-driver-non-free opencl-clhpp-headers git libasound2-dev \
libmp3lame-dev libpulse-dev

# libvaのインストール
mkdir ~/git && cd ~/git
git clone https://github.com/intel/libva
cd libva
./autogen.sh
make
sudo make install

# libva-utilsのインストール
cd ~/git
git clone https://github.com/intel/libva-utils
cd libva-utils
./autogen.sh
make
sudo make install

# gmmlibのインストール
cd ~/git
git clone https://github.com/intel/gmmlib
cd gmmlib
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE= Release -DARCH=64 ../
make
sudo make install

# Intel-Media-Driverのインストール
cd ~/git
git clone https://github.com/intel/media-driver
mkdir build_media && cd build_media
cmake ../media-driver
make -j"$(nproc)"
sudo make install

# Intel-Media-Driverで生成されたライブラリをffmpegで使用するために移動
sudo mkdir -p /usr/local/lib/dri 
sudo cp ~/git/build_media/media_driver/iHD_drv_video.so /usr/local/lib/dri/



# Intel-Media-SDKのインストール
cd ~/git
git clone https://github.com/Intel-Media-SDK/MediaSDK msdk
cd msdk
git submodule init
git pull
mkdir -p ~/git/build_msdk && cd ~/git/build_msdk
cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_WAYLAND=ON -DENABLE_X11_DRI3=ON -DENABLE_OPENCL=ON  ../msdk
make
sudo make install

sudo rm -f -- /etc/ld.so.conf.d/imsdk.conf
echo '/opt/intel/mediasdk/lib' | sudo tee -a /etc/ld.so.conf.d/imsdk.conf
sudo ldconfig

# 最新版ffmpegの構築
cd ~/git
git clone https://github.com/FFmpeg/FFmpeg
cd FFmpeg
PKG_CONFIG_PATH=/opt/intel/mediasdk/lib/pkgconfig
./configure  --prefix=/usr/local/ffmpeg  --extra-cflags="-I/opt/intel/mediasdk/include"  --extra-ldflags="-L/opt/intel/mediasdk/lib"  --extra-ldflags="-L/opt/intel/mediasdk/plugins"  \
--enable-libmfx  --enable-vaapi  --enable-opencl  --disable-debug  --enable-libvorbis  --enable-libvpx  --enable-libdrm  --enable-gpl  --cpu=native  --enable-libfdk-aac  --enable-libx264 \
--enable-libx265  --extra-libs=-lpthread  --enable-nonfree --enable-libmp3lame --enable-libfreetype --enable-libpulse
make
sudo make install

# vaapiが導入されていることを確認 
/usr/local/ffmpeg/bin/ffmpeg -hwaccels 2>/dev/null | grep vaapi 

# 利用できるようになったコーデックの確認 
/usr/local/ffmpeg/bin/ffmpeg -encoders 2>/dev/null | grep vaapi
