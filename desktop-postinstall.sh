
#!/bin/bash
 
# ctags pgadmin3
progslist="gcc g++ make cmake unrar nmap traceroute libpcap-dev cppcheck valgrind mc automake \
autoconf autoconf-doc  fdupes mesa-common-dev libglew-dev libglm-dev hydrogen \
tuxguitar tuxguitar-alsa jackd audacious audacity mplayer mplayer-gui mplayer-skins gimp qbittorrent \
wine-stable timidity tuxguitar-jsa virtualbox virtualbox-guest-additions-iso \
virtualbox-guest-additions-iso pavucontrol brasero filezilla conky \
mypaint htop virtualbox-qt whois gtk+-3.0 libpq-dev postgresql-client-common \
postgresql dconf-editor ddd libcurl4-openssl-dev vlc \
libboost-all-dev curl doxygen graphviz devhelp git git-lfs \
libgtkmm-3.0-dev libgtkmm-3.0-doc freeglut3 freeglut3-dev mesa-common-dev \
qtcreator qt5-qmake qt5-doc qdbus-qt5 qt5serialport-examples libqt5xml5 libqt5quick5 libqt5qml5 linguist-qt6 \
virtualbox-dkms virtualbox-guest-utils virtualbox-modules \
inkscape apache2 \
libsdl2-dev libsdl2-doc libsdl2-image-2.0-0 libsdl2-image-dev libsdl2-mixer-2.0-0 libsdl2-mixer-dev \
libsdl2-net-2.0-0 libsdl2-net-dev libsdl2-ttf-dev docker.io \
google-earth-pro-stable \
ffmpeg \
KiCad \
siril"

function notify_u ()
{
  n=$(whereis notify-send)
  n=${n##*[[.colon.]]}

  if [[ ! -z ${n} ]]
  then
    notify-send --app-name="$0" "$*"
  else
    echo -e "$*\n"
  fi
}

echo -e "Trying to install programs list: ${progslist}\n"

# main app
sudo apt-get install -f -y ${progslist}

notify_u "End of installation of programs"
