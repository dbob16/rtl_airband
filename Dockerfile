FROM debian:12

# Install Driver
WORKDIR /app/driverbuild
RUN apt-get update && apt-get install -y libusb-1.0-0-dev git cmake pkg-config
RUN git clone https://github.com/rtlsdrblog/rtl-sdr-blog .
WORKDIR /app/driverbuild/build
RUN cmake ../ -DINSTALL_UDEV_RULES=ON && \
  make && \
  make install && \
  cp ../rtl-sdr.rules /etc/udev/rules.d && \
  ldconfig && \
  mkdir -p /etc/modprobe.d && \
  echo 'blacklist dvb_usb_rtl28xxu' > /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf

# Install RTL_Airband
WORKDIR /app/appbuild
RUN apt-get install -y build-essential cmake pkg-config libmp3lame-dev libshout3-dev 'libconfig++-dev' libfftw3-dev
RUN git clone https://github.com/szpajder/RTLSDR-Airband.git . && git checkout main && git pull 
WORKDIR /app/appbuild/build
RUN cmake -DNFM=ON ../ && \
  make && \
  make install

# Cleanup
WORKDIR /app
RUN rm -rf /app/driverbuild && rm -rf /app/appbuild

# Copy default config 
COPY ./rtl_airband.conf /app/rtl_airband.conf

# Specify command
CMD ["rtl_airband", "-f", "-c", "/app/rtl_airband.conf"]

