#!/bin/bash
#  Copyright (C) 2015, 2016 University of Stuttgart
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

# ############################################################################ #
# SETUP OF CLIENT                                                              #
# ############################################################################ #

set -e
set -x

ROOT=`pwd`/client
BINARY_FOLDER="bin"
INSTALL_PATH_PAPI=${ROOT}/${BINARY_FOLDER}/papi
INSTALL_PATH_APR=${ROOT}/${BINARY_FOLDER}/apr
INSTALL_PATH_APU=${INSTALL_PATH_APR}
INSTALL_PATH_CURL=${ROOT}/${BINARY_FOLDER}/curl
INSTALL_PATH_NVIDIA=${ROOT}/${BINARY_FOLDER}/nvidia
INSTALL_PATH_BISON=${ROOT}/${BINARY_FOLDER}/bison
INSTALL_PATH_FLEX=${ROOT}/${BINARY_FOLDER}/flex
INSTALL_PATH_SENSORS=${ROOT}/${BINARY_FOLDER}/sensors
INSTALL_PATH_EXCESS_QUEUE=${ROOT}/ext/queue
INSTALL_PATH_LIBIIO=${ROOT}/${BINARY_FOLDER}/libiio

PAPI="papi"
PAPI_VERSION="5.4.0"
CURL="curl"
CURL_VERSION="7.37.0"
APR="apr"
APR_VERSION="1.7.0"
APR_UTIL="apr-util"
APR_UTIL_VERSION="1.6.1"
EXCESS_QUEUE_VERSION=release/0.1.0
BISON=bison
BISON_VERSION=3.4.1
FLEX=flex
FLEX_VERSION=2.6.0
LM_SENSORS=lm-sensors
LM_SENSORS_VERSION=3-5-0

# ============================================================================ #
# DOWNLOAD AND INSTALL PAPI-C                                                  #
# ============================================================================ #

cd $ROOT
wget http://icl.cs.utk.edu/projects/papi/downloads/${PAPI}-${PAPI_VERSION}.tar.gz -O ${PAPI}-${PAPI_VERSION}.tar.gz
if [ ! -f ${PAPI}-${PAPI_VERSION}.tar.gz ]; then
    echo "[ERROR] File not found: " ${PAPI}-${PAPI_VERSION}.tar.gz
    exit 1;
fi
tar zxf ${PAPI}-${PAPI_VERSION}.tar.gz
cd ${PAPI}-${PAPI_VERSION}/src
./configure --prefix=${INSTALL_PATH_PAPI} --with-components="rapl coretemp infiniband"
make
make install all

# ============================================================================ #
# DOWNLOAD AND INSTALL CURL                                                    #
# ============================================================================ #

cd $ROOT
wget http://curl.haxx.se/download/${CURL}-${CURL_VERSION}.tar.gz -O ${CURL}-${CURL_VERSION}.tar.gz
if [ ! -f ${CURL}-${CURL_VERSION}.tar.gz ]; then
    echo "[ERROR] File not found: " ${CURL}-${CURL_VERSION}.tar.gz
    exit 1;
fi
tar zxf ${CURL}-${CURL_VERSION}.tar.gz
cd ${CURL}-${CURL_VERSION}
./configure --prefix=${INSTALL_PATH_CURL}
make
make install
make install all

# ============================================================================ #
# DOWNLOAD AND INSTALL APACHE APR                                              #
# ============================================================================ #

cd $ROOT
wget http://apache.crihan.fr/dist/apr/${APR}-${APR_VERSION}.tar.gz -O ${APR}-${APR_VERSION}.tar.gz
if [ ! -f ${APR}-${APR_VERSION}.tar.gz ]; then
    echo "[ERROR] File not found: " ${APR}-${APR_VERSION}.tar.gz
    exit 1;
fi
tar zxvf ${APR}-${APR_VERSION}.tar.gz
cd ${APR}-${APR_VERSION}
./configure --prefix=${INSTALL_PATH_APR}
make
make install
make install all

# ============================================================================ #
# DOWNLOAD AND INSTALL APACHE APR UTILITIES                                    #
# ============================================================================ #

cd $ROOT
wget http://apache.crihan.fr/dist/apr/${APR_UTIL}-${APR_UTIL_VERSION}.tar.gz -O ${APR_UTIL}-${APR_UTIL_VERSION}.tar.gz
if [ ! -f ${APR_UTIL}-${APR_UTIL_VERSION}.tar.gz ]; then
    echo "[ERROR] File not found: " ${APR_UTIL}-${APR_UTIL_VERSION}.tar.gz
    exit 1;
fi
tar zxvf ${APR_UTIL}-${APR_UTIL_VERSION}.tar.gz
cd ${APR_UTIL}-${APR_UTIL_VERSION}
./configure --prefix=${INSTALL_PATH_APU} --with-apr=${INSTALL_PATH_APR}
make
make install
make install all

# ============================================================================ #
# DOWNLOAD AND INSTALL NVIDIA GDK                                              #
# ============================================================================ #

cd $ROOT
mkdir -p nvidia_gdk_download
cd nvidia_gdk_download
NVIDIA_BASE_URL="http://developer.download.nvidia.com"
NVIDIA_GDK="gdk_linux_amd64_352_55_release.run"
wget ${NVIDIA_BASE_URL}/compute/cuda/7.5/Prod/gdk/${NVIDIA_GDK} -O ${NVIDIA_GDK}
if [ ! -f ${NVIDIA_GDK} ]; then
    echo "[ERROR] File not found: " ${NVIDIA_GDK}
    exit 1;
fi
chmod +x ${NVIDIA_GDK}
rm -f ${INSTALL_PATH_NVIDIA}/usr/bin/nvvs
./${NVIDIA_GDK} --silent --installdir=${INSTALL_PATH_NVIDIA}

# ============================================================================ #
# DOWNLOAD AND INSTALL SENSORS LIB                                             #
# https://fossies.org/linux/misc/lm_sensors-3.4.0.tar.gz/lm_sensors-3.4.0/lib/libsensors.3
# ============================================================================ #
#
# DEPENDENCIES: bison and flex
#
cd $ROOT
wget http://ftp.gnu.org/gnu/bison/${BISON}-${BISON_VERSION}.tar.gz -O ${BISON}-${BISON_VERSION}.tar.gz
tar zxf ${BISON}-${BISON_VERSION}.tar.gz
cd ${BISON}-${BISON_VERSION}
./configure --prefix=${INSTALL_PATH_BISON}
make
make install

cd $ROOT
wget http://prdownloads.sourceforge.net/flex/${FLEX}-${FLEX_VERSION}.tar.gz -O ${FLEX}-${FLEX_VERSION}.tar.gz
tar zxf ${FLEX}-${FLEX_VERSION}.tar.gz
cd ${FLEX}-${FLEX_VERSION}
./configure --prefix=${INSTALL_PATH_FLEX}
make
make install

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${INSTALL_PATH_FLEX}/lib:${INSTALL_PATH_BISON}/lib
export PATH=${PATH}:${INSTALL_PATH_BISON}/bin:${INSTALL_PATH_FLEX}/bin

cd $ROOT
wget https://fossies.org/linux/misc/${LM_SENSORS}-${LM_SENSORS_VERSION}.tar.gz -O ${LM_SENSORS}-${LM_SENSORS_VERSION}.tar.gz
tar zxf ${LM_SENSORS}-${LM_SENSORS_VERSION}.tar.gz
cd ${LM_SENSORS}-${LM_SENSORS_VERSION}
make PREFIX=${INSTALL_PATH_SENSORS} all
make PREFIX=${INSTALL_PATH_SENSORS} install


# ============================================================================ #
# DOWNLOAD AND INSTALL LIBIIO                                                  #
# https://wiki.analog.com/resources/tools-software/linux-software/libiio
# ============================================================================ #
#
# DEPENDENCIES: libxml2 libxml2-dev bison flex libcdk5-dev libavahi-client-dev cmake
#
cd $ROOT
rm -rf libiio
git clone https://github.com/analogdevicesinc/libiio.git
cd libiio
mkdir -p ${INSTALL_PATH_LIBIIO}
cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH_LIBIIO} ./
make all
make install
find ./ -name "libiio.so*" -exec mv {} ${INSTALL_PATH_LIBIIO}/lib/ \;

# ============================================================================ #
# DOWNLOAD AND INSTALL EXCESS QUEUE LIBS                                                                                        #
# https://github.com/excess-project/data-structures-library.git
# ============================================================================ #
#
cd $INSTALL_PATH_EXCESS_QUEUE
rm -rf data-structures-library
git clone https://github.com/excess-project/data-structures-library.git
cd data-structures-library
git checkout $EXCESS_QUEUE_VERSION

# ============================================================================ #
# CLEANING UP                                                                  #
# ============================================================================ #

cd $ROOT
rm -f *.tar.gz
rm -rf ${PAPI}-${PAPI_VERSION}
rm -rf ${LIKWID}-${LIKWID_VERSION}
rm -rf ${APR}-${APR_VERSION}
rm -rf ${APR_UTIL}-${APR_UTIL_VERSION}
rm -rf ${CURL}-${CURL_VERSION}
rm -rf nvidia_gdk_download
rm -rf bison-3.0.2
rm -rf flex-2.6.0
rm -rf lm_sensors-3.4.0
rm -rf ${NVIDIA_GDK}
rm -rf libiio


cd $ROOT/..

# ############################################################################ #
# SETUP OF SERVER                                                              #
# ############################################################################ #

BASE_DIR=`pwd`/server
TMP_DIR=${BASE_DIR}/tmp
DIST_DIR=${BASE_DIR}/dist


ELASTICSEARCH_VERSION="2.1.1"
ELASTICSEARCH="elasticsearch-${ELASTICSEARCH_VERSION}"
NODE_JS_VERSION="4.2.1"
NODE_JS="node-v${NODE_JS_VERSION}-linux-x64"


rm -rf ${DIST_DIR}
mkdir ${TMP_DIR}
mkdir ${DIST_DIR}
cd ${BASE_DIR}

echo "Checking for required software:"
echo "> git"
command -v git >/dev/null 2>&1 || { echo " git  : Not installed. Aborting." >&2; exit 1; }
echo "> wget"
command -v wget >/dev/null 2>&1 || { echo " wget  : Not installed. Aborting." >&2; exit 1; }

#
# DOWNLOADING AND INSTALLING EXTERNAL DEPENDENCIES
# > elasticsearch
# > node.js and npm
#
echo "Installing external dependencies:"
echo "> elasticsearch"
cd ${TMP_DIR}
if [ ! -f "${ELASTICSEARCH}.tar.gz" ]
then
    wget https://download.elasticsearch.org/elasticsearch/elasticsearch/${ELASTICSEARCH}.tar.gz
fi
if [ ! -d "${DIST_DIR}/${ELASTICSEARCH}" ]
then
    tar -xf ${ELASTICSEARCH}.tar.gz
    mv ${ELASTICSEARCH} ${DIST_DIR}/elasticsearch
fi

echo "> node.js"
cd ${TMP_DIR}
if [ ! -f "${NODE_JS}.tar.gz" ]
then
    wget https://nodejs.org/dist/v${NODE_JS_VERSION}/${NODE_JS}.tar.gz
fi

if [ ! -d "${DIST_DIR}/${NODE_JS}" ]
then
    tar -xf ${NODE_JS}.tar.gz
    mv ${NODE_JS} ${DIST_DIR}/nodejs
fi

rm -rf ${TMP_DIR}
