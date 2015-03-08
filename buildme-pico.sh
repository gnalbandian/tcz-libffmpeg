#!/bin/sh

FFMPEG=ffmpeg
FFMPEGVERSION=2.1.7
SRC=${FFMPEG}-$FFMPEGVERSION
LOG=$PWD/config.log
OUTPUT=$PWD/${FFMPEG}-build
TCZ=lib${FFMPEG}.tcz

# Build requires these extra packages in addition to the raspbian 7.6 build tools
# sudo apt-get install squashfs-tools bsdtar

## Start
echo "Most log mesages sent to $LOG... only 'errors' displayed here"
date > $LOG

# Clean up
if [ -d $OUTPUT ]; then
	rm -rf $OUTPUT >> $LOG
fi

if [ -d $SRC ]; then
	rm -rf $SRC >> $LOG
fi

## Build
echo "Untarring..."
bsdtar -xf $SRC.tar.bz2 >> $LOG

echo "Configuring..."
cd $SRC >> $LOG
./configure \
    --prefix=/usr/local \
    --disable-debug \
    --enable-static \
    --disable-avresample \
    --disable-dxva2 \
    --disable-fontconfig \
    --enable-gpl \
    --disable-libass \
    --disable-libbluray \
    --disable-libfreetype \
    --disable-libgsm \
    --disable-libmodplug \
    --disable-libmp3lame \
    --disable-libopencore_amrnb \
    --disable-libopencore_amrwb \
    --disable-libopenjpeg \
    --disable-libopus \
    --disable-libpulse \
    --disable-librtmp \
    --disable-libschroedinger \
    --disable-libspeex \
    --disable-libtheora \
    --disable-libv4l2 \
    --disable-libvorbis \
    --disable-libvpx \
    --disable-libx264 \
    --disable-libxvid \
    --enable-pic \
    --disable-postproc \
    --enable-runtime-cpudetect \
    --enable-shared \
    --disable-swresample \
    --disable-vdpau \
    --enable-version3 \
    --disable-x11grab \
    --disable-zlib \
    --enable-ffmpeg \
    --enable-ffplay \
    --enable-ffprobe \
    --enable-ffserver \
    --extra-ldflags=-Wl,-rpath,/usr/local/lib >> $LOG

echo "Running make"
make >> $LOG
make prefix=$OUTPUT/usr/local install

echo "Building tcz"
cd ../.. >> $LOG

if [ -f $TCZ ]; then
	rm $TCZ >> $LOG
fi

cd $OUTPUT/usr/local >> $LOG
rm -rf include >> $LOG
rm -rf bin >> $LOG
rm -rf share >> $LOG
cd lib >> $LOG
rm -rf pkgconfig >> $LOG
rm -f libavdevice\.* >> $LOG
rm -f libavfilter\.* >> $LOG
rm -f libswscale\.* >> $LOG
rm -f libavcodec.so.55 libavcodec.so libavcodec.a >> $LOG
mv libavcodec.so.55.39.101 libavcodec.so.55 >> $LOG
strip libavcodec.so.55 >> $LOG
rm -f libavformat.so.55 libavformat.so libavformat.a >> $LOG
mv libavformat.so.55.19.104 libavformat.so.55 >> $LOG
strip libavformat.so.55 >> $LOG
rm -f libavutil.so.52 libavutil.so libavutil.a >> $LOG
mv libavutil.so.52.48.101 libavutil.so.52  >> $LOG
strip libavutil.so.52 >> $LOG
cd ../../../../ >> $LOG

# Not needed twice, included in libfaad.tcz. TODO create a separate libcofi.tcz
# cp -p /usr/lib/arm-linux-gnueabihf/libcofi_rpi.so $OUTPUT/usr/lib/ >> $LOG

mksquashfs $OUTPUT $TCZ -all-root >> $LOG
md5sum $TCZ > ${TCZ}.md5.txt

echo "$TCZ contains"
unsquashfs -ll $TCZ
