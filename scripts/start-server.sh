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
echo "---Checking if 'settings.xml' is present---"
if [ ! -f ${SERVER_DIR}/settings.xml ]; then
	cd ${SERVER_DIR}
	if wget -q -O ${SERVER_DIR}/settings.xml --show-progress --progress=bar:force:noscroll https://raw.githubusercontent.com/ich777/docker-steamcmd-server/stationeers/config/settings.xml ; then
		echo "---Sucessfully downloaded configuration file 'settings.xml'---"
	else
		echo "---Something went wrong, can't download 'settings.xml', putting server in sleep mode---"
		sleep infinity
	fi
else
	echo "---Configuration file 'settings.xml' found---"
fi
chmod -R ${DATA_PERM} ${DATA_DIR}
find $SERVER_DIR -name "masterLog.*" -exec rm -f {} \;

echo "---Prepare BeepinEx---"
if [ ! -f ${SERVER_DIR}/BepInEx ]; then
	cd ${SERVER_DIR}
	if wget curl -s https://api.github.com/repos/BepInEx/BepInEx/releases/latest | grep "BepInEx_linux_x64_.*zip" | cut -d : -f 2,3 | tr -d \" | wget -O bepinex.zip --show-progress --progress=bar:force:noscroll -qi - ; then
		echo "---Sucessfully downloaded 'bepinex.zip'---"
        unzip -o bepinex.zip
        chmod +x run_bepinex.sh
        sed -i 's/executable_name=""/executable_name="rocketstation_DedicatedServer.x86_64"/g' run_bepinex.sh
        rm bepinex.zip
	    echo "---BeepinEx successfully installed---"
	else
		echo "---Something went wrong, can't download 'BepInEx', putting server in sleep mode---"
		sleep infinity
	fi
else
	echo "---BeepinEx already installed---"
fi

echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}

if [ ! -f ${SERVER_DIR}/run_bepinex.sh ]; then
  echo "---Something went wrong, can't find the 'run_bepinex.sh', putting container into sleep mode!---"
  sleep infinity
fi

if [ ! -f ${SERVER_DIR}/rocketstation_DedicatedServer.x86_64 ]; then
  echo "---Something went wrong, can't find the executable, putting container into sleep mode!---"
  sleep infinity
else
  ${SERVER_DIR}/run_bepinex.sh ${GAME_PARAMS} -settingspath ${SERVER_DIR}/settings.xml
fi