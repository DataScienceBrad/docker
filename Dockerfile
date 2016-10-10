FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04
MAINTAINER Chris Stone <chstone>

ENV DISTRO=xenial
ENV PYTHONPATH /mxnet/python
ENV CUDA_PATH /usr/local/cuda

#RUN echo "deb https://cran.cnr.berkeley.edu/bin/linux/ubuntu $DISTRO/" >> /etc/apt/sources.list && \
  #echo "deb https://azure.archive.ubuntu.com/ $DISTRO-backports main restricted universe" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
  build-essential \
  git \
  libcurl4-openssl-dev \
  libopenblas-dev \
  libopencv-dev \
  libssl-dev \
  python-numpy \
  python-opencv \
  r-base \
  r-base-dev \
  wget \
  unzip

RUN git clone --recursive https://github.com/dmlc/mxnet && \
  cd mxnet && \
  cp make/config.mk . && \
  echo "USE_BLAS=openblas" >> config.mk && \
  echo "USE_CUDA=1" >> config.mk && \
  echo "USE_CUDNN=1" >> config.mk && \
  echo "USE_CUDA_PATH=$CUDA_PATH" >> config.mk && \
  make -j$(nproc) && \
  Rscript -e "install.packages('devtools', repo = 'https://cran.rstudio.com')" && \
  cd R-package && \
  Rscript -e "library(devtools); library(methods); options(repos=c(CRAN='https://cran.rstudio.com')); install_deps(dependencies = TRUE)" && \
  cd .. && \
  make rpkg && \
  cd ..

RUN cd mxnet && \
  R CMD INSTALL mxnet_*.tar.gz && \
  cd ..
