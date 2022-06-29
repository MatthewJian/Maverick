#!/bin/bash
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

start_menu(){
	green " 1.安装BBR内核"
	green " 2.安装Trojan"
	green " 3.更改伪装站点"
    read -p "请选择：" num
    case "$num" in
		1)
		kernel_install	
		;;
		2)
		trojan_install		
		;;
		3)
		change_fakewebsite
		;;
		*)
		start_menu
		;;
    esac
}

kernel_install(){
    bash <(curl -Lso- https://git.io/kernel.sh)
}

trojan_install(){
    wget -N --no-check-certificate https://raw.githubusercontent.com/atrandys/trojan/master/trojan_mult.sh && chmod +x trojan_mult.sh && ./trojan_mult.sh
}

change_fakewebsite(){
	green "开始······" 
	rm -rf /usr/share/nginx/html/*
	cd /usr/share/nginx/html/
	wget https://raw.githubusercontent.com/AllenCrecoe/Backup_of_Hexo/main/index.html
	sleep 1s
	systemctl daemon-reload
	systemctl restart trojan-web
	systemctl restart nginx	
	green "完成！" 
}

start_menu