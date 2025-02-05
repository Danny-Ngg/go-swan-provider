#!/bin/bash

CONF_FILE_DIR=${HOME}/.swan/provider

if [ ! -d "${CONF_FILE_DIR}" ]; then
    mkdir -p ${CONF_FILE_DIR}
fi

CONF_FILE_PATH=${CONF_FILE_DIR}/config.toml
echo $CONF_FILE_PATH

if [ -f "${CONF_FILE_PATH}" ]; then
    echo "${CONF_FILE_PATH} exists"
else
    cp ./config/config.toml.example $CONF_FILE_PATH
    ARIA2_DOWNLOAD_DIR=${CONF_FILE_DIR}/download
    sed -i 's@%%ARIA2_DOWNLOAD_DIR%%@'${ARIA2_DOWNLOAD_DIR}'@g' $CONF_FILE_PATH   # Set aria2 download dir

    if [ ! -d "${ARIA2_DOWNLOAD_DIR}" ]; then
        mkdir -p ${ARIA2_DOWNLOAD_DIR}
        echo "${ARIA2_DOWNLOAD_DIR} created"
    else
        echo "${ARIA2_DOWNLOAD_DIR} exists"
    fi

    echo "${CONF_FILE_PATH} created"
fi

sed -i 's/%%USER%%/'${USER}'/g' ./aria2c.service   # Set User & Group to value of $USER

if [ ! -d "/etc/aria2" ]; then
    sudo mkdir /etc/aria2
    echo "/etc/aria2 created"
else
    echo "/etc/aria2 exists"
fi

sudo chown $USER:$USER /etc/aria2/             # Change user authority to current user

ARIA2_SESSION=/etc/aria2/aria2.session
if [ -f "${ARIA2_SESSION}" ]; then
    echo ${ARIA2_SESSION} exists
else
    sudo touch ${ARIA2_SESSION}            # Create a session file
fi

ARIA2_CONF=/etc/aria2/aria2.conf
if [ -f "${ARIA2_CONF}" ]; then
    echo ${ARIA2_CONF} exists
else
    sudo cp ./config/aria2.conf /etc/aria2/               # Copy config file
fi

ARIA2_SERVICE=/etc/systemd/system/aria2c.service
if [ -f "${ARIA2_SERVICE}" ]; then
    echo ${ARIA2_SERVICE} exists
else
    sudo cp ./aria2c.service /etc/systemd/system/    # Copy service file
fi

sudo systemctl enable aria2c.service           # Set to start Aria2 automatically
sudo systemctl restart aria2c.service            # Start Aria2


BINARY_NAME=swan-provider

make
chmod +x ./build/${BINARY_NAME}
./build/${BINARY_NAME}                         # Run swan provider

