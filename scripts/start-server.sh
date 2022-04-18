#!/bin/bash
if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "SteamCMD not found!"
    wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz 
    tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
    rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
fi

echo "---Update SteamCMD---"
if [ "${USERNAME}" == "" ]; then
    echo "Please enter a valid username and password and restart the container. ATTENTION: Steam Guard must be DISABLED!!!"
    sleep infinity
else
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login ${USERNAME} ${PASSWRD} \
    +quit
fi

echo "---Update Server---"
if [ "${VALIDATE}" == "true" ]; then
	echo "---Validating installation---"
    ${STEAMCMD_DIR}/steamcmd.sh \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir ${SERVER_DIR} \
    +login ${USERNAME} ${PASSWRD} \
    +app_update ${GAME_ID} validate \
    +quit
else
    ${STEAMCMD_DIR}/steamcmd.sh \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir ${SERVER_DIR} \
    +login ${USERNAME} ${PASSWRD} \
    +app_update ${GAME_ID} \
    +quit
fi

if [ "${INSTALL_STRACKER}" == "true" ]; then
echo "---Searching for Stracker installation---"
    if [ ! -f ${SERVER_DIR}/stracker/stracker_linux_x86/stracker ]; then
		echo "---Stracker not found, downloading and installing---"
		if [ ! -d ${SERVER_DIR}/stracker ]; then
			mkdir ${SERVER_DIR}/stracker
		fi
		cd ${SERVER_DIR}/stracker
		if wget -q -nc --show-progress --progress=bar:force:noscroll -O stracker.zip https://github.com/ich777/runtimes/raw/master/stracker/stracker.zip ; then
			echo "---Successfully downloaded Stracker!---"
		else
			echo "---Something went wrong, can't download Stracker, putting server in sleep mode---"
			sleep infinity
		fi
		unzip -o stracker.zip
		rm ${SERVER_DIR}/stracker/stracker.zip
		tar -xvzf stracker_linux_x86.tgz
		rm ${SERVER_DIR}/stracker/stracker_linux_x86.tgz
		rm ${SERVER_DIR}/stracker/start-stracker.cmd
		if [ -f ${SERVER_DIR}/stracker.ini ]; then
			echo "---Old stracker.ini found, copying!---"
			mv ${SERVER_DIR}/stracker.ini ${SERVER_DIR}/stracker/stracker_linux_x86/stracker.ini
			rm ${SERVER_DIR}/stracker/stracker-default.ini
		else
			rm ${SERVER_DIR}/stracker/stracker-default.ini
		fi
	else
		echo "---Stracker found, continuing---"
	fi
else
	if [ -d ${SERVER_DIR}/stracker ]; then
		echo "---Old stracker installation found, removing and backing up stracker.ini---"
		if [ -f ${SERVER_DIR}/stracker/stracker_linux_x86/stracker.ini ]; then
			cp ${SERVER_DIR}/stracker/stracker_linux_x86/stracker.ini ${SERVER_DIR}/stracker.ini
			echo "---'stracker.ini' backed up to main directory---"
		else
			echo "---Can't find old 'stracker.ini', continuing---"
		fi
		rm -R ${SERVER_DIR}/stracker
	fi
	if [ -f ${SERVER_DIR}/stracker.log ]; then
		rm ${SERVER_DIR}/stracker.log
	fi
	if [ -f ${SERVER_DIR}/AC.log ]; then
		rm ${SERVER_DIR}/AC.log
	fi
fi

if [ "${INSTALL_ASSETTO_SERVER_MANAGER}" == "true" ]; then
	if [ ! -f ${SERVER_DIR}/assetto-server-manager/linux/server-manager ]; then
		echo "---Assetto-Server-Manager not found, installing!---"
		echo "---Trying to get latest version for Assetto-Server-Manager---"
		ASSETTO_SERVER_MANAGER_V="$(curl -s https://api.github.com/repos/JustaPenguin/assetto-server-manager/releases/latest | grep tag_name | cut -d '"' -f4 | cut -d 'v' -f2)"
		if [ -z $ASSETTO_SERVER_MANAGER_V ]; then
			echo "---Can't get latest version for Assetto-Server-Manager, putting container into sleep mode!---"
			sleep infinity
		fi
		echo "---Latest version for Assetto-Server-Manager: v$ASSETTO_SERVER_MANAGER_V---"
		if [ ! -d ${SERVER_DIR}/assetto-server-manager ]; then
			mkdir -p ${SERVER_DIR}/assetto-server-manager
		fi
		cd ${SERVER_DIR}/assetto-server-manager
		echo "---Downloading Assetto-Server-Manager v$ASSETTO_SERVER_MANAGER_V, please wait!---"
		if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/assetto-server-manager/asm.zip "https://github.com/JustaPenguin/assetto-server-manager/releases/download/v$ASSETTO_SERVER_MANAGER_V/server-manager_v$ASSETTO_SERVER_MANAGER_V.zip" ; then
			echo "---Successfully downloaded Assetto-Server-Manager v$ASSETTO_SERVER_MANAGER_V---"
		else
			echo "---Download of Assetto-Server-Manager v$ASSETTO_SERVER_MANAGER_V failed, putting container into sleep mode!---"
			sleep infinity
		fi
		unzip ${SERVER_DIR}/assetto-server-manager/asm.zip
		rm ${SERVER_DIR}/assetto-server-manager/asm.zip
	else
		echo "---Assetto-Server-Manager found, continuing!---"
	fi
fi

echo "---Prepare Server---"
if [ "${INSTALL_STRACKER}" == "true" ]; then
	echo "---Checking if Server is configured properly---"
	sed -i '/UDP_PLUGIN_ADDRESS/c\UDP_PLUGIN_ADDRESS=127.0.0.1:12000' ${SERVER_DIR}/cfg/server_cfg.ini
	sed -i '/UDP_PLUGIN_LOCAL_PORT/c\UDP_PLUGIN_LOCAL_PORT=11000' ${SERVER_DIR}/cfg/server_cfg.ini
	if [ ! -f ${SERVER_DIR}/stracker/stracker_linux_x86/stracker.ini ]; then
		cd ${SERVER_DIR}/stracker/stracker_linux_x86
		if wget -q -nc --show-progress --progress=bar:force:noscroll -O stracker.ini https://raw.githubusercontent.com/ich777/docker-steamcmd-server/assettocorsa/config/stracker.ini ; then
			echo "---Successfully downloaded 'stacker.ini'---"
		else
			echo "---Something went wrong, can't download 'stacker.ini', putting server in sleep mode---"
			sleep infinity
		fi
	fi
	echo "---Checking for old logs---"
	find ${SERVER_DIR} -name "AC.log" -exec rm -f {} \;
	find ${SERVER_DIR} -name "stracker.log" -exec rm -f {} \;
else
	sed -i '/UDP_PLUGIN_ADDRESS/c\UDP_PLUGIN_ADDRESS=' ${SERVER_DIR}/cfg/server_cfg.ini
	sed -i '/UDP_PLUGIN_LOCAL_PORT/c\UDP_PLUGIN_LOCAL_PORT=0' ${SERVER_DIR}/cfg/server_cfg.ini
fi
if [ "${INSTALL_ASSETTO_SERVER_MANAGER}" == "true" ]; then
	sed -i '/  username:/c\  username:' ${SERVER_DIR}/assetto-server-manager/linux/config.yml
	sed -i '/  password:/c\  password:' ${SERVER_DIR}/assetto-server-manager/linux/config.yml
	sed -i '/  install_path:/c\  install_path: /serverdata/serverfiles/' ${SERVER_DIR}/assetto-server-manager/linux/config.yml
fi
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Start Server---"
if [ "${INSTALL_STRACKER}" == "true" ]; then
	cd ${SERVER_DIR}
	screen -S AssettoCorsa -L -Logfile ${SERVER_DIR}/AC.log -d -m ${SERVER_DIR}/acServer
	sleep 10
	cd ${SERVER_DIR}/stracker/stracker_linux_x86
	screen -S Stracker -L -d -m ${SERVER_DIR}/stracker/stracker_linux_x86/stracker --stracker_ini ${SERVER_DIR}/stracker/stracker_linux_x86/stracker.ini
	sleep 2
	tail -f ${SERVER_DIR}/AC.log ${SERVER_DIR}/stracker.log
elif [ "${INSTALL_ASSETTO_SERVER_MANAGER}" == "true" ]; then
	cd ${SERVER_DIR}/assetto-server-manager/linux
	${SERVER_DIR}/assetto-server-manager/linux/server-manager
else
	cd ${SERVER_DIR}
	${SERVER_DIR}/acServer
fi