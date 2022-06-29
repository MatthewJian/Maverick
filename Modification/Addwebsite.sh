#!/bin/bash
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

add_fakewebsite(){
	green "开始添加伪装站点······"
	apt install -y nginx && apt install -y unzip
	systemctl enable nginx
	rm -rf /var/www/html/*
	cd /var/www/html
	wget https://github.com/AllenCrecoe/AllenCrecoe.github.io/archive/refs/heads/main.zip
	unzip main.zip
	mv AllenCrecoe.github.io-main/* /var/www/html
	rm -rf AllenCrecoe.github.io-main && rm main.zip
	sed -i '/ExecStart/s/trojan web/trojan web -p 4096/g' /etc/systemd/system/trojan-web.service
	systemctl daemon-reload
	systemctl restart trojan-web
	systemctl restart nginx
	green "添加完成！控制面板在4096端口。" 
}

add_fakewebsite
