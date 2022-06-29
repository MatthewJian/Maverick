#!/bin/bash
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

start_menu(){
	green " 1.安装BBR内核"
	green " 2.安装Trojan-web"
	green " 3.添加伪装站点"
	red " 4.卸载"
    read -p "请选择：" num
    case "$num" in
		1)
		kernel_install	
		;;
		2)
		trojan_install		
		;;
		3)
		add_fakewebsite
		;;
		4)
		uninstall
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
    bash <(curl -sL https://git.io/trojan-install)
}

add_fakewebsite(){
    bash <(curl -Lso- https://raw.githubusercontent.com/MatthewJian/Maverick/main/Modification/Addwebsite.sh)
}

uninstall(){
    bash <(curl -Lso- https://raw.githubusercontent.com/MatthewJian/Maverick/main/Modification/Uninstall.sh)
}

start_menu