#!/bin/bash
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

start_menu(){
	green " 1.安装BBR内核"
	green " 2.安装X-UI"
    read -p "请选择：" num
    case "$num" in
		1)
		kernel_install	
		;;
		2)
		trojan_install		
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
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
}

start_menu