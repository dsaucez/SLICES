FROM ubuntu:jammy AS ran-flexric

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade --yes && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes \
       build-essential \
       libsctp-dev \
       git \
       wget \
       tar \
       m4 \
       automake \
       libtool \
       python3 \
       cmake \
       cmake-curses-gui \
       bison \
       flex \
       gdb \
       libpcre2-dev \
       python3-dev \
       python3-pip \
       gcc-12 && \
    apt-get clean

WORKDIR /opt

#swig
RUN git clone https://github.com/swig/swig.git /opt/swig
RUN cd swig && git checkout release-4.1 && ./autogen.sh && ./configure --prefix=/usr/ && make  -j8 && make install

WORKDIR /



#flexric
RUN git clone https://gitlab.eurecom.fr/mosaic5g/flexric /flexric
COPY xapp_kpm_moni.c .

WORKDIR /flexric
RUN git checkout dev 
RUN rm -rf /examples/xApp/c/monitor/xapp_kpm_moni.c
COPY /xapp_kpm_moni.c  /flexric/examples/xApp/c/monitor/xapp_kpm_moni.c
RUN mkdir build && \
    cd build && \
    cmake -DCMAKE_C_COMPILER=gcc-12 .. && make -j8 && make install

WORKDIR /flexric


