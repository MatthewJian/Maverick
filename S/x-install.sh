#!/bin/bash
echo -e "This script will run in \033[42m 3 \033[0m seconds."
sleep 1s
for i in 2 1 0; do
	echo -en "\rRunning in \033[42m $i \033[0m s,"
	sleep 1s
done

cat >> /etc/sysctl.conf << EOF
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr

net.ipv4.icmp_echo_ignore_all = 1
EOF
sysctl -p

shadowsockspassword=$(printf '%q' "$1")
shadowsocksport=$(printf '%q' "$2")

apt update && apt install -y shadowsocks-libev ufw

cat > /etc/shadowsocks-libev/config.json << EOF
{
	"server":"0.0.0.0",
	"mode":"tcp_and_udp",
	"server_port":$shadowsocksport,
	"local_port":1080,
	"password":"SS-WS-2017@$shadowsockspassword!",
	"timeout":86400,
	"method":"aes-128-gcm",
}
EOF

systemctl enable shadowsocks-libev && systemctl restart shadowsocks-libev
sleep 1s

ufw allow $shadowsocksport
ufw --force enable

sleep 1s
systemctl status shadowsocks-libev

echo -e "The script has finished running and the system will restart in \033[41m 3 \033[0m seconds."
for i in 2 1 0; do
	echo -en "\rSystem restarting in \033[41m $i \033[0m s,"
	sleep 1s
done
echo ""
echo "System restarting now!"
reboot
