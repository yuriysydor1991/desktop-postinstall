
#!/bin/bash
 
# ctags pgadmin3
progslist=(
# compilers, build systems and the autotools
build-essential gcc g++ make cmake meson
automake autoconf autoconf-doc pkg-config

# version control
git git-lfs

# static analysis, debugging and profiling
cppcheck clang-tidy valgrind kcachegrind ddd

# unit testing frameworks
libgtest-dev libgmock-dev

# documentation and API browsing
doxygen graphviz devhelp

# general purpose C/C++ development libraries
libboost-all-dev libcurl4-openssl-dev libpcap-dev

# json dev lib
nlohmann-json3-dev

# DBus dev
libsdbus-c++-dev libsdbus-c++-doc

# GTK / gtkmm development
gtk+-3.0 libgtkmm-3.0-dev libgtkmm-3.0-doc

# flatpak packager
flatpak flatpak-builder

# Qt development
qtcreator qt5-qmake qt5-doc qdbus-qt5 qt5serialport-examples
libqt5xml5 libqt5quick5 libqt5qml5 linguist-qt6

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

# audio and video players / editors
audacious audacity mplayer mplayer-gui mplayer-skins vlc ffmpeg
libgstreamerd-3-dev libgstreamermm-1.0-dev libgstreamer1.0-dev

# audio production and MIDI
hydrogen jackd timidity pavucontrol
tuxguitar tuxguitar-alsa tuxguitar-jsa

# raster graphics and image editing
gimp gimp-plugin-registry gimp-data-extras gimp-gap gimp-lensfun
gimp-texturize gtkam-gimp libgimp2.0-doc
mypaint

# vector graphics
inkscape

# photo and astrophotography processing
darktable rawtherapee siril

# electronics design automation
kicad

# desktop applications
qbittorrent filezilla brasero google-earth-pro-stable dconf-editor

# windows compatibility layer
wine-stable

# qemu VM and emulation
qemu-system-arm qemu-system qemu-system-gui
qemu-system-common qemu-system-x86 qemu-efi-aarch64
qemu-utils qemu-user qemu-user-binfmt ovmf qemu-system-misc 

# plotting 
gnuplot

# computer vision and image manip
libopencv-dev libopencv-dnn-dev libopencv-imgcodecs-dev
libopencv-imgproc-dev opencv-data opencv-doc

# FS management
gparted
)

# names of the packages that apt-get refused to install
failedlist=()


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

# flatpak related
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y runtime/org.freedesktop.Platform/x86_64/24.08
flatpak install -y runtime/org.freedesktop.Sdk/x86_64/24.08
flatpak install -y runtime/org.kde.Platform/x86_64/6.8
flatpak install -y runtime/org.kde.Sdk/x86_64/6.8

if [[ ${#failedlist[@]} -eq 0 ]]
then
  echo -e "\nAll the ${#progslist[@]} packages were installed successfully\n"
  notify_u "End of installation of programs"
else
  echo -e "\nWARNING: ${#failedlist[@]} of ${#progslist[@]} packages failed to install:\n" >&2

  for prog in "${failedlist[@]}"
  do
    echo -e "\t${prog}" >&2
  done

  echo ""

  notify_u "End of installation of programs. Failed to install ${#failedlist[@]} package(s): ${failedlist[*]}"
fi
