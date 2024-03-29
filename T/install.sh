#!/bin/bash
start_menu(){
	echo -e "\033[32m\033[01m1.Install kernel\033[0m"
	echo -e "\033[32m\033[01m2.Install trojan\033[0m"
	echo -e "\033[32m\033[01m4.Add websocket for trojan-go\033[0m"
	read -p $'\033[34m\033[01mPlease choose an option: \033[0m' option
    case "$option" in
		1)
		kernel_install	
		;;
		2)
		trojan_install		
		;;
		3)
		add_websocket
		;;
		*)
		start_menu
		;;
    esac
}

kernel_install(){
	echo "bash <(curl -Lso- https://git.io/kernel.sh)"
	bash <(curl -Lso- https://git.io/kernel.sh)
}

trojan_install(){
	echo "bash <(curl -sL https://git.io/trojan-install)"
	bash <(curl -sL https://git.io/trojan-install)
}

add_websocket(){
	echo -e "\033[32mPlease enter a domain name：\033[0m"
	read domainname
	sed -i '44,51d' /usr/local/etc/trojan/config.json
	cat >> /usr/local/etc/trojan/config.json << EOF
  },
  "websocket": {
    "enabled": true,
    "path": "/WEBSOCKET/TROJAN",
    "host": "$domainname"
  }
}
EOF
	apt install -y nginx
	sed -i '/ExecStart/s/trojan web/trojan web -p 4096/g' /etc/systemd/system/trojan-web.service
	systemctl daemon-reload
	systemctl restart trojan-web
	systemctl restart nginx
	sleep 1s
}

start_menu