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

curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list

apt update
apt install -y curl nginx cloudflare-warp
curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
bash install-release.sh

if [[ -z "$1" ]]; then
	echo -e "\033[1m\033[31mError: no input provided.\033[0m"
	exit 1
fi
commonname=$(printf '%q' "$1")
v2rayuuid=$(cat /proc/sys/kernel/random/uuid)
numbers=(11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97)
websocketaddress="${numbers[$RANDOM % ${#numbers[@]}]}.${numbers[$RANDOM % ${#numbers[@]}]}"

mkdir -p /etc/nginx/ssl
openssl genrsa -out /etc/nginx/ssl/private.key 2048
chmod 600 /etc/nginx/ssl/private.key
openssl req -new -key /etc/nginx/ssl/private.key -out /etc/nginx/ssl/certificate.csr -subj "/CN=${commonname}"
openssl x509 -req -days 2000 -in /etc/nginx/ssl/certificate.csr -signkey /etc/nginx/ssl/private.key -out /etc/nginx/ssl/certificate.crt
rm /etc/nginx/ssl/certificate.csr

warp-cli register
warp-cli set-mode proxy
warp-cli connect

cat > /usr/local/etc/v2ray/config.json << EOF
{
  "routing": {
    "rules": [
      {
        "type": "field",
        "outboundTag": "WARP",
        "domain": [
          "geosite:netflix",
          "geosite:disney",
          "domain:openai.com",
          "domain:ai.com",
          "domain:scholar.google.com"
        ]
      }
    ]
  },
  "inbounds": [
    {
      "port": 8389,
      "listen":"127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$v2rayuuid",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "/WS-VMESS/$websocketaddress"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "WARP",
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "address": "127.0.0.1",
            "port": 40000
          }
        ]
      }
    }
  ]
}
EOF

cat > /etc/nginx/sites-enabled/default << EOF
server {
	listen 80;
	listen [::]:80;
	server_name $commonname;

	return 301 https://${commonname}\$request_uri;
	add_header Cache-Control "no-cache, no-store, must-revalidate";
}

server {
	listen 443 ssl backlog=65535;
	listen [::]:443 ssl backlog=65535;
	server_name $commonname;

	root /var/www/html;
	index index.html index.htm index.nginx-debian.html;
	
	ssl_certificate /etc/nginx/ssl/certificate.crt;
	ssl_certificate_key /etc/nginx/ssl/private.key;
	ssl_protocols TLSv1.1 TLSv1.2;
	ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305;
	ssl_prefer_server_ciphers on;
	ssl_session_timeout 1d;
	ssl_session_cache shared:SSL:30m;
	ssl_session_tickets off;
    
	location /WS-VMESS/$websocketaddress {
		if (\$http_upgrade != "websocket") {
			 return 404;
		}
		proxy_pass http://127.0.0.1:8389;
		proxy_http_version 1.1;
		proxy_set_header Connection "upgrade";
		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header Host \$http_host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		}
}
EOF

echo -e "Nginx will restart in \033[42m 3 \033[0m seconds."
for i in 2 1 0; do
	echo -en "\rNginx restarting in \033[42m $i \033[0m s,"
	sleep 1s
done
echo ""
echo "Nginx restarting now!"
systemctl start v2ray
systemctl enable v2ray
systemctl restart nginx.service
sleep 1s

currentsshport=$(grep -oP '(?<=Port )\d+' /etc/ssh/sshd_config)

apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ${currentsshport}
ufw allow 80
ufw allow 443
ufw enable

sed -i 's/^#MaxSessions 10$/MaxSessions 2/' /etc/ssh/sshd_config
sed -i 's/^#MaxAuthTries 6$/MaxAuthTries 2/' /etc/ssh/sshd_config

echo -e "The uuid of vmess is: \033[42m $v2rayuuid \033[0m"
echo -e "The address of websocket is: \033[42m /WS-VMESS/${websocketaddress} \033[0m"