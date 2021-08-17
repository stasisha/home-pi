#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

apt install netfilter-persistent
docker run --name raspap -it -d --restart unless-stopped --privileged --network=host -v /sys/fs/cgroup:/sys/fs/cgroup:ro --cap-add SYS_ADMIN jrcichra/raspap-docker
docker exec -it raspap bash ./setup.sh

curl -K "https://raw.githubusercontent.com/stasisha/home-pi/main/startup-rasp-ap.sh" -o "/etc/init.d/startup-rasp-ap.sh"
chmod +x /etc/init.d/startup-rasp-ap.sh
ln -s /etc/init.d/startup-rasp-ap.sh /etc/rc3.d/startup-rasp-ap
sh ./etc/init.d/startup-rasp-ap.sh

docker restart raspap
