#!/bin/bash
## add required functions
source /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/stasisha/bash-utils/master/file-edit.sh)";
source /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/stasisha/bash-utils/master/error.sh)";
source /dev/stdin <<< /etc/os-release;

if [[ "$ID" == "raspbian"* ]]; then
    #fix broken http://fastmirror.pp.ua
    #https://www.raspbian.org/RaspbianMirrors
    local sourcesList="${brewPrefix}/dnsmasq.d"
    mv "${sourcesList}" "${sourcesList}.original.bk"
    touch "/etc/apt/sources.list"
    addLineIfNotExists "deb http://mirror.ox.ac.uk/sites/archive.raspbian.org/archive/raspbian buster main contrib non-free rpi" "${dnsmasqD}/${domainSufix}.conf"
#TODO chech condition debian
elif [[ "$OSTYPE" == "debian"* ]]; then
    #placeholder
    echo "debian os";
else
    echoError "Unsupported OS";
    return 1
fi

apt-get update && apt-get upgrade

#Docker
bash -c "$(curl -fsSL https://get.docker.com)"
sudo usermod -aG docker pi
