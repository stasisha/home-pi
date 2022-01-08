#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

apt install -y --no-install-recommends pulseaudio pulseaudio-module-bluetooth bluez-tools


echo "Installing PulseAudio"
usermod -a -G pulse-access root
usermod -a -G bluetooth pulse
mv /etc/pulse/client.conf /etc/pulse/client.conf.original
cat <<'EOF' >> /etc/pulse/client.conf
autospawn = no
EOF

# PulseAudio system daemon
cat <<'EOF' > /etc/systemd/system/pulseaudio.service
[Unit]
Description=Sound Service
[Install]
WantedBy=multi-user.target
[Service]
Type=notify
PrivateTmp=true
ExecStart=/usr/bin/pulseaudio --daemonize=no --system --disallow-exit --disable-shm --exit-idle-time=-1 --log-target=journal
Restart=on-failure
EOF
systemctl enable --now pulseaudio.service

# Disable user-level PulseAudio service
systemctl --global mask pulseaudio.socket

# Bluetooth settings
mv /etc/bluetooth/main.conf /etc/bluetooth/main.conf.original
cat <<'EOF' > /etc/bluetooth/main.conf
[General]
Class = 0x200414
DiscoverableTimeout = 0
[Policy]
AutoEnable=true
EOF

# Password/Pin file
cat <<'EOF' > /etc/bluetooth/pin.conf
* 1234
EOF

chown root:root /etc/bluetooth/pin.conf
chmod 600 /etc/bluetooth/pin.conf



# Make Bluetooth discoverable after initialisation
mkdir -p /etc/systemd/system/bthelper@.service.d
cat <<'EOF' > /etc/systemd/system/bthelper@.service.d/override.conf
[Service]
Type=oneshot
EOF

cat <<'EOF' > /etc/systemd/system/bt-agent@.service
[Unit]
Description=Bluetooth Agent
Requires=bluetooth.service
After=bluetooth.service
[Service]
ExecStartPre=/usr/bin/bluetoothctl discoverable on
ExecStartPre=/bin/hciconfig %I piscan
ExecStartPre=/bin/hciconfig %I sspmode 1
ExecStart=/usr/bin/bt-agent --capability=NoInputNoOutput --pin /etc/bluetooth/pin.conf
RestartSec=5
Restart=always
KillSignal=SIGUSR1
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable bt-agent@hci0.service

usermod -a -G bluetooth pulse

# PulseAudio settings
#sed -i.orig 's/^load-module module-udev-detect$/load-module module-udev-detect tsched=0/' /etc/pulse/system.pa
echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa
echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa

# Bluetooth udev script
cat <<'EOF' > /usr/local/bin/bluetooth-udev
#!/bin/bash
if [[ ! $NAME =~ ^\"([0-9A-F]{2}[:-]){5}([0-9A-F]{2})\"$ ]]; then exit 0; fi
action=$(expr "$ACTION" : "\([a-zA-Z]\+\).*")
if [ "$action" = "add" ]; then
    bluetoothctl discoverable off
    # disconnect wifi to prevent dropouts
    #ifconfig wlan0 down &
fi
if [ "$action" = "remove" ]; then
    # reenable wifi
    #ifconfig wlan0 up &
    bluetoothctl discoverable on
fi
EOF
chmod 755 /usr/local/bin/bluetooth-udev

cat <<'EOF' > /etc/udev/rules.d/99-bluetooth-udev.rules
SUBSYSTEM=="input", GROUP="input", MODE="0660"
KERNEL=="input[0-9]*", RUN+="/usr/local/bin/bluetooth-udev"
EOF
