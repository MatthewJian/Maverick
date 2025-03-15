#!/bin/bash

# 進度條函數
progress_bar() {
    local progress=$1  # 進度百分比
    local width=20     # 進度條寬度
    local filled=$((width * progress / 100))  # 已填充的部分
    local empty=$((width - filled))           # 未填充的部分
    printf "\rProgress: ["
    printf "\033[32m%${filled}s\033[0m" | tr ' ' '#'
    printf "%${empty}s" | tr ' ' '-'
    printf "] %d%%" "$progress"
    if [ "$progress" -eq 100 ]; then
        echo ""  # 完成時換行
    fi
}

# 顯示提示訊息，告知腳本將於 3 秒後開始運行，並使用綠色背景高亮數字 3
echo -e "This script will run in \033[42m 3 \033[0m seconds."
sleep 1s  # 等待 1 秒
# 倒數計時從 2 到 0，每秒更新顯示，使用綠色背景高亮倒數數字
for i in 2 1 0; do
    echo -en "\rRunning in \033[42m $i \033[0m s,"
    sleep 1s  # 每顯示一次等待 1 秒
done
echo ""  # 換行

# 將網絡優化參數追加到 /etc/sysctl.conf 文件
cat >> /etc/sysctl.conf << EOF
# 設置默認隊列規則為 cake，提升網絡性能
net.core.default_qdisc = cake
# 使用 BBR 擁塞控制算法，優化 TCP 性能
net.ipv4.tcp_congestion_control = bbr
# 忽略所有 ICMP 回顯請求（ping），增強安全性
net.ipv4.icmp_echo_ignore_all = 1
EOF
# 應用 sysctl 配置，並將輸出重定向到 /dev/null 以保持簡潔
sysctl -p >/dev/null

# 將第一個參數（Shadowsocks 密碼）轉義並儲存到變量
shadowsockspassword=$(printf '%q' "$1")
# 將第二個參數（Shadowsocks 端口）轉義並儲存到變量
shadowsocksport=$(printf '%q' "$2")
progress_bar 30  # 完成 30%

# 更新軟件包列表並安裝 Shadowsocks-libev 和 UFW 防火牆
apt update >/dev/null 2>&1 && apt install -y shadowsocks-libev ufw >/dev/null 2>&1
progress_bar 70  # 完成 70%

# 創建 Shadowsocks 配置文件，設定服務器參數
cat > /etc/shadowsocks-libev/config.json << EOF
{
    "server":"0.0.0.0",
    "mode":"tcp_and_udp",
    "server_port":$shadowsocksport,
    "local_port":1080,
    "password":"SS-WS-2017@$shadowsockspassword!",
    "timeout":86400,
    "method":"aes-128-gcm"
}
EOF
sleep 1s  # 等待 1 秒
progress_bar 80  # 完成 80%

# 啟用並重啟 Shadowsocks 服務，使配置生效
systemctl enable shadowsocks-libev >/dev/null 2>&1 && systemctl restart shadowsocks-libev >/dev/null 2>&1
sleep 1s  # 等待 1 秒以確保服務啟動
progress_bar 90  # 完成 90%

# 在防火牆中開放指定的 Shadowsocks 端口
ufw allow $shadowsocksport >/dev/null 2>&1
# 強制啟用 UFW 防火牆
ufw --force enable >/dev/null 2>&1
sleep 1s  # 等待 1 秒以確保服務啟動
progress_bar 100  # 完成 100%

# 根據 Shadowsocks 服務狀態動態設置顏色：active 為綠色，其他為紅色
status=$(systemctl status shadowsocks-libev | grep -oP '(?<=Active: ).*(?= since)')
if [[ "$status" =~ ^active ]]; then
    echo -e "Shadowsocks status: \033[1;32m$status\033[0m"  # 綠色
else
    echo -e "Shadowsocks status: \033[1;31m$status\033[0m"  # 紅色
    echo -e "\033[1;31mError: Shadowsocks is not active. System will not restart.\033[0m"
    exit 1  # 退出腳本，不執行後續重啟
fi

# 只有當 Shadowsocks 狀態為 active 時才執行以下重啟步驟
# 顯示提示訊息，告知系統將於 3 秒後重啟，並使用紅色背景高亮數字 3
echo -e "The script has finished running and the system will restart in \033[41m 3 \033[0m seconds."
# 倒數計時從 2 到 0，每秒更新顯示，使用紅色背景高亮倒數數字
for i in 2 1 0; do
    echo -en "\rSystem restarting in \033[41m $i \033[0m s,"
    sleep 1s  # 每顯示一次等待 1 秒
done
echo ""  # 換行
# 顯示最終重啟提示
echo "System restarting now!"
# 重啟系統
reboot
