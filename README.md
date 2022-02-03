# SteamCMD in Docker optimized for Unraid
This Docker will download and install SteamCMD. It will also install Alien Swarm: Reactive Drop and run it.

**!!!This container will only run on systems with less than 32 CPU cores!!!**

**Update Notice:** Simply restart the container if a newer version of the game is available.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| STEAMCMD_DIR | Folder for SteamCMD | /serverdata/steamcmd |
| SERVER_DIR | Folder for gamefile | /serverdata/serverfiles |
| GAME_ID | SteamID for server | 563560 |
| GAME_NAME | SRCDS gamename | reactivedrop |
| GAME_PARAMS | Values to start the server | +map lobby -maxplayers 4 +exec server.cfg |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| GAME_PORT | Port the server will be running on | 27015 |
| VALIDATE | Validates the game data | blank |
| USERNAME | Leave blank for anonymous login | blank |
| PASSWRD | Leave blank for anonymous login | blank |

## Run example
```
docker run --name AlienSwarmReactiveDrop -d \
	-p 27015:27015 -p 27015:27015/udp \
	--env 'GAME_ID=563560' \
	--env 'GAME_NAME=reactivedrop' \
	--env 'GAME_PORT=27015' \
	--env 'GAME_PARAMS=+map lobby -maxplayers 4 +exec server.cfg' \
	--env 'UID=99' \
	--env 'GID=100' \
	--volume /path/to/steamcmd:/serverdata/steamcmd \
	--volume /path/to/alienswarmreactivedrop:/serverdata/serverfiles \
	ich777/steamcmd:alienswarmreactivedrop
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!


This Docker is forked from mattieserver, thank you for this wonderfull Docker.
