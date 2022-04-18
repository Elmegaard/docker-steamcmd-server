#!/bin/bash
if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "SteamCMD not found!"
    wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz 
    tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
    rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
fi

echo "---Update SteamCMD---"
if [ "${USERNAME}" == "" ]; then
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login anonymous \
    +quit
else
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login ${USERNAME} ${PASSWRD} \
    +quit
fi

echo "---Update Server---"
if [ "${USERNAME}" == "" ]; then
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} \
        +quit
    fi
else
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} \
        +quit
    fi
fi

echo "---Prepare Server---"
echo "---Checking if 'Game.ini' exists---"
if [ ! -f ${SERVER_DIR}/Pavlov/Saved/Config/LinuxServer/Game.ini ]; then
	echo "---'Game.ini' not found, downloading...---"
	if [ ! -d ${SERVER_DIR}/Pavlov/Saved ]; then
    	mkdir ${SERVER_DIR}/Pavlov/Saved
	fi
	if [ ! -d ${SERVER_DIR}/Pavlov/Saved/Config ]; then
    	mkdir ${SERVER_DIR}/Pavlov/Saved/Config
	fi
	if [ ! -d ${SERVER_DIR}/Pavlov/Saved/Config/LinuxServer ]; then
    	mkdir ${SERVER_DIR}/Pavlov/Saved/Config/LinuxServer
	fi
    cd ${SERVER_DIR}/Pavlov/Saved/Config/LinuxServer
	if wget -q -nc --show-progress --progress=bar:force:noscroll https://raw.githubusercontent.com/ich777/docker-steamcmd-server/pavlovvr/config/Game.ini ; then
		echo "---Successfully downloaded 'Game.ini'---"
	else
		echo "---Something went wrong, can't download 'Game.ini', putting server in sleep mode---"
		sleep infinity
	fi
else
	echo "---'Game.ini' found---"
fi
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}
${SERVER_DIR}/PavlovServer.sh ${GAME_PARAMS}