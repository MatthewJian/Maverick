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

dokodemodoorport=$(printf '%q' "$1")
commonname=$(printf '%q' "$2")
shadowsocksport=$(printf '%q' "$3")

wget https://github.com/v2fly/v2ray-core/releases/download/v5.8.0/v2ray-linux-64.zip && wget https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh && bash install-release.sh --local v2ray-linux-64.zip

cat > /usr/local/etc/v2ray/config.json << EOF
{
	"inbounds": [
		{
			"listen": "0.0.0.0",
			"port": $dokodemodoorport,
			"protocol": "dokodemo-door",
			"settings": {
				"address": "$commonname",
				"port": $shadowsocksport,
				"network": "tcp,udp"
			}
		}
	],
	"outbounds": [
		{
			"protocol": "freedom",
			"settings": {},
			"tag": "direct"
		},
		{
			"protocol": "blackhole",
			"settings": {},
			"tag": "block"
		}
	],
	"routing": {
		"domainStrategy": "IPOnDemand",
		"strategy": "rules",
		"rules": [
			{
				"type": "field",
				"ip": [
					"geoip:private",
					"geoip:cn"
				],
				"outboundTag": "block"
			},
			{
				"type": "field",
				"network": "tcp,udp",
				"outboundTag": "direct"
			}
		]
	}
}
EOF

systemctl enable v2ray && systemctl start v2ray && systemctl daemon-reload && systemctl status v2ray

echo -e "The script has finished running and the system will restart in \033[41m 3 \033[0m seconds."
for i in 2 1 0; do
	echo -en "\rSystem restarting in \033[41m $i \033[0m s,"
	sleep 1s
done
echo ""
echo "System restarting now!"
reboot
