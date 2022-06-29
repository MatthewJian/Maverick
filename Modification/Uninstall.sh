#!/bin/bash
systemctl stop nginx
systemctl disable nginx
apt-get remove nginx nginx-common
apt-get purge nginx nginx-common
apt-get autoremove
apt-get remove nginx-full nginx-common
bash <(curl -sL https://git.io/trojan-install) --remove
