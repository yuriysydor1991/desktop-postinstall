
#!/bin/bash
 
# ctags pgadmin3
progslist="gcc g++ make unrar nmap traceroute libpcap-dev cppcheck valgrind mc automake \
autoconf autoconf-doc  fdupes mesa-common-dev libglew-dev libglm-dev hydrogen \
tuxguitar tuxguitar-alsa jackd audacious audacity mplayer gimp qbittorrent conky \
wine-stable timidity tuxguitar-jsa virtualbox virtualbox-guest-additions-iso \
virtualbox-guest-additions-iso pavucontrol brasero filezilla \
mypaint htop virtualbox-qt whois gtk+-3.0 libsdl2-dev libpq-dev postgresql-client-common \
postgresql dconf-editor ddd libcurl4-openssl-dev vlc"

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

