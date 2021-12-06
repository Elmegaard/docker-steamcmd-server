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
        +login anonymous \
        +force_install_dir ${SERVER_DIR} \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +login anonymous \
        +force_install_dir ${SERVER_DIR} \
        +app_update ${GAME_ID} \
        +quit
    fi
else
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +login ${USERNAME} ${PASSWRD} \
        +force_install_dir ${SERVER_DIR} \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +login ${USERNAME} ${PASSWRD} \
        +force_install_dir ${SERVER_DIR} \
        +app_update ${GAME_ID} \
        +quit
    fi
fi

echo "---Prepare Server---"
if [ ! -f ${SERVER_DIR}/ShooterGame/Binaries/Linux/libsteam_api.so ]; then
	echo "---Librarys not found, downloading---"
    cd ${SERVER_DIR}/ShooterGame/Binaries/Linux
	if wget -q -nc --show-progress --progress=bar:force:noscroll https://github.com/ich777/runtimes/raw/master/arkse/lib.tar.gz ; then
		echo "---Download complete, extracting---"
		tar -xvf ${SERVER_DIR}/ShooterGame/Binaries/Linux/lib.tar.gz
		rm ${SERVER_DIR}/ShooterGame/Binaries/Linux/lib.tar.gz
	else
		echo "---Something went wrong, can't download Librarys, putting server in sleep mode---"
        rm ${SERVER_DIR}/ShooterGame/Binaries/Linux/lib.tar.gz
		sleep infinity
	fi
fi
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}/ShooterGame/Binaries/Linux
./ShooterGameServer ${MAP}?listen?SessionName=${SERVER_NAME}?ServerPassword=${SRV_PWD}?ServerAdminPassword=${SRV_ADMIN_PWD}${GAME_PARAMS} ${GAME_PARAMS_EXTRA}
