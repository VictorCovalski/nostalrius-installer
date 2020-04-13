#!/bin/bash

# Nostalrius 7.4 Client Installer
# https://nostalrius.com.br
# 
# Developed by Victor Covalski <vrcjunes@gmail.com>
# Tested on Ubuntu 18.04 LTS amd64
# 
# License: MIT
#

[[ -z $DEBUG ]] || set -x 

CLIENT_URL="https://github.com/VictorCovalski/nostalrius-installer/raw/master/nostalrius.zip"
MAP_URL="https://github.com/VictorCovalski/nostalrius-installer/raw/master/minimap.otmm"
INSTALL_DIR="${HOME}/.nostalrius"
NOSTALRIUS_CONFIG_PATH=$( echo -n "${HOME}/.wine/drive_c/users/${USER}/Application Data/OTClientV8/nostalrius_74/")

wine 2>/dev/null ; if [[ $? != 1 ]] ; then
	read -p "Could not find your wine installation. Install package wine-stable. Proceed (y/n)?"
	case ${REPLY} in
	 [yY]*)
		sudo apt install wine-stable -y
		break;;
	 *) exit ;;
        esac
fi

#set -e

read -p "Enter path to install Nostalrius (eg. /opt/nostalrius ) Default: [${INSTALL_DIR}]"

if [[ ${ans} != "" ]]; then
	INSTALL_DIR=${ans}
fi

if [[ ! -d $INSTALL_DIR ]]; then
	mkdir -p ${INSTALL_DIR}
fi

echo "Downloading Nostalrius Client files"
wget $CLIENT_URL -O /tmp/nostalrius.zip 

echo -n "Installing Nostalrius"
unzip -o /tmp/nostalrius.zip -d "$INSTALL_DIR" &>/dev/null
echo -n '.'

wine "${INSTALL_DIR}/Nostalrius_DX9.exe" &>/dev/null &
winePid=$!
echo -n '.'
while [[ ! -d "$NOSTALRIUS_CONFIG_PATH" ]]; do
	echo -n '.' ; sleep 1
done

kill $winePid &>/dev/null
echo '. Done!'

read -p "Do you wish to install the game maps? (y/n) [n]"

case $REPLY in
  [yY]*)
	  wget $MAP_URL -O "/tmp/minimap.otmm" 
	  mv /tmp/minimap.otmm "${NOSTALRIUS_CONFIG_PATH}/minimap.otmm"
	  break;;
      *)
	  break;;
esac

cat << EOFCLI > /home/${USER}/.local/bin/nostalrius
#!/bin/bash

nohup wine ${INSTALL_DIR}/Nostalrius_DX9.exe &>/dev/null &
EOFCLI
chmod +x ~/.local/bin/nostalrius

echo "Creating Desktop shortcut"
cat << EOFDESKTOP > ${HOME}/Desktop/Nostalrius.desktop
[Desktop Entry]
Version=7.4
Name=Nostalrius
Comment=Tibia OTServer https://nostalrius.com.br
Exec=/usr/bin/wine ./Nostalrius_DX9.exe
Path=${INSTALL_DIR}
Icon=${INSTALL_DIR}/icon.gif
Terminal=false
Type=Application
Categories=Games;
EOFDESKTOP

chmod +x ~/Desktop/Nostalrius.desktop

echo "Nostalrius was successfully installed"

