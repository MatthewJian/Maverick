#!/bin/bash
echo -e "This script will run in \033[42m 3 \033[0m seconds."
sleep 1s
for i in 2 1 0; do
	echo -en "\rRunning in \033[42m $i \033[0m s,"
	sleep 1s
done
echo ""
echo "Running now!"

sleep 1s

apt update
apt install -y shadowsocks-libev 

numbers=(11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97)
shadowsockspassword="${numbers[$RANDOM % ${#numbers[@]}]}.${numbers[$RANDOM % ${#numbers[@]}]}.${numbers[$RANDOM % ${#numbers[@]}]}"
shadowsocksport=$((RANDOM % 20000 + 20001))

cat > /etc/shadowsocks-libev/config.json << EOF
{
	"server":"0.0.0.0",
	"mode":"tcp_and_udp",
	"server_port":$shadowsocksport,
	"local_port":1080,
	"password":"SS-IPLC-2017@$shadowsockspassword!",
	"timeout":86400,
	"method":"aes-128-gcm",
}
EOF

systemctl start shadowsocks-libev
systemctl enable shadowsocks-libev

cat >> /etc/sysctl.conf << EOF
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr

fs.file-max = 2097152

net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1

net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2

net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fin_timeout = 15

net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1

net.ipv4.tcp_window_scaling = 1

net.ipv4.tcp_fastopen = 3

net.ipv4.tcp_max_syn_backlog = 32768

vm.overcommit_memory = 0
vm.oom_kill_allocating_task = 1

net.ipv4.icmp_echo_ignore_all = 1
EOF
sysctl -p

cat >> /etc/security/limits.conf << EOF
*	soft	noproc	65535
*	hard	noproc	65535
*	soft	nofile	65535
*	hard	nofile	65535
EOF

echo "ulimit -SHn 65535" >> /etc/profile
source /etc/profile

currentip=$(who -u | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
currentsshport=$(grep -oP '(?<=Port )\d+' /etc/ssh/sshd_config)
newsshport=$((RANDOM % 20000 + 40001))

sed -i "s/^#\?Port $currentsshport$/Port $newsshport/" /etc/ssh/sshd_config
sed -i "s/^#MaxSessions 10$/MaxSessions 2/" /etc/ssh/sshd_config
sed -i "s/^#MaxAuthTries 6$/MaxAuthTries 2/" /etc/ssh/sshd_config

apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow $shadowsocksport
ufw enable

echo -e "The new port of ssh is: \033[42m $newsshport \033[0m"
echo -e "The new port of shadowsocks-libev is: \033[42m $shadowsocksport \033[0m"
echo -e "The password of shadowsocks-libev is: \033[42m $shadowsockspassword \033[0m"

echo -e "The script has finished running and the system will restart in \033[41m 5 \033[0m seconds."
sleep 1s
for i in 4 3 2 1 0; do
	echo -en "\rSystem restarting in \033[41m $i \033[0m s,"
	sleep 1s
done
echo ""
echo "System restarting now!"
sleep 1s
reboot
