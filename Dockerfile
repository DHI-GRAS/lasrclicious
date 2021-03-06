FROM ubuntu:18.04
MAINTAINER "Jonas Sølvsteen <josl@dhigroup.com>"

USER root

RUN apt-get update && \
    apt-get install -y \
        'gcc' \
        'make' \
        'curl' \
        'gdal-bin' \
        'python' \
        'python-numpy' \
        'python-gdal' \
        'python-requests' \
        'libtiff-dev' \
        'libjpeg-dev' \
        'libxml2-dev' \
        'libgeotiff-dev' \
        'hdf4-tools' \
        'libhdf4-dev' \
        'libhdf5-dev' \
        'libnetcdf-dev' \
        'libidn11-dev' \
        'zlib1g-dev' \
        'liblzma-dev' && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*


# hdfEOS
RUN curl https://observer.gsfc.nasa.gov/ftp/edhs/hdfeos/latest_release/HDF-EOS2.20v1.00.tar.Z -o /tmp/hdfeos.tar.Z
RUN tar xzf /tmp/hdfeos.tar.Z -C /opt
WORKDIR /opt/hdfeos
RUN ./configure CC=/usr/bin/h4cc --prefix=/opt/hdfeos/build && \
    make -j 4 && \
    make install && \
    make clean && \
    ls /opt/hdfeos/build


# environment
ENV XML2INC=/usr/include/libxml2
ENV XML2LIB=/usr/lib/x86_64-linux-gnu
ENV GEOTIFF_INC=/usr/include/geotiff
ENV GEOTIFF_LIB=/usr/lib/x86_64-linux-gnu
ENV TIFFINC=/usr/include/x86_64-linux-gnu
ENV TIFFLIB=/usr/lib/x86_64-linux-gnu
ENV HDFEOS_INC=/opt/hdfeos/include
ENV HDFEOS_LIB=/opt/hdfeos/build/lib
ENV HDFEOS_GCTPINC=/opt/hdfeos/gctp/include
ENV HDFEOS_GCTPLIB=/opt/hdfeos/build/lib
ENV HDFINC=/usr/include/hdf
ENV HDFLIB=/usr/lib/libdf.so
ENV HDF5INC=/usr/include/hdf5/serial
ENV HDF5LIB=/usr/lib/x86_64-linux-gnu/hdf5/serial
ENV NCDF4INC=/usr/include
ENV NCDF4LIB=/usr/lib/x86_64-linux-gnu
ENV JPEGINC=/usr/include
ENV JPEGLIB=/usr/lib/x86_64-linux-gnu
ENV ZLIBINC=/usr/include
ENV ZLIBLIB=/usr/lib/x86_64-linux-gnu
ENV SZIPINC=/usr/include
ENV SZIPLIB=/usr/lib/x86_64-linux-gnu
ENV CURLINC=/usr/include/curl
ENV CURLLIB=/usr/lib/x86_64-linux-gnu
ENV LZMAINC=/usr/include/lzma
ENV LZMALIB=/usr/lib/x86_64-linux-gnu
ENV IDNINC=/usr/include
ENV IDNLIB=/usr/lib/x86_64-linux-gnu
ENV JBIGINC=/usr/include
ENV JBIGLIB=/usr/lib/x86_64-linux-gnu

ENV ESPAINC=/opt/espa-product-formatter/raw_binary/include
ENV ESPALIB=/opt/espa-product-formatter/raw_binary/lib


# product formatter
RUN curl -L https://github.com/USGS-EROS/espa-product-formatter/archive/product_formatter_v1.15.0.tar.gz -o /tmp/product_formatter.tar.gz && \
    tar xzf /tmp/product_formatter.tar.gz && \
    mv espa-product-formatter-product_formatter_v1.15.0 /opt/espa-product-formatter && \
    rm /tmp/product_formatter.tar.gz

ENV PREFIX=/opt/espa-product-formatter/build

WORKDIR /opt/espa-product-formatter
RUN make && \
    make install && \
    ls -l $PREFIX


# surface reflectance
RUN curl -L https://github.com/DHI-GRAS/espa-surface-reflectance/archive/gras-patch.tar.gz -o /tmp/lasrc.tar.gz && \
    tar xzf /tmp/lasrc.tar.gz && \
    mv espa-surface-reflectance-gras-patch /opt/espa-surface-reflectance && \
    rm /tmp/lasrc.tar.gz

ENV PREFIX=/opt/espa-surface-reflectance/build

WORKDIR /opt/espa-surface-reflectance/lasrc
RUN make && \
    make install && \
    make clean && \
    ls -l $PREFIX

RUN make all-lasrc-aux && \
    make install-lasrc-aux && \
    make clean-lasrc-aux && \
    ls -l $PREFIX

WORKDIR /opt/espa-surface-reflectance/scripts
RUN make && \
    make install && \
    make clean && \
    ls -l $PREFIX


# cloud masking
RUN curl -L https://github.com/USGS-EROS/espa-cloud-masking/archive/cfmask-v2.0.2.tar.gz -o /tmp/cloud_masking.tar.gz && \
    tar xzf /tmp/cloud_masking.tar.gz && \
    mv espa-cloud-masking-cfmask-v2.0.2 /opt/espa-cloud-masking && \
    rm /tmp/cloud_masking.tar.gz

ENV PREFIX=/opt/espa-cloud-masking/build

WORKDIR /opt/espa-cloud-masking
RUN make && \
    make install && \
    make clean && \
    ls -l $PREFIX


# path, volumes, and scripts
VOLUME ["/mnt/lasrc-aux"]
ENV L8_AUX_DIR=/mnt/lasrc-aux

ENV ESUN=/opt/espa-cloud-masking/cfmask/static_data
ENV ESPA_SCHEMA=/opt/espa-product-formatter/build/schema/espa_internal_metadata_v2_0.xsd
ENV PATH=/opt/espa-product-formatter/build/bin:/opt/espa-cloud-masking/build/bin:/opt/espa-surface-reflectance/build/bin:$PATH

VOLUME ["/mnt/input-dir"]
VOLUME ["/mnt/output-dir"]

COPY run_lasrc.sh /usr/local/bin
RUN chmod +x /usr/local/bin/run_lasrc.sh
COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /work
ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
CMD ["--help"]
