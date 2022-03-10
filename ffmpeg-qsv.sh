#!/bin/bash
# Taken from: https://red-full-moon.com/make-hevc-qsv-env-first-half/

# dotnet-runtime-5.0
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt dist-upgrade
sudo apt install apt-transport-https 
sudo apt update
sudo apt install dotnet-runtime-5.0

# lib and app
sudo apt install cmake make autoconf automake libtool g++ bison libpcre3-dev pkg-config libtool libdrm-dev xorg xorg-dev openbox \
libx11-dev libgl1-mesa-glx libgl1-mesa-dev libpciaccess-dev libfdk-aac-dev libvorbis-dev libvpx-dev libx264-dev libx265-dev \
ocl-icd-opencl-dev pkg-config yasm libx11-xcb-dev libxcb-dri3-dev libxcb-present-dev libva-dev libmfx-dev intel-media-va-driver-non-free opencl-clhpp-headers git libasound2-dev \
libmp3lame-dev libpulse-dev libvlc-dev pavucontrol vim

# libva
mkdir ~/git && cd ~/git
git clone https://github.com/intel/libva
cd libva
./autogen.sh
make
sudo make install

# libva-utils
cd ~/git
git clone https://github.com/intel/libva-utils
cd libva-utils
./autogen.sh
make
sudo make install

# gmmlib
cd ~/git
git clone https://github.com/intel/gmmlib
cd gmmlib
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE= Release -DARCH=64 ../
make
sudo make install

# Intel-Media-Driver
cd ~/git
git clone https://github.com/intel/media-driver
mkdir build_media && cd build_media
cmake ../media-driver
make -j"$(nproc)"
sudo make install

# Intel-Media-Driver
sudo mkdir -p /usr/local/lib/dri 
sudo cp ~/git/build_media/media_driver/iHD_drv_video.so /usr/local/lib/dri/

# Intel-Media-SDK
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

# ffmpeg
cd ~/git
git clone https://github.com/FFmpeg/FFmpeg
cd FFmpeg
PKG_CONFIG_PATH=/opt/intel/mediasdk/lib/pkgconfig
./configure  --prefix=/usr/local/ffmpeg  --extra-cflags="-I/opt/intel/mediasdk/include"  --extra-ldflags="-L/opt/intel/mediasdk/lib"  --extra-ldflags="-L/opt/intel/mediasdk/plugins"  \
--enable-libmfx  --enable-vaapi  --enable-opencl  --disable-debug  --enable-libvorbis  --enable-libvpx  --enable-libdrm  --enable-gpl  --cpu=native  --enable-libfdk-aac  --enable-libx264 \
--enable-libx265  --extra-libs=-lpthread  --enable-nonfree --enable-libmp3lame --enable-libfreetype --enable-libpulse
make
sudo make install

# vaapi
/usr/local/ffmpeg/bin/ffmpeg -hwaccels 2>/dev/null | grep vaapi 

# vaapi
/usr/local/ffmpeg/bin/ffmpeg -encoders 2>/dev/null | grep vaapi

sudo apt remove ffmpeg

# set environment
sudo rm -f -- /etc/environment
echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/local/ffmpeg/bin"' | sudo tee -a /etc/environment


# custom config /etc/pulse/default.pa
sudo wget https://raw.githubusercontent.com/achille2k/gagh/main/default.pa
sudo mv default.pa /etc/pulse/
pulseaudio -k

# create folder for application
sudo mkdir -p /opt/gagh
sudo chown soho.soho /opt/gagh
sudo mkdir -p /opt/records
sudo chown soho.soho /opt/records




