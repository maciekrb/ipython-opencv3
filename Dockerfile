FROM ubuntu:latest

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -y -q install \
  build-essential \
  cmake \
  ca-certificates \
  curl \
  libjpeg8-dev \
  libtiff4-dev \
  libjasper-dev \
  libpng12-dev \
  libavcodec-dev \
  libavformat-dev \
  libswscale-dev \
  libv4l-dev \
  libatlas-base-dev \
  libfreetype6-dev \
  gfortran \
  pkg-config \
  python-dev \
  python-openssl \
  python-pip \
  && apt-get clean && rm -rf /var/tmp/* /var/lib/apt/lists/* /tmp/*

# ------------------------------------- python deps -------------------------------------------
RUN pip install \
  docopt \
  numpy \
  scipy 

RUN pip install \
  matplotlib \
  mahotas \
  scikit-learn \
  scikit-image 

# ------------------------------------- python niceties ---------------------------------------
RUN pip install \
  ipython \
  notebook

# ------------------------------------- OpenCV stuff ------------------------------------------
COPY opencv/ /opt/src/opencv
COPY opencv_contrib/ /opt/src/opencv_contrib
RUN mkdir /opt/src/opencv/build

WORKDIR /opt/src/opencv/build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D INSTALL_C_EXAMPLES=ON \
  -D INSTALL_PYTHON_EXAMPLES=ON \
  -D OPENCV_EXTRA_MODULES_PATH=/opt/src/opencv_contrib/modules \
  -D BUILD_EXAMPLES=ON .. \
  && make -j4 \
  && make install \
  && ldconfig

# ------------------------------------- Startup script ----------------------------------------
COPY notebook.sh /
RUN chmod +x /notebook.sh

VOLUME /notebooks
WORKDIR /notebooks
EXPOSE 8888
CMD ["/notebook.sh"]
