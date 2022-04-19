#!/bin/bash
# Taken from: https://red-full-moon.com/make-hevc-qsv-env-first-half/

# Telex
sudo add-apt-repository ppa:bamboo-engine/ibus-bamboo
sudo apt-get update
sudo apt install ibus-bamboo

# lib and app
sudo apt install cmake make autoconf automake libtool g++ bison libpcre3-dev pkg-config libtool libdrm-dev xorg xorg-dev openbox \
libx11-dev libgl1-mesa-glx libgl1-mesa-dev libpciaccess-dev libfdk-aac-dev libvorbis-dev libvpx-dev libx264-dev libx265-dev \
ocl-icd-opencl-dev pkg-config yasm libx11-xcb-dev libxcb-dri3-dev libxcb-present-dev libva-dev libmfx-dev intel-media-va-driver-non-free opencl-clhpp-headers git libasound2-dev \
libmp3lame-dev libpulse-dev vlc libvlc-dev v4l-utils pavucontrol vim growisofs dvd+rw-tools libmpv-dev unzip

# excute sudo without pass
echo -e '\nsoho ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers

# dotnet-runtime-5.0
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt dist-upgrade
sudo apt install apt-transport-https 
sudo apt update
sudo apt install dotnet-runtime-5.0
sudo rm packages-microsoft-prod.deb

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

# set environment
sudo rm -f -- /etc/environment
echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/local/ffmpeg/bin"' | sudo tee -a /etc/environment


# custom config /etc/pulse/default.pa
sudo wget -q https://raw.githubusercontent.com/achille2k/gagh/main/default.pa -O /etc/pulse/default.pa > /dev/null 2>&1
#sudo mv default.pa 
pulseaudio -k

# install font
FONT_DIR="$HOME/.local/share/fonts/Microsoft/TrueType/Segoe UI/"
mkdir -p "$FONT_DIR"
wget -q https://github.com/achille2k/gagh/raw/main/fonts/segoeui.ttf -O "$FONT_DIR"/segoeui.ttf > /dev/null 2>&1 # regular
wget -q https://github.com/achille2k/gagh/raw/main/fonts/segoeuib.ttf -O "$FONT_DIR"/segoeuib.ttf > /dev/null 2>&1 # bold
wget -q https://github.com/achille2k/gagh/raw/main/fonts/segoeuii.ttf -O "$FONT_DIR"/segoeuii.ttf > /dev/null 2>&1 # italic
wget -q https://github.com/achille2k/gagh/raw/main/fonts/segoeuiz.ttf -O "$FONT_DIR"/segoeuiz.ttf > /dev/null 2>&1 # bold italic
wget -q https://github.com/achille2k/gagh/raw/main/fonts/segoeuil.ttf -O "$FONT_DIR"/segoeuil.ttf > /dev/null 2>&1 # light
wget -q https://github.com/achille2k/gagh/raw/main/fonts/seguili.ttf -O "$FONT_DIR"/seguili.ttf > /dev/null 2>&1 # light italic
wget -q https://github.com/achille2k/gagh/raw/main/fonts/segoeuisl.ttf -O "$FONT_DIR"/segoeuisl.ttf > /dev/null 2>&1 # semilight
wget -q https://github.com/achille2k/gagh/raw/main/fonts/seguisli.ttf -O "$FONT_DIR"/seguisli.ttf > /dev/null 2>&1 # semilight italic
wget -q https://github.com/achille2k/gagh/raw/main/fonts/seguisb.ttf -O "$FONT_DIR"/seguisb.ttf > /dev/null 2>&1 # semibold
wget -q https://github.com/achille2k/gagh/raw/main/fonts/seguisbi.ttf -O "$FONT_DIR"/seguisbi.ttf > /dev/null 2>&1 # semibold italic
fc-cache -f "$FONT_DIR"

# create folder for application
sudo mkdir -p /opt/gagh
sudo chown soho.soho /opt/gagh
sudo mkdir -p /opt/records
sudo chown soho.soho /opt/records

# gagh
cd ~
wget -q https://github.com/achille2k/gagh/raw/main/gagh.tar.gz -O gagh.tar.gz > /dev/null 2>&1
tar -xvzf gagh.tar.gz 
cd gagh
mv * /opt/gagh/
cp /opt/gagh/config/* /opt/records/
cd ~
rm -rf gagh*

# setup kiosk
wget -q https://raw.githubusercontent.com/achille2k/gagh/main/kiosk.sh -O "$HOME"/kiosk.sh > /dev/null 2>&1
chmod +x kiosk.sh
sudo ./kiosk.sh

# change logo boot
wget -q https://github.com/achille2k/gagh/raw/main/watermark.png -O watermark.png > /dev/null 2>&1
sudo mv watermark.png /usr/share/plymouth/themes/spinner/

# disable auto datetime
sudo timedatectl set-ntp 0

# auto mount usb 4 openbox
cd ~/git
git clone https://github.com/achille2k/automount-usb
cd automount-usb
sudo ./CONFIGURE.sh

# remove git
cd ~
rm -rf git

# remove ffmpeg
sudo apt remove ffmpeg

# reboot
sudo reboot




