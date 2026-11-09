#!/bin/bash

# The flatpak flavour of the desktop-postinstall.sh: the desktop applications
# are installed from the Flathub instead of the OS repository. The tool
# chains, development libraries, command line tools and system services have
# no flatpak counterparts, so they are still installed with apt-get, as are
# the few applications missing on the Flathub.

# ctags pgadmin3
progslist=(
# compilers, build systems and the autotools
build-essential gcc g++ make cmake meson
automake autoconf autoconf-doc pkg-config

# version control
git git-lfs

# static analysis, debugging and profiling (kcachegrind is a flatpak, ddd is
# not available on the Flathub)
cppcheck clang-tidy valgrind ddd

# unit testing frameworks
libgtest-dev libgmock-dev

# documentation and API browsing (the devhelp flatpak is end-of-life)
doxygen graphviz devhelp

# general purpose C/C++ development libraries
libboost-all-dev libcurl4-openssl-dev libpcap-dev

# json dev lib
nlohmann-json3-dev

# DBus dev
libsdbus-c++-dev libsdbus-c++-doc

# GTK / gtkmm development
gtk+-3.0 libgtkmm-3.0-dev libgtkmm-3.0-doc libgtkmm-4.0-dev

# flatpak packager, the flatpak itself is required by the flatpaklist below
flatpak flatpak-builder

# Qt development. The qtcreator stays a native package: its flatpak builds
# with its own sandboxed SDK and cannot use the host compilers and the Qt
# packages below. The Qt linguist is a flatpak
qtcreator qt5-qmake qt5-doc qdbus-qt5 qt5serialport-examples
libqt5xml5 libqt5quick5 libqt5qml5

qt6-base-dev qt6-base-dev-tools
qt6-declarative-dev qt6-tools-dev qt6-tools-dev-tools
qml6-module-qtquick qml6-module-qtqml-workerscript
qml6-module-qtquick-templates qml6-module-qtquick-window
qtquickcontrols2-5-dev libqt6gui6 qml-module-qtquick2
qml-module-qtquick-controls2 qml-module-qtquick-dialogs
qml-module-qtquick-layouts qml-module-qtquick-shapes
libqt6quick6 libqt6quickcontrols2-6 libqt6opengl6-dev
libqt6openglwidgets6 qt6-webview-dev qml6-module-qtwebview
qt6-webengine-dev libqt6webenginecore6 qt6-webengine-dev-tools
qml6-module-qtquick-controls
qt6-webview-dev qml6-module-qtwebview
qt6-webengine-dev libqt6webenginecore6 qt6-webengine-dev-tools

# OpenGL / 3D development
mesa-common-dev libglew-dev libglm-dev freeglut3-dev

# SDL2 development
libsdl2-dev libsdl2-doc
libsdl2-image-2.0-0 libsdl2-image-dev
libsdl2-mixer-2.0-0 libsdl2-mixer-dev
libsdl2-net-2.0-0 libsdl2-net-dev
libsdl2-ttf-dev

# SDL3
libsdl3-dev libsdl3-image-dev libsdl3-ttf-dev libgl1-mesa-dev

# databases
postgresql postgresql-client-common libpq-dev

# servers and containers
apache2 docker.io

# shell and file system utilities
mc htop btop fdupes unrar

# network tools
curl wget nmap traceroute whois nettop

# audio and video tools and development (mplayer is not available on the
# Flathub, the players and editors are flatpaks)
mplayer mplayer-gui mplayer-skins ffmpeg
libgstreamerd-3-dev libgstreamermm-1.0-dev libgstreamer1.0-dev

# audio production and MIDI
jackd timidity

# GIMP plug-in development documentation
libgimp2.0-doc

# udev rules for the Steam controllers and VR headsets, the Steam flatpak
# relies on the host for them (multiverse)
steam-devices

# qemu VM and emulation
qemu-system-arm qemu-system qemu-system-gui
qemu-system-common qemu-system-x86 qemu-efi-aarch64
qemu-utils qemu-user qemu-user-binfmt ovmf qemu-system-misc 

# plotting 
gnuplot

# computer vision and image manip
libopencv-dev libopencv-dnn-dev libopencv-imgcodecs-dev
libopencv-imgproc-dev opencv-data opencv-doc

# FS management (gparted needs a raw access to the disks, it is not available
# on the Flathub)
gparted
)

# the applications installed from the Flathub
flatpaklist=(
# profiling
org.kde.kcachegrind

# Qt translations editor
io.qt.Linguist

# audio and video players / editors
org.atheme.audacious org.audacityteam.Audacity org.videolan.VLC

# audio production and MIDI
org.hydrogenmusic.Hydrogen org.pulseaudio.pavucontrol ar.com.tuxguitar.TuxGuitar

# raster graphics and image editing. The Flathub GIMP is the GIMP 3: the
# gimp-plugin-registry, gimp-data-extras, gimp-gap, gimp-lensfun,
# gimp-texturize and gtkam-gimp add-ons have no flatpaks for it and their apt
# packages would pull in the native GIMP, so they are left out
org.gimp.GIMP org.mypaint.MyPaint

# vector graphics
org.inkscape.Inkscape

# photo and astrophotography processing
org.darktable.Darktable com.rawtherapee.RawTherapee org.siril.Siril

# electronics design automation
org.kicad.KiCad

# desktop applications
org.qbittorrent.qBittorrent org.filezillaproject.Filezilla org.gnome.Brasero
com.google.EarthPro ca.desrt.dconf-editor

# windows compatibility layer, the Flathub publishes it in several branches,
# so one has to be picked
org.winehq.Wine//stable

# messengers
com.viber.Viber com.discordapp.Discord

# music streaming
com.spotify.Client

# gaming
com.valvesoftware.Steam

# flatpak-builder runtimes and SDKs
runtime/org.freedesktop.Platform/x86_64/24.08
runtime/org.freedesktop.Sdk/x86_64/24.08
runtime/org.kde.Platform/x86_64/6.8
runtime/org.kde.Sdk/x86_64/6.8
)

# names of the packages that apt-get refused to install
failedlist=()

# names of the flatpaks that failed to install
failedflatpaks=()

# the docker daemon TCP socket, bound to the loopback interface only. Keep in
# mind that the socket is unauthenticated, so every local user and every
# process of the machine gets a root equivalent access to the docker daemon
# through it
docker_tcp_addr="127.0.0.1:2375"
docker_dropin_dir="/etc/systemd/system/docker.service.d"
docker_dropin="${docker_dropin_dir}/tcp-socket.conf"
docker_default_execstart="ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock"


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

# makes the docker daemon listen on the ${docker_tcp_addr} TCP socket in
# addition to its default unix one
function configure_docker_tcp ()
{
  local fragment=""
  local execstart=""
  local try=0

  if ! command -v dockerd &> /dev/null
  then
    echo -e "\nWARNING: the dockerd is not installed, skipping the TCP socket configuration\n" >&2
    return 1
  fi

  # the ExecStart of the packaged unit only, the drop-ins are not listed here,
  # so the command line is never extended twice
  fragment=$(systemctl show -p FragmentPath --value docker.service 2> /dev/null)

  if [[ -r ${fragment} ]]
  then
    execstart=$(grep -m1 '^ExecStart=' "${fragment}")
  fi

  if [[ -z ${execstart} ]]
  then
    echo -e "\nWARNING: cannot read the ExecStart of the docker.service, falling back to the default one\n" >&2
    execstart=${docker_default_execstart}
  fi

  if [[ ${execstart} == *"tcp://"* ]]
  then
    echo -e "\nThe docker.service already listens on a TCP socket, leaving it as is\n"
    return 0
  fi

  if ! sudo mkdir -p "${docker_dropin_dir}"
  then
    echo -e "\nWARNING: failed to create the ${docker_dropin_dir} directory\n" >&2
    return 1
  fi

  # the empty ExecStart= resets the list inherited from the unit file, the
  # second one replaces it with the extended command line
  if ! printf '%s\n' \
         "[Service]" \
         "ExecStart=" \
         "${execstart} -H tcp://${docker_tcp_addr}" \
       | sudo tee "${docker_dropin}" > /dev/null
  then
    echo -e "\nWARNING: failed to write the ${docker_dropin} file\n" >&2
    return 1
  fi

  sudo systemctl daemon-reload

  if ! sudo systemctl restart docker.service
  then
    echo -e "\nWARNING: failed to restart the docker.service with the TCP socket enabled\n" >&2
    return 1
  fi

  # the daemon needs a moment before it starts to answer
  for try in {1..10}
  do
    if curl -fsS -m 2 "http://${docker_tcp_addr}/_ping" > /dev/null 2>&1
    then
      echo -e "\nThe docker daemon is listening on the ${docker_tcp_addr}"
      echo -e "Use it with: export DOCKER_HOST=tcp://${docker_tcp_addr}\n"
      return 0
    fi

    sleep 1
  done

  echo -e "\nWARNING: the docker daemon does not answer on the ${docker_tcp_addr}\n" >&2

  return 1
}

# prints the result of one of the installation steps
# $1 - what was installed, $2 - the number of the items tried to install,
# $3... - the items that failed to install
function print_summary ()
{
  local what="$1"
  local total="$2"
  local item=""

  shift 2

  if [[ $# -eq 0 ]]
  then
    echo -e "\nAll the ${total} ${what} were installed successfully\n"
  else
    echo -e "\nWARNING: $# of ${total} ${what} failed to install:\n" >&2

    for item in "$@"
    do
      echo -e "\t${item}" >&2
    done

    echo ""
  fi
}

sudo apt update
sudo apt upgrade -y

echo -e "Trying to install ${#progslist[@]} programs: ${progslist[*]}\n"

# main app: install one by one, so a single broken package does not
# abort the installation of all the remaining ones
for prog in "${progslist[@]}"
do
  echo -e "\n=== Installing ${prog} ===\n"

  if ! sudo apt-get install -f -y "${prog}"
  then
    echo -e "\nWARNING: failed to install the package '${prog}'\n" >&2
    failedlist+=("${prog}")
  fi
done

#
# manual commands
#

# the docker daemon local TCP socket
if ! configure_docker_tcp
then
  notify_u "Failed to configure the docker TCP socket on the ${docker_tcp_addr}"
fi

# flatpak related, the flatpak itself was installed by the apt-get above
if ! command -v flatpak &> /dev/null
then
  echo -e "\nERROR: the flatpak is not installed, cannot install the ${#flatpaklist[@]} flatpaks\n" >&2
  failedflatpaks=("${flatpaklist[@]}")
elif ! flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
then
  echo -e "\nERROR: failed to add the flathub remote, cannot install the ${#flatpaklist[@]} flatpaks\n" >&2
  failedflatpaks=("${flatpaklist[@]}")
else
  echo -e "\nTrying to install ${#flatpaklist[@]} flatpaks: ${flatpaklist[*]}\n"

  # one by one as well, so a single broken flatpak does not abort the
  # installation of all the remaining ones
  for app in "${flatpaklist[@]}"
  do
    echo -e "\n=== Installing ${app} ===\n"

    if ! flatpak install -y flathub "${app}"
    then
      echo -e "\nWARNING: failed to install the flatpak '${app}'\n" >&2
      failedflatpaks+=("${app}")
    fi
  done
fi

print_summary "packages" "${#progslist[@]}" "${failedlist[@]}"
print_summary "flatpaks" "${#flatpaklist[@]}" "${failedflatpaks[@]}"

# a freshly installed flatpak adds its applications to the XDG_DATA_DIRS of
# the new sessions only
echo -e "Log out and back in (or reboot) if the flatpak applications are missing from the applications menu\n"

summary="End of installation of programs"

if [[ ${#failedlist[@]} -ne 0 ]]
then
  summary+=". Failed to install ${#failedlist[@]} package(s): ${failedlist[*]}"
fi

if [[ ${#failedflatpaks[@]} -ne 0 ]]
then
  summary+=". Failed to install ${#failedflatpaks[@]} flatpak(s): ${failedflatpaks[*]}"
fi

notify_u "${summary}"
