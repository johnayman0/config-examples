#!/bin/bash

legacy() {
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box_Config_Installer/Legacy-Menu.sh)"
    exit 0
}

tui() {
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box_Config_Installer/TUI-Menu.sh)"
    exit 0
}

optimize_server() {
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnayman0/Linux-Optimizer/main/linux-optimizer.sh)"
    clear
}

install_hysteria() {
    Transport="$1"
    user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)

    install_core SH

    mkdir -p /etc/hysteria2

    if [ "$Transport" == "native" ]; then
        curl -Lo /etc/hysteria2/server.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Hysteria2.json
    elif [ "$Transport" == "obfs" ]; then
        curl -Lo /etc/hysteria2/server.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Hysteria2-obfs.json
    fi

    curl -Lo /etc/systemd/system/SH.service https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/SH.service
    systemctl daemon-reload

    get_selfsigned_cert hysteria2

    password=$(openssl rand -hex 8)
    obfspassword=$(openssl rand -hex 8)
    sed -i "s/PORT/$user_port/" /etc/hysteria2/server.json
    sed -i "s/PASSWORD/$password/" /etc/hysteria2/server.json
    sed -i "s/OBFS/$obfspassword/" /etc/hysteria2/server.json
    sed -i "s/NAME/Hysteria2/" /etc/hysteria2/server.json

    public_ipv4=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v4.ident.me)
    public_ipv6=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v6.ident.me)

    set_ufw udp

    systemctl enable --now SH

    (crontab -l 2>/dev/null; echo "0 */5 * * * systemctl restart SH") | crontab -

    if [ "$Transport" == "native" ]; then
        result_url=" 
        ipv4 : hy2://$password@$public_ipv4:$user_port?insecure=1&sni=www.google.com#HY2
        ---------------------------------------------------------------
        ipv6 : hy2://$password@[$public_ipv6]:$user_port?insecure=1&sni=www.google.com#HY2-V6"

        result_url2=" 
        ipv4 : hy2://PASSWORD@$public_ipv4:$user_port?insecure=1&sni=www.google.com#NAME-HY2
        ---------------------------------------------------------------
        ipv6 : hy2://PASSWORD@[$public_ipv6]:$user_port?insecure=1&sni=www.google.com#NAME-HY2-V6"
    elif [ "$Transport" == "obfs" ]; then
        result_url="
        ipv4 : hy2://$password@$public_ipv4:$user_port?obfs=salamander&obfs-password=$obfspassword&insecure=1&sni=www.google.com#HY2
        ---------------------------------------------------------------
        ipv6 : hy2://$password@[$public_ipv6]:$user_port?obfs=salamander&obfs-password=$obfspassword&insecure=1&sni=www.google.com#HY2-V6"

        result_url2=" 
        ipv4 : hy2://PASSWORD@$public_ipv4:$user_port?obfs=salamander&obfs-password=$obfspassword&insecure=1&sni=www.google.com#NAME-HY2
        ---------------------------------------------------------------
        ipv6 : hy2://PASSWORD@[$public_ipv6]:$user_port?obfs=salamander&obfs-password=$obfspassword&insecure=1&sni=www.google.com#NAME-HY2-V6"
    fi

    echo -e "Config URL: $result_url" >/etc/hysteria2/user-config.txt
    echo -e "Config URL: $result_url2" >/etc/hysteria2/config.txt
    echo -e "Config URL: \e[91m$result_url\e[0m"

    ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/hysteria2/user-config.txt)
    ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/hysteria2/user-config.txt)

    echo IPv4:
    qrencode -t ANSIUTF8 <<<"$ipv4qr"

    echo IPv6:
    qrencode -t ANSIUTF8 <<<"$ipv6qr"

    echo "Hysteria2 setup completed."

    echo -e "\e[31mPress Enter to Exit\e[0m"
    read
    clear
}

modify_hysteria_config() {
    Transport="$1"
    user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)

    systemctl stop SH

    rm -rf /etc/hysteria2

    mkdir -p /etc/hysteria2

    if [ "$Transport" == "native" ]; then
        curl -Lo /etc/hysteria2/server.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Hysteria2.json
    elif [ "$Transport" == "obfs" ]; then
        curl -Lo /etc/hysteria2/server.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Hysteria2-obfs.json
    fi

    get_selfsigned_cert hysteria2

    password=$(openssl rand -hex 8)
    obfspassword=$(openssl rand -hex 8)
    sed -i "s/PORT/$user_port/" /etc/hysteria2/server.json
    sed -i "s/PASSWORD/$password/" /etc/hysteria2/server.json
    sed -i "s/OBFS/$obfspassword/" /etc/hysteria2/server.json
    sed -i "s/NAME/Hysteria2/" /etc/hysteria2/server.json

    public_ipv4=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v4.ident.me)
    public_ipv6=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v6.ident.me)

    set_ufw udp

    systemctl start SH

    if [ "$Transport" == "native" ]; then
        result_url=" 
        ipv4 : hy2://$password@$public_ipv4:$user_port?insecure=1&sni=www.google.com#HY2
        ---------------------------------------------------------------
        ipv6 : hy2://$password@[$public_ipv6]:$user_port?insecure=1&sni=www.google.com#HY2-V6"

        result_url2=" 
        ipv4 : hy2://PASSWORD@$public_ipv4:$user_port?insecure=1&sni=www.google.com#NAME-HY2
        ---------------------------------------------------------------
        ipv6 : hy2://PASSWORD@[$public_ipv6]:$user_port?insecure=1&sni=www.google.com#NAME-HY2-V6"
    elif [ "$Transport" == "obfs" ]; then
        result_url="
        ipv4 : hy2://$password@$public_ipv4:$user_port?obfs=salamander&obfs-password=$obfspassword&insecure=1&sni=www.google.com#HY2
        ---------------------------------------------------------------
        ipv6 : hy2://$password@[$public_ipv6]:$user_port?obfs=salamander&obfs-password=$obfspassword&insecure=1&sni=www.google.com#HY2-V6"

        result_url2=" 
        ipv4 : hy2://PASSWORD@$public_ipv4:$user_port?obfs=salamander&obfs-password=$obfspassword&insecure=1&sni=www.google.com#NAME-HY2
        ---------------------------------------------------------------
        ipv6 : hy2://PASSWORD@[$public_ipv6]:$user_port?obfs=salamander&obfs-password=$obfspassword&insecure=1&sni=www.google.com#NAME-HY2-V6"
    fi

    echo -e "Config URL: $result_url" >/etc/hysteria2/user-config.txt
    echo -e "Config URL: $result_url2" >/etc/hysteria2/config.txt
    echo -e "Config URL: \e[91m$result_url\e[0m"

    ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/hysteria2/user-config.txt)
    ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/hysteria2/user-config.txt)

    echo IPv4:
    qrencode -t ANSIUTF8 <<<"$ipv4qr"

    echo IPv6:
    qrencode -t ANSIUTF8 <<<"$ipv6qr"

    echo "Hysteria2 configuration modified."

    echo -e "\e[31mPress Enter to Exit\e[0m"
    read
    clear
}

uninstall_hysteria() {
    systemctl stop SH
    rm -f /usr/bin/SH
    rm -rf /etc/hysteria2
    rm -f /etc/systemd/system/SH.service
    crontab -l | sed '/0 \*\/5 \* \* \* systemctl restart SH/d' | crontab -
    systemctl daemon-reload

    whiptail --msgbox "Hysteria2 uninstalled." 10 30
    clear
}

install_tuic() {
    tuic_check="/etc/tuic/server.json"

    if [ -e "$tuic_check" ]; then
        whiptail --msgbox "TUIC is Already installed " 10 30
        clear
    else
        user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)

        install_core TS

        mkdir -p /etc/tuic

        curl -Lo /etc/tuic/server.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Tuic.json
        curl -Lo /etc/systemd/system/TS.service https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/TS.service
        systemctl daemon-reload

        get_selfsigned_cert tuic

        password=$(openssl rand -hex 8)
        uuid=$(cat /proc/sys/kernel/random/uuid)
        sed -i "s/NAME/Tuic/" /etc/tuic/server.json
        sed -i "s/PORT/$user_port/" /etc/tuic/server.json
        sed -i "s/PASSWORD/$password/" /etc/tuic/server.json
        sed -i "s/UUID/$uuid/" /etc/tuic/server.json

        public_ipv4=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v4.ident.me)
        public_ipv6=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v6.ident.me)

        set_ufw  udp

        systemctl enable --now TS

        (crontab -l 2>/dev/null; echo "0 */5 * * * systemctl restart TS") | crontab -

        result_url=" 
        ipv4 : tuic://$uuid:$password@$public_ipv4:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.google.com&udp_relay_mode=native&allow_insecure=1#TUIC
        ---------------------------------------------------------------
        ipv6 : tuic://$uuid:$password@[$public_ipv6]:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.google.com&udp_relay_mode=native&allow_insecure=1#TUIC-V6"

        result_url2=" 
        ipv4 : tuic://UUID:PASSWORD@$public_ipv4:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.google.com&udp_relay_mode=native&allow_insecure=1#NAME-TUIC
        ---------------------------------------------------------------
        ipv6 : tuic://UUID:PASSWORD@[$public_ipv6]:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.google.com&udp_relay_mode=native&allow_insecure=1#NAME-TUIC-V6"

        echo -e "Config URL: $result_url" >/etc/tuic/user-config.txt
        echo -e "Config URL: $result_url2" >/etc/tuic/config.txt
        echo -e "Config URL: \e[91m$result_url\e[0m"

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/tuic/user-config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/tuic/user-config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

        echo "TUIC setup completed."

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    fi
}

modify_tuic_config() {
    tuic_check="/etc/tuic/server.json"

    if [ -e "$tuic_check" ]; then
        user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)

        systemctl stop TS

        rm -rf /etc/tuic

        mkdir -p /etc/tuic

        curl -Lo /etc/tuic/server.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Tuic.json

        get_selfsigned_cert tuic

        password=$(openssl rand -hex 8)
        uuid=$(cat /proc/sys/kernel/random/uuid)
        sed -i "s/NAME/Tuic/" /etc/tuic/server.json
        sed -i "s/PORT/$user_port/" /etc/tuic/server.json
        sed -i "s/PASSWORD/$password/" /etc/tuic/server.json
        sed -i "s/UUID/$uuid/" /etc/tuic/server.json

        public_ipv4=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v4.ident.me)
        public_ipv6=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v6.ident.me)

        set_ufw udp

        systemctl start TS

        result_url=" 
        ipv4 : tuic://$uuid:$password@$public_ipv4:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.google.com&udp_relay_mode=native&allow_insecure=1#TUIC
        ---------------------------------------------------------------
        ipv6 : tuic://$uuid:$password@[$public_ipv6]:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.google.com&udp_relay_mode=native&allow_insecure=1#TUIC-V6"

        result_url2=" 
        ipv4 : tuic://UUID:PASSWORD@$public_ipv4:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.google.com&udp_relay_mode=native&allow_insecure=1#NAME-TUIC
        ---------------------------------------------------------------
        ipv6 : tuic://UUID:PASSWORD@[$public_ipv6]:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.google.com&udp_relay_mode=native&allow_insecure=1#NAME-TUIC-V6"

        echo -e "Config URL: $result_url" >/etc/tuic/user-config.txt
        echo -e "Config URL: $result_url2" >/etc/tuic/config.txt
        echo -e "Config URL: \e[91m$result_url\e[0m"

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/tuic/user-config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/tuic/user-config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

        echo "TUIC configuration modified."

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    else
        whiptail --msgbox "TUIC is not installed yet." 10 30
        clear
    fi
}

uninstall_tuic() {
    systemctl stop TS
    rm -f /usr/bin/TS
    rm -rf /etc/tuic
    rm -f /etc/systemd/system/TS.service
    crontab -l | sed '/0 \*\/5 \* \* \* systemctl restart TS/d' | crontab -
    systemctl daemon-reload

    whiptail --msgbox "TUIC uninstalled." 10 30
    clear
}

install_reality() {
    Transport="$1"
    user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)
    user_sni=$(whiptail --inputbox "Enter SNI:" 10 30 2>&1 >/dev/tty)

    install_core RS

    mkdir -p /etc/reality

    if [ "$Transport" == "grpc" ]; then
        curl -Lo /etc/reality/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Reality-gRPC.json
    elif [ "$Transport" == "tcp" ]; then
        curl -Lo /etc/reality/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Reality-tcp.json
    fi

    curl -Lo /etc/systemd/system/RS.service https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/RS.service
    systemctl daemon-reload

    uuid=$(cat /proc/sys/kernel/random/uuid)
    short_id=$(openssl rand -hex 8)
    service_name=$(openssl rand -hex 4)
    output=$(RS generate reality-keypair)
    private_key=$(echo "$output" | grep -oP 'PrivateKey: \K\S+')
    public_key=$(echo "$output" | grep -oP 'PublicKey: \K\S+')
    sed -i "s/PORT/$user_port/" /etc/reality/config.json
    sed -i "s/SNI/$user_sni/" /etc/reality/config.json
    sed -i "s/NAME/Reality/" /etc/reality/config.json
    sed -i "s/UUID/$uuid/" /etc/reality/config.json
    sed -i "s/PRIVATE-KEY/$private_key/" /etc/reality/config.json
    sed -i "s/SHORT-ID/$short_id/" /etc/reality/config.json
    sed -i "s/PATH/$service_name/" /etc/reality/config.json

    public_ipv4=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v4.ident.me)
    public_ipv6=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v6.ident.me)

    set_ufw tcp

    systemctl enable --now RS

    (crontab -l 2>/dev/null; echo "0 */5 * * * systemctl restart RS") | crontab -

    if [ "$Transport" == "grpc" ]; then
        result_url=" 
        ipv4 : vless://$uuid@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality
        ---------------------------------------------------------------
        ipv6 : vless://$uuid@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality-V6"

        result_url2=" 
        ipv4 : vless://UUID@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#NAME-Reality
        ---------------------------------------------------------------
        ipv6 : vless://UUID@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#NAME-Reality-V6"
    elif [ "$Transport" == "tcp" ]; then
        result_url="
        ipv4 : vless://$uuid@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=tcp&flow=xtls-rprx-vision&encryption=none#Reality
        ---------------------------------------------------------------
        ipv6 : vless://$uuid@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=tcp&flow=xtls-rprx-vision&encryption=none#Reality-V6"

        result_url2=" 
        ipv4 : vless://UUID@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=tcp&flow=xtls-rprx-vision&encryption=none#NAME-Reality
        ---------------------------------------------------------------
        ipv6 : vless://UUID@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=tcp&flow=xtls-rprx-vision&encryption=none#NAME-Reality-V6"
    fi

    echo -e "Config URL: $result_url" >/etc/reality/user-config.txt
    echo -e "Config URL: $result_url2" >/etc/reality/config.txt
    echo -e "Config URL: \e[91m$result_url\e[0m"

    ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/reality/user-config.txt)
    ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/reality/user-config.txt)

    echo IPv4:
    qrencode -t ANSIUTF8 <<<"$ipv4qr"

    echo IPv6:
    qrencode -t ANSIUTF8 <<<"$ipv6qr"

    echo "Reality setup completed."

    echo -e "\e[31mPress Enter to Exit\e[0m"
    read
    clear
}

modify_reality_config() {
    Transport="$1"
    user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)
    user_sni=$(whiptail --inputbox "Enter SNI:" 10 30 2>&1 >/dev/tty)

    systemctl stop RS

    rm -rf /etc/reality

    mkdir -p /etc/reality

    if [ "$Transport" == "grpc" ]; then
        curl -Lo /etc/reality/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Reality-gRPC.json
    elif [ "$Transport" == "tcp" ]; then
        curl -Lo /etc/reality/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Reality-tcp.json
    fi

    uuid=$(cat /proc/sys/kernel/random/uuid)
    short_id=$(openssl rand -hex 8)
    service_name=$(openssl rand -hex 4)
    output=$(RS generate reality-keypair)
    private_key=$(echo "$output" | grep -oP 'PrivateKey: \K\S+')
    public_key=$(echo "$output" | grep -oP 'PublicKey: \K\S+')
    sed -i "s/PORT/$user_port/" /etc/reality/config.json
    sed -i "s/SNI/$user_sni/" /etc/reality/config.json
    sed -i "s/NAME/Reality/" /etc/reality/config.json
    sed -i "s/UUID/$uuid/" /etc/reality/config.json
    sed -i "s/PRIVATE-KEY/$private_key/" /etc/reality/config.json
    sed -i "s/SHORT-ID/$short_id/" /etc/reality/config.json
    sed -i "s/PATH/$service_name/" /etc/reality/config.json

    public_ipv4=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v4.ident.me)
    public_ipv6=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v6.ident.me)

    set_ufw tcp

    systemctl start RS

    if [ "$Transport" == "grpc" ]; then
        result_url=" 
        ipv4 : vless://$uuid@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality
        ---------------------------------------------------------------
        ipv6 : vless://$uuid@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality-V6"

        result_url2=" 
        ipv4 : vless://UUID@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#NAME-Reality
        ---------------------------------------------------------------
        ipv6 : vless://UUID@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#NAME-Reality-V6"
    elif [ "$Transport" == "tcp" ]; then
        result_url="
        ipv4 : vless://$uuid@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=tcp&flow=xtls-rprx-vision&encryption=none#Reality
        ---------------------------------------------------------------
        ipv6 : vless://$uuid@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=tcp&flow=xtls-rprx-vision&encryption=none#Reality-V6"

        result_url2=" 
        ipv4 : vless://UUID@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=tcp&flow=xtls-rprx-vision&encryption=none#NAME-Reality
        ---------------------------------------------------------------
        ipv6 : vless://UUID@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=tcp&flow=xtls-rprx-vision&encryption=none#NAME-Reality-V6"
    fi

    echo -e "Config URL: $result_url" >/etc/reality/user-config.txt
    echo -e "Config URL: $result_url2" >/etc/reality/config.txt
    echo -e "Config URL: \e[91m$result_url\e[0m"

    ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/reality/user-config.txt)
    ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/reality/user-config.txt)

    echo IPv4:
    qrencode -t ANSIUTF8 <<<"$ipv4qr"

    echo IPv6:
    qrencode -t ANSIUTF8 <<<"$ipv6qr"

    echo "Reality configuration modified."

    echo -e "\e[31mPress Enter to Exit\e[0m"
    read
    clear
}

regenerate_keys() {
    reality_check="/etc/reality/config.json"
    config_json="/etc/reality/config.json"
    config_txt="/etc/reality/config.txt"

    if [ -e "$reality_check" ]; then
        output=$(RS generate reality-keypair)
        new_private_key=$(echo "$output" | grep -oP 'PrivateKey: \K\S+')
        new_public_key=$(echo "$output" | grep -oP 'PublicKey: \K\S+')
        new_short_id=$(RS generate rand 8 --hex)

        jq --arg new_key "$new_private_key" --arg new_id "$new_short_id" '.inbounds[0].tls.reality.private_key = $new_key | .inbounds[0].tls.reality.short_id[0] = $new_id' "$config_json" >temp.json && mv temp.json "$config_json"
        sed -i "s/pbk=[^\&]*/pbk=$new_public_key/g" "$config_txt"
        sed -i "s/sid=[^\&]*/sid=$new_short_id/g" "$config_txt"

        systemctl restart RS

        whiptail --msgbox "Keys updated successfully!" 10 30
        clear
    else
        whiptail --msgbox "Reality is not installed yet." 10 30
        clear
    fi
}

uninstall_reality() {
    systemctl stop RS
    rm -f /usr/bin/RS
    rm -rf /etc/reality
    rm -f /etc/systemd/system/RS.service
    crontab -l | sed '/0 \*\/5 \* \* \* systemctl restart RS/d' | crontab -
    systemctl daemon-reload

    whiptail --msgbox "Reality uninstalled." 10 30
    clear
}

install_shadowtls() {
    shadowtls_check="/etc/shadowtls/config.json"

    if [ -e "$shadowtls_check" ]; then
        whiptail --msgbox "ShadowTLS is Already installed " 10 30
        clear
    else
        user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)
        user_sni=$(whiptail --inputbox "Enter SNI:" 10 30 2>&1 >/dev/tty)

        install_core ST

        mkdir -p /etc/shadowtls

        curl -Lo /etc/shadowtls/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/ShadowTLS.json
        curl -Lo /etc/shadowtls/user-nekorayconfig.txt https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Client/ShadowTLS-nekoray.json
        curl -Lo /etc/shadowtls/user-nekoboxconfig.txt https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Client/ShadowTLS-nekobox.json
        curl -Lo /etc/shadowtls/nekorayconfig.txt https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Client/ShadowTLS-nekoray.json
        curl -Lo /etc/shadowtls/nekoboxconfig.txt https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Client/ShadowTLS-nekobox.json
        curl -Lo /etc/systemd/system/ST.service https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/ST.service
        systemctl daemon-reload

        stpass=$(openssl rand -hex 16)
        sspass=$(openssl rand -hex 16)
        public_ipv4=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v4.ident.me)

        sed -i "s/PORT/$user_port/" /etc/shadowtls/config.json
        sed -i "s/PORT/$user_port/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/PORT/$user_port/" /etc/shadowtls/nekoboxconfig.txt
        sed -i "s/PORT/$user_port/" /etc/shadowtls/user-nekorayconfig.txt
        sed -i "s/PORT/$user_port/" /etc/shadowtls/user-nekoboxconfig.txt

        sed -i "s/SNI/$user_sni/" /etc/shadowtls/config.json
        sed -i "s/SNI/$user_sni/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/SNI/$user_sni/" /etc/shadowtls/nekoboxconfig.txt
        sed -i "s/SNI/$user_sni/" /etc/shadowtls/user-nekorayconfig.txt
        sed -i "s/SNI/$user_sni/" /etc/shadowtls/user-nekoboxconfig.txt

        sed -i "s/STPASS/$stpass/" /etc/shadowtls/config.json
        sed -i "s/STPASS/$stpass/" /etc/shadowtls/user-nekorayconfig.txt
        sed -i "s/STPASS/$stpass/" /etc/shadowtls/user-nekoboxconfig.txt

        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/config.json
        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/nekoboxconfig.txt
        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/user-nekorayconfig.txt
        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/user-nekoboxconfig.txt

        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekoboxconfig.txt
        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/user-nekorayconfig.txt
        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/user-nekoboxconfig.txt

        sed -i "s/NAME/ShadowTLS/" /etc/shadowtls/config.json

        set_ufw tcp

        systemctl enable --now ST

        (crontab -l 2>/dev/null; echo "0 */5 * * * systemctl restart ST") | crontab -

        echo "ShadowTLS config for Nekoray : "
        echo
        cat /etc/shadowtls/user-nekorayconfig.txt
        echo
        echo "ShadowTLS config for Nekobox : "
        echo
        cat /etc/shadowtls/user-nekoboxconfig.txt
        echo
        echo "ShadowTLS setup completed."
        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    fi
}

modify_shadowtls_config() {
    shadowtls_check="/etc/shadowtls/config.json"

    if [ -e "$shadowtls_check" ]; then
        user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)
        user_sni=$(whiptail --inputbox "Enter SNI:" 10 30 2>&1 >/dev/tty)

        systemctl stop ST

        rm -rf /etc/shadowtls

        mkdir -p /etc/shadowtls

        curl -Lo /etc/shadowtls/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/ShadowTLS.json
        curl -Lo /etc/shadowtls/user-nekorayconfig.txt https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Client/ShadowTLS-nekoray.json
        curl -Lo /etc/shadowtls/user-nekoboxconfig.txt https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Client/ShadowTLS-nekobox.json
        curl -Lo /etc/shadowtls/nekorayconfig.txt https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Client/ShadowTLS-nekoray.json
        curl -Lo /etc/shadowtls/nekoboxconfig.txt https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Client/ShadowTLS-nekobox.json

        stpass=$(openssl rand -hex 16)
        sspass=$(openssl rand -hex 16)
        public_ipv4=$(wget -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://v4.ident.me)

        sed -i "s/PORT/$user_port/" /etc/shadowtls/config.json
        sed -i "s/PORT/$user_port/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/PORT/$user_port/" /etc/shadowtls/nekoboxconfig.txt
        sed -i "s/PORT/$user_port/" /etc/shadowtls/user-nekorayconfig.txt
        sed -i "s/PORT/$user_port/" /etc/shadowtls/user-nekoboxconfig.txt

        sed -i "s/SNI/$user_sni/" /etc/shadowtls/config.json
        sed -i "s/SNI/$user_sni/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/SNI/$user_sni/" /etc/shadowtls/nekoboxconfig.txt
        sed -i "s/SNI/$user_sni/" /etc/shadowtls/user-nekorayconfig.txt
        sed -i "s/SNI/$user_sni/" /etc/shadowtls/user-nekoboxconfig.txt

        sed -i "s/STPASS/$stpass/" /etc/shadowtls/config.json
        sed -i "s/STPASS/$stpass/" /etc/shadowtls/user-nekorayconfig.txt
        sed -i "s/STPASS/$stpass/" /etc/shadowtls/user-nekoboxconfig.txt

        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/config.json
        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/nekoboxconfig.txt
        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/user-nekorayconfig.txt
        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/user-nekoboxconfig.txt

        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekoboxconfig.txt
        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/user-nekorayconfig.txt
        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/user-nekoboxconfig.txt

        sed -i "s/NAME/ShadowTLS/" /etc/shadowtls/config.json

        set_ufw tcp

        systemctl start ST

        echo "ShadowTLS config for Nekoray : "
        echo
        cat /etc/shadowtls/user-nekorayconfig.txt
        echo
        echo "ShadowTLS config for Nekobox : "
        echo
        cat /etc/shadowtls/user-nekoboxconfig.txt
        echo
        echo "ShadowTLS configuration modified."
        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    else
        whiptail --msgbox "ShadowTLS is not installed yet." 10 30
        clear
    fi
}

uninstall_shadowtls() {
    systemctl stop ST
    rm -f /usr/bin/ST
    rm -rf /etc/shadowtls
    rm -f /etc/systemd/system/ST.service
    crontab -l | sed '/0 \*\/5 \* \* \* systemctl restart ST/d' | crontab -
    systemctl daemon-reload

    whiptail --msgbox "ShadowTLS uninstalled." 10 30
    clear
}

install_ws() {
    ws_check="/etc/ws/config.json"

    if [ -e "$ws_check" ]; then
        whiptail --msgbox "WebSocket is Already installed " 10 30
        clear
    else
        user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)
        domain=$(whiptail --inputbox "Enter Domain:" 10 30 2>&1 >/dev/tty)

        install_core WS

        mkdir -p /etc/ws

        curl -Lo /etc/ws/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/vless-WebSocket.json
        curl -Lo /etc/systemd/system/WS.service https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/WS.service
        systemctl daemon-reload

        uuid=$(cat /proc/sys/kernel/random/uuid)
        sed -i "s/UUID/$uuid/" /etc/ws/config.json
        sed -i "s/PORT/$user_port/" /etc/ws/config.json
        sed -i "s/DOMAIN/$domain/" /etc/ws/config.json
        sed -i "s/NAME/WebSocket/" /etc/ws/config.json

        set_ufw tcp

        get_ssl ws "$domain"
        cp /etc/letsencrypt/live/"$domain"/fullchain.pem /etc/ws/server.crt
        cp /etc/letsencrypt/live/"$domain"/privkey.pem /etc/ws/server.key

        systemctl enable --now WS

        (crontab -l 2>/dev/null; echo "0 */5 * * * systemctl restart WS") | crontab -

        result_url=" 
        vless://$uuid@$domain:$user_port?security=tls&sni=$domain&alpn=http/1.1&fp=firefox&type=ws&encryption=none#WebSocket"

        result_url2=" 
        vless://UUID@$domain:$user_port?security=tls&sni=$domain&alpn=http/1.1&fp=firefox&type=ws&encryption=none#NAME-WebSocket"

        echo -e "Config URL: $result_url" >/etc/ws/user-config.txt
        echo -e "Config URL: $result_url2" >/etc/ws/config.txt
        echo -e "Config URL: \e[91m$result_url\e[0m"

        config=$(cat /etc/ws/user-config.txt)

        echo QR:
        qrencode -t ANSIUTF8 <<<"$config"

        echo "WebSocket setup completed."

        echo -e "\e[31mPress Enter to Exit\e[0m"

        read
        clear
    fi
}

modify_ws_config() {
    ws_check="/etc/ws/config.json"

    if [ -e "$ws_check" ]; then
        user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)
        domain=$(whiptail --inputbox "Enter Domain:" 10 30 2>&1 >/dev/tty)

        systemctl stop WS

        rm -rf /etc/ws

        mkdir -p /etc/ws

        curl -Lo /etc/ws/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/vless-WebSocket.json

        uuid=$(cat /proc/sys/kernel/random/uuid)
        sed -i "s/UUID/$uuid/" /etc/ws/config.json
        sed -i "s/PORT/$user_port/" /etc/ws/config.json
        sed -i "s/DOMAIN/$domain/" /etc/ws/config.json
        sed -i "s/NAME/WebSocket/" /etc/ws/config.json

        set_ufw tcp

        get_ssl ws "$domain"
        rm -f /etc/ws/server.crt
        rm -f /etc/ws/server.key
        cp /etc/letsencrypt/live/"$domain"/fullchain.pem /etc/ws/server.crt
        cp /etc/letsencrypt/live/"$domain"/privkey.pem /etc/ws/server.key

        systemctl enable --now WS

        result_url=" 
        vless://$uuid@$domain:$user_port?security=tls&sni=$domain&alpn=http/1.1&fp=firefox&type=ws&encryption=none#WebSocket"

        result_url2=" 
        vless://UUID@$domain:$user_port?security=tls&sni=$domain&alpn=http/1.1&fp=firefox&type=ws&encryption=none#NAME-WebSocket"

        echo -e "Config URL: $result_url" >/etc/ws/user-config.txt
        echo -e "Config URL: $result_url2" >/etc/ws/config.txt
        echo -e "Config URL: \e[91m$result_url\e[0m"

        config=$(cat /etc/ws/user-config.txt)

        echo QR:
        qrencode -t ANSIUTF8 <<<"$config"

        echo "WebSocket configuration modified."

        echo -e "\e[31mPress Enter to Exit\e[0m"

        read
        clear
    else
        whiptail --msgbox "WebSocket is not installed yet." 10 30
        clear
    fi
}

uninstall_ws() {
    systemctl stop WS
    rm -f /usr/bin/WS
    rm -rf /etc/ws
    rm -f /etc/systemd/system/WS.service
    crontab -l | sed '/0 \*\/5 \* \* \* systemctl restart WS/d' | crontab -
    systemctl daemon-reload

    whiptail --msgbox "WebSocket uninstalled." 10 30
    clear
}

install_grpc() {
    grpc_check="/etc/grpc/config.json"

    if [ -e "$grpc_check" ]; then
        whiptail --msgbox "gRPC is Already installed " 10 30
        clear
    else
        user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)
        domain=$(whiptail --inputbox "Enter Domain:" 10 30 2>&1 >/dev/tty)

        install_core GS

        mkdir -p /etc/grpc

        curl -Lo /etc/grpc/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/vless-gRPC.json
        curl -Lo /etc/systemd/system/GS.service https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/GS.service
        systemctl daemon-reload

        uuid=$(cat /proc/sys/kernel/random/uuid)
        service_name=$(openssl rand -hex 4)
        sed -i "s/UUID/$uuid/" /etc/grpc/config.json
        sed -i "s/PORT/$user_port/" /etc/grpc/config.json
        sed -i "s/DOMAIN/$domain/" /etc/grpc/config.json
        sed -i "s/NAME/gRPC/" /etc/grpc/config.json
        sed -i "s/PATH/$service_name/" /etc/grpc/config.json

        set_ufw tcp

        get_ssl grpc "$domain"
        cp /etc/letsencrypt/live/"$domain"/fullchain.pem /etc/grpc/server.crt
        cp /etc/letsencrypt/live/"$domain"/privkey.pem /etc/grpc/server.key

        systemctl enable --now GS

        (crontab -l 2>/dev/null; echo "0 */5 * * * systemctl restart GS") | crontab -

        result_url=" 
        vless://$uuid@$domain:$user_port?security=tls&sni=$domain&alpn=h2&fp=firefox&type=grpc&serviceName=$service_name&encryption=none#gRPC"

        result_url2=" 
        vless://UUID@$domain:$user_port?security=tls&sni=$domain&alpn=h2&fp=firefox&type=grpc&serviceName=$service_name&encryption=none#NAME-gRPC"

        echo -e "Config URL: $result_url" >/etc/grpc/user-config.txt
        echo -e "Config URL: $result_url2" >/etc/grpc/config.txt
        echo -e "Config URL: \e[91m$result_url\e[0m"

        config=$(cat /etc/grpc/user-config.txt)

        echo QR:
        qrencode -t ANSIUTF8 <<<"$config"

        echo "gRPC setup completed."

        echo -e "\e[31mPress Enter to Exit\e[0m"

        read
        clear
    fi
}

modify_grpc_config() {
    grpc_check="/etc/grpc/config.json"

    if [ -e "$grpc_check" ]; then
        user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)
        domain=$(whiptail --inputbox "Enter Domain:" 10 30 2>&1 >/dev/tty)

        systemctl stop GS

        rm -rf /etc/grpc

        mkdir -p /etc/grpc

        curl -Lo /etc/grpc/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/vless-gRPC.json

        uuid=$(cat /proc/sys/kernel/random/uuid)
        service_name=$(openssl rand -hex 4)
        sed -i "s/UUID/$uuid/" /etc/grpc/config.json
        sed -i "s/PORT/$user_port/" /etc/grpc/config.json
        sed -i "s/DOMAIN/$domain/" /etc/grpc/config.json
        sed -i "s/NAME/gRPC/" /etc/grpc/config.json
        sed -i "s/PATH/$service_name/" /etc/grpc/config.json

        set_ufw tcp

        get_ssl grpc "$domain"
        rm -f /etc/grpc/server.crt
        rm -f /etc/grpc/server.key
        cp /etc/letsencrypt/live/"$domain"/fullchain.pem /etc/grpc/server.crt
        cp /etc/letsencrypt/live/"$domain"/privkey.pem /etc/grpc/server.key

        systemctl enable --now GS

        result_url=" 
        vless://$uuid@$domain:$user_port?security=tls&sni=$domain&alpn=h2&fp=firefox&type=grpc&serviceName=$service_name&encryption=none#gRPC"

        result_url2=" 
        vless://UUID@$domain:$user_port?security=tls&sni=$domain&alpn=h2&fp=firefox&type=grpc&serviceName=$service_name&encryption=none#NAME-gRPC"

        echo -e "Config URL: $result_url" >/etc/grpc/user-config.txt
        echo -e "Config URL: $result_url2" >/etc/grpc/config.txt
        echo -e "Config URL: \e[91m$result_url\e[0m"

        config=$(cat /etc/grpc/user-config.txt)

        echo QR:
        qrencode -t ANSIUTF8 <<<"$config"

        echo "gRPC configuration modified."

        echo -e "\e[31mPress Enter to Exit\e[0m"

        read
        clear
    else
        whiptail --msgbox "gRPC is not installed yet." 10 30
        clear
    fi
}

uninstall_grpc() {
    systemctl stop GS
    rm -f /usr/bin/GS
    rm -rf /etc/grpc
    rm -f /etc/systemd/system/GS.service
    crontab -l | sed '/0 \*\/5 \* \* \* systemctl restart GS/d' | crontab -
    systemctl daemon-reload

    whiptail --msgbox "gRPC uninstalled." 10 30
    clear
}

install_naive() {
    naive_check="/etc/naive/config.json"

    if [ -e "$naive_check" ]; then
        whiptail --msgbox "Naive is Already installed " 10 30
        clear
    else
        user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)
        domain=$(whiptail --inputbox "Enter Domain:" 10 30 2>&1 >/dev/tty)

        install_core NS

        mkdir -p /etc/naive

        curl -Lo /etc/naive/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Naive.json
        curl -Lo /etc/systemd/system/NS.service https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/NS.service
        systemctl daemon-reload

        password=$(openssl rand -hex 8)
        sed -i "s/PASSWORD/$password/" /etc/naive/config.json
        sed -i "s/PORT/$user_port/" /etc/naive/config.json
        sed -i "s/DOMAIN/$domain/" /etc/naive/config.json
        sed -i "s/NAME/Naive/" /etc/naive/config.json

        set_ufw tcp

        get_ssl naive "$domain"
        cp /etc/letsencrypt/live/"$domain"/fullchain.pem /etc/naive/server.crt
        cp /etc/letsencrypt/live/"$domain"/privkey.pem /etc/naive/server.key

        systemctl enable --now NS

        (crontab -l 2>/dev/null; echo "0 */5 * * * systemctl restart NS") | crontab -

        result_url=" 
        naive+https://Naive:$password@$domain:$user_port#Naive"

        result_url2=" 
        naive+https://NAME:PASSWORD@$domain:$user_port#NAME-Naive"

        echo -e "Config URL: $result_url" >/etc/naive/user-config.txt
        echo -e "Config URL: $result_url2" >/etc/naive/config.txt
        echo -e "Config URL: \e[91m$result_url\e[0m"

        config=$(cat /etc/naive/user-config.txt)

        echo QR:
        qrencode -t ANSIUTF8 <<<"$config"

        echo "Naive setup completed."

        echo -e "\e[31mPress Enter to Exit\e[0m"

        read
        clear
    fi
}

modify_naive_config() {
    naive_check="/etc/naive/config.json"

    if [ -e "$naive_check" ]; then
        user_port=$(whiptail --inputbox "Enter Port:" 10 30 2>&1 >/dev/tty)
        domain=$(whiptail --inputbox "Enter Domain:" 10 30 2>&1 >/dev/tty)

        systemctl stop NS

        rm -rf /etc/naive

        mkdir -p /etc/naive

        curl -Lo /etc/naive/config.json https://raw.githubusercontent.com/johnayman0/config-examples/main/Sing-Box/Server/Naive.json

        password=$(openssl rand -hex 8)
        sed -i "s/PASSWORD/$password/" /etc/naive/config.json
        sed -i "s/PORT/$user_port/" /etc/naive/config.json
        sed -i "s/DOMAIN/$domain/" /etc/naive/config.json
        sed -i "s/NAME/Naive/" /etc/naive/config.json

        set_ufw tcp

        get_ssl naive "$domain"
        rm -f /etc/naive/server.crt
        rm -f /etc/naive/server.key
        cp /etc/letsencrypt/live/"$domain"/fullchain.pem /etc/naive/server.crt
        cp /etc/letsencrypt/live/"$domain"/privkey.pem /etc/naive/server.key

        systemctl enable --now NS

        result_url=" 
        naive+https://Naive:$password@$domain:$user_port#Naive"

        result_url2=" 
        naive+https://NAME:PASSWORD@$domain:$user_port#NAME-Naive"

        echo -e "Config URL: $result_url" >/etc/naive/user-config.txt
        echo -e "Config URL: $result_url2" >/etc/naive/config.txt
        echo -e "Config URL: \e[91m$result_url\e[0m"

        config=$(cat /etc/naive/user-config.txt)

        echo QR:
        qrencode -t ANSIUTF8 <<<"$config"

        echo "Naive Configuration Modified."

        echo -e "\e[31mPress Enter to Exit\e[0m"

        read
        clear
    else
        whiptail --msgbox "Naive is not installed yet." 10 30
        clear
    fi
}

uninstall_naive() {
    systemctl stop NS
    rm -f /usr/bin/NS
    rm -rf /etc/naive
    rm -f /etc/systemd/system/NS.service
    crontab -l | sed '/0 \*\/5 \* \* \* systemctl restart NS/d' | crontab -
    systemctl daemon-reload

    whiptail --msgbox "Naive uninstalled." 10 30
    clear
}

show_hysteria_config() {
    hysteria_check="/etc/hysteria2/config.txt"

    if [ -e "$hysteria_check" ]; then
        config_file="/etc/hysteria2/server.json"
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select user:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_password=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].password' "$config_file")
            user_name=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].name' "$config_file")

            sed -e "s/PASSWORD/$user_password/g" -e "s/NAME/$user_name/g" /etc/hysteria2/config.txt >/etc/hysteria2/user-config.txt

            echo -e "\e[91m$(cat /etc/hysteria2/user-config.txt)\e[0m"

            ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/hysteria2/user-config.txt)
            ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/hysteria2/user-config.txt)

            echo IPv4:
            qrencode -t ANSIUTF8 <<<"$ipv4qr"

            echo IPv6:
            qrencode -t ANSIUTF8 <<<"$ipv6qr"
        fi

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    else
        whiptail --msgbox "Hysteria2 is not installed yet." 10 30
        clear
    fi
}

show_tuic_config() {
    tuic_check="/etc/tuic/config.txt"

    if [ -e "$tuic_check" ]; then
        config_file="/etc/tuic/server.json"
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select user:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_password=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].password' "$config_file")
            user_uuid=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].uuid' "$config_file")
            user_name=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].name' "$config_file")

            sed -e "s/PASSWORD/$user_password/g" -e "s/UUID/$user_uuid/g" -e "s/NAME/$user_name/g" /etc/tuic/config.txt >/etc/tuic/user-config.txt

            echo -e "\e[91m$(cat /etc/tuic/user-config.txt)\e[0m"

            ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/tuic/user-config.txt)
            ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/tuic/user-config.txt)

            echo IPv4:
            qrencode -t ANSIUTF8 <<<"$ipv4qr"

            echo IPv6:
            qrencode -t ANSIUTF8 <<<"$ipv6qr"
        fi

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    else
        whiptail --msgbox "TUIC is not installed yet." 10 30
        clear
    fi

}

show_reality_config() {
    reality_check="/etc/reality/config.txt"

    if [ -e "$reality_check" ]; then
        config_file="/etc/reality/config.json"
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select user:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_uuid=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].uuid' "$config_file")
            user_name=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].name' "$config_file")

            sed -e "s/UUID/$user_uuid/g" -e "s/NAME/$user_name/g" /etc/reality/config.txt >/etc/reality/user-config.txt

            echo -e "\e[91m$(cat /etc/reality/user-config.txt)\e[0m"

            ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/reality/user-config.txt)
            ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/reality/user-config.txt)

            echo IPv4:
            qrencode -t ANSIUTF8 <<<"$ipv4qr"

            echo IPv6:
            qrencode -t ANSIUTF8 <<<"$ipv6qr"
        fi

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    else
        whiptail --msgbox "Reality is not installed yet." 10 30
        clear
    fi
}

show_shadowtls_config() {
    shadowtls_check="/etc/shadowtls/nekorayconfig.txt"

    if [ -e "$shadowtls_check" ]; then
        config_file="/etc/shadowtls/config.json"
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select user:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_password=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].password' "$config_file")

            sed "s/STPASS/$user_password/g" /etc/shadowtls/nekorayconfig.txt >/etc/shadowtls/user-nekorayconfig.txt
            sed "s/STPASS/$user_password/g" /etc/shadowtls/nekoboxconfig.txt >/etc/shadowtls/user-nekoboxconfig.txt

            echo "ShadowTLS config for Nekoray : "

            echo

            cat /etc/shadowtls/user-nekorayconfig.txt

            echo

            echo "ShadowTLS config for Nekobox : "

            echo

            cat /etc/shadowtls/user-nekoboxconfig.txt

            echo
        fi

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    else
        whiptail --msgbox "ShadowTLS is not installed yet." 10 30
        clear
    fi
}

show_ws_config() {
    ws_check="/etc/ws/config.txt"

    if [ -e "$ws_check" ]; then
        config_file="/etc/ws/config.json"
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select user:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_uuid=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].uuid' "$config_file")
            user_name=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].name' "$config_file")

            sed -e "s/UUID/$user_uuid/g" -e "s/NAME/$user_name/g" /etc/ws/config.txt >/etc/ws/user-config.txt

            echo -e "\e[91m$(cat /etc/ws/user-config.txt)\e[0m"

            config=$(cat /etc/ws/user-config.txt)

            echo QR:
            qrencode -t ANSIUTF8 <<<"$config"
        fi

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    else
        whiptail --msgbox "WebSocket is not installed yet." 10 30
        clear
    fi
}

show_grpc_config() {
    grpc_check="/etc/grpc/config.txt"

    if [ -e "$grpc_check" ]; then
        config_file="/etc/grpc/config.json"
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select user:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_uuid=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].uuid' "$config_file")
            user_name=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].name' "$config_file")

            sed -e "s/UUID/$user_uuid/g" -e "s/NAME/$user_name/g" /etc/grpc/config.txt >/etc/grpc/user-config.txt

            echo -e "\e[91m$(cat /etc/grpc/user-config.txt)\e[0m"

            config=$(cat /etc/grpc/user-config.txt)

            echo QR:
            qrencode -t ANSIUTF8 <<<"$config"
        fi

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    else
        whiptail --msgbox "gRPC is not installed yet." 10 30
        clear
    fi
}

show_naive_config() {
    naive_check="/etc/naive/config.txt"

    if [ -e "$naive_check" ]; then
        config_file="/etc/naive/config.json"
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.username)"' "$config_file")
        user_choice=$(whiptail --menu "Select user:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_password=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].password' "$config_file")
            user_name=$(jq -r --argjson user_key "$user_choice" '.inbounds[0].users[$user_key].username' "$config_file")

            sed -e "s/PASSWORD/$user_password/g" -e "s/NAME/$user_name/g" /etc/naive/config.txt >/etc/naive/user-config.txt

            echo -e "\e[91m$(cat /etc/naive/user-config.txt)\e[0m"

            config=$(cat /etc/naive/user-config.txt)

            echo QR:
            qrencode -t ANSIUTF8 <<<"$config"
        fi

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    else
        whiptail --msgbox "Naive is not installed yet." 10 30
        clear
    fi
}

show_warp_config() {
    warp_conf_check="/etc/sbw/proxy.json"

    if [ -e "$warp_conf_check" ]; then
        cat /etc/sbw/proxy.json | jq

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear
    else
        whiptail --msgbox "WARP is not installed yet." 10 30
        clear
    fi
}

warp_key_gen() {
    curl -fsSL https://raw.githubusercontent.com/johnayman0/config-examples/main/WARP%2B-sing-box-config-generator/key-generator.py -o key-generator.py
    python3 key-generator.py
    rm -f key-generator.py
    clear
}

install_warp() {
    rm -rf /etc/sbw
    mkdir /etc/sbw && cd /etc/sbw || exit
    wget https://raw.githubusercontent.com/johnayman0/config-examples/main/WARP%2B-sing-box-config-generator/main.sh
    wget https://raw.githubusercontent.com/johnayman0/config-examples/main/WARP%2B-sing-box-config-generator/warp-api
    wget https://raw.githubusercontent.com/johnayman0/config-examples/main/WARP%2B-sing-box-config-generator/warp-go
    chmod +x main.sh
    ./main.sh
    rm -f warp-go warp-api main.sh warp.conf
    cd || exit

    whiptail --msgbox "WARP Wireguard Config Generated successfuly" 10 30
    clear
}

uninstall_warp() {
    rm -rf /etc/sbw

    file1="/etc/reality/config.json"

    if [ -e "$file1" ]; then
        if jq -e '.outbounds[0].type == "wireguard"' "$file1" &>/dev/null; then
            new_json='{
            "tag": "direct",
            "type": "direct"
            }'

            jq '.outbounds = ['"$new_json"']' "$file1" >/tmp/tmp_config.json
            mv /tmp/tmp_config.json "$file1"
            systemctl restart RS

            echo "WARP is disabled on Reality"
        else
            echo
        fi
    else
        echo
    fi

    file2="/etc/shadowtls/config.json"

    if [ -e "$file2" ]; then
        if jq -e '.outbounds[0].type == "wireguard"' "$file2" &>/dev/null; then
            new_json='{
            "tag": "direct",
            "type": "direct"
            }'

            jq '.outbounds = ['"$new_json"']' "$file2" >/tmp/tmp_config.json
            mv /tmp/tmp_config.json "$file2"
            systemctl restart ST

            echo "WARP is disabled on ShadowTLS"
        else
            echo
        fi
    else
        echo
    fi

    file3="/etc/tuic/server.json"

    if [ -e "$file3" ]; then
        if jq -e '.outbounds[0].type == "wireguard"' "$file3" &>/dev/null; then
            new_json='{
            "tag": "direct",
            "type": "direct"
            }'

            jq '.outbounds = ['"$new_json"']' "$file3" >/tmp/tmp_config.json
            mv /tmp/tmp_config.json "$file3"
            systemctl restart TS

            echo "WARP is disabled on TUIC"
        else
            echo
        fi
    else
        echo
    fi

    file4="/etc/hysteria2/server.json"

    if [ -e "$file4" ]; then
        if jq -e '.outbounds[0].type == "wireguard"' "$file4" &>/dev/null; then
            new_json='{
            "tag": "direct",
            "type": "direct"
            }'

            jq '.outbounds = ['"$new_json"']' "$file4" >/tmp/tmp_config.json
            mv /tmp/tmp_config.json "$file4"
            systemctl restart SH

            echo "WARP is disabled on Hysteria2"
        else
            echo
        fi
    else
        echo
    fi

    file5="/etc/ws/config.json"

    if [ -e "$file5" ]; then
        if jq -e '.outbounds[0].type == "wireguard"' "$file5" &>/dev/null; then
            new_json='{
            "tag": "direct",
            "type": "direct"
            }'

            jq '.outbounds = ['"$new_json"']' "$file5" >/tmp/tmp_config.json
            mv /tmp/tmp_config.json "$file5"
            systemctl restart WS

            echo "WARP is disabled on WebSocket"
        else
            echo
        fi
    else
        echo
    fi

    file6="/etc/naive/config.json"

    if [ -e "$file6" ]; then
        if jq -e '.outbounds[0].type == "wireguard"' "$file6" &>/dev/null; then
            new_json='{
            "tag": "direct",
            "type": "direct"
            }'

            jq '.outbounds = ['"$new_json"']' "$file6" >/tmp/tmp_config.json
            mv /tmp/tmp_config.json "$file6"
            systemctl restart NS

            echo "WARP is disabled on Naive"
        else
            echo
        fi
    else
        echo
    fi

    file7="/etc/grpc/config.json"

    if [ -e "$file7" ]; then
        if jq -e '.outbounds[0].type == "wireguard"' "$file7" &>/dev/null; then
            new_json='{
            "tag": "direct",
            "type": "direct"
            }'

            jq '.outbounds = ['"$new_json"']' "$file7" >/tmp/tmp_config.json
            mv /tmp/tmp_config.json "$file7"
            systemctl restart WS

            echo "WARP is disabled on gRPC"
        else
            echo
        fi
    else
        echo
    fi    

    whiptail --msgbox "WARP uninstalled." 10 30
    clear

}

update_sing-box_core() {

    rlt_core_check="/usr/bin/RS"

    if [ -e "$rlt_core_check" ]; then
        systemctl stop RS
        rm /usr/bin/RS
        install_core RS
        systemctl start RS
        echo "Reality sing-box core has been updated"
    else
        echo "Reality is not installed yet."
    fi

    st_core_check="/usr/bin/ST"

    if [ -e "$st_core_check" ]; then
        systemctl stop ST
        rm /usr/bin/ST
        install_core ST
        systemctl start ST
        echo "ShadowTLS sing-box core has been updated"
    else
        echo "ShadowTLS is not installed yet."
    fi

    ts_core_check="/usr/bin/TS"

    if [ -e "$ts_core_check" ]; then
        systemctl stop TS
        rm /usr/bin/TS
        install_core TS
        systemctl start TS
        echo "TUIC sing-box core has been updated"
    else
        echo "TUIC is not installed yet."
    fi

    sh_core_check="/usr/bin/SH"

    if [ -e "$sh_core_check" ]; then
        systemctl stop SH
        rm /usr/bin/SH
        install_core SH
        systemctl start SH
        echo "Hysteria2 sing-box core has been updated"
    else
        echo "Hysteria2 is not installed yet."
    fi

    ws_core_check="/usr/bin/WS"

    if [ -e "$ws_core_check" ]; then
        systemctl stop WS
        rm /usr/bin/WS
        install_core WS
        systemctl start WS
        echo "WebSocket sing-box core has been updated"
    else
        echo "WebSocket is not installed yet."
    fi

    ns_core_check="/usr/bin/NS"

    if [ -e "$ns_core_check" ]; then
        systemctl stop NS
        rm /usr/bin/NS
        install_core NS
        systemctl start NS
        echo "Naive sing-box core has been updated"
    else
        echo "Naive is not installed yet."
    fi

    gs_core_check="/usr/bin/GS"

    if [ -e "$gs_core_check" ]; then
        systemctl stop GS
        rm /usr/bin/GS
        install_core GS
        systemctl start GS
        echo "gRPC sing-box core has been updated"
    else
        echo "gRPC is not installed yet."
    fi    

    whiptail --msgbox "Sing-Box Cores Has Been Updated" 10 30
    clear

}

toggle_warp_reality() {
    file="/etc/reality/config.json"
    warp="/etc/sbw/proxy.json"

    if [ -e "$file" ]; then
        if [ -e "$warp" ]; then
            systemctl stop RS

            if jq -e '.outbounds[0].type == "wireguard"' "$file" &>/dev/null; then
                new_json='{
                "tag": "direct",
                "type": "direct"
                }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"
                systemctl start RS

                whiptail --msgbox "WARP is disabled now" 10 30
                clear
            else
                outbounds_block=$(jq -c '.outbounds' "$warp")

                jq --argjson new_outbounds "$outbounds_block" '.outbounds = $new_outbounds' "$file" >temp_config.json
                mv temp_config.json "$file"
                systemctl start RS

                whiptail --msgbox "WARP is enabled now" 10 30
                clear
            fi
        else
            whiptail --msgbox "WARP is not installed yet" 10 30
            clear
        fi
    else
        whiptail --msgbox "Reality is not installed yet." 10 30
        clear
    fi
}

toggle_warp_shadowtls() {
    file="/etc/shadowtls/config.json"
    warp="/etc/sbw/proxy.json"

    if [ -e "$file" ]; then
        if [ -e "$warp" ]; then
            systemctl stop ST

            if jq -e '.outbounds[0].type == "wireguard"' "$file" &>/dev/null; then
                new_json='{
                "tag": "direct",
                "type": "direct"
                }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"
                systemctl start ST

                whiptail --msgbox "WARP is disabled now" 10 30
                clear
            else
                outbounds_block=$(jq -c '.outbounds' "$warp")

                jq --argjson new_outbounds "$outbounds_block" '.outbounds = $new_outbounds' "$file" >temp_config.json
                mv temp_config.json "$file"
                systemctl start ST

                whiptail --msgbox "WARP is enabled now" 10 30
                clear
            fi
        else
            whiptail --msgbox "WARP is not installed yet" 10 30
            clear
        fi
    else
        whiptail --msgbox "ShadowTLS is not installed yet." 10 30
        clear
    fi
}

toggle_warp_tuic() {
    file="/etc/tuic/server.json"
    warp="/etc/sbw/proxy.json"

    if [ -e "$file" ]; then
        if [ -e "$warp" ]; then
            systemctl stop TS

            if jq -e '.outbounds[0].type == "wireguard"' "$file" &>/dev/null; then
                new_json='{
                "tag": "direct",
                "type": "direct"
                }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"
                systemctl start TS

                whiptail --msgbox "WARP is disabled now" 10 30
                clear
            else
                outbounds_block=$(jq -c '.outbounds' "$warp")

                jq --argjson new_outbounds "$outbounds_block" '.outbounds = $new_outbounds' "$file" >temp_config.json
                mv temp_config.json "$file"
                systemctl start TS

                whiptail --msgbox "WARP is enabled now" 10 30
                clear
            fi
        else
            whiptail --msgbox "WARP is not installed yet" 10 30
            clear
        fi
    else
        whiptail --msgbox "TUIC is not installed yet." 10 30
        clear
    fi
}

toggle_warp_hysteria() {
    file="/etc/hysteria2/server.json"
    warp="/etc/sbw/proxy.json"

    if [ -e "$file" ]; then
        if [ -e "$warp" ]; then
            systemctl stop SH

            if jq -e '.outbounds[0].type == "wireguard"' "$file" &>/dev/null; then
                new_json='{
                "tag": "direct",
                "type": "direct"
                }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"
                systemctl start SH

                whiptail --msgbox "WARP is disabled now" 10 30
                clear
            else
                outbounds_block=$(jq -c '.outbounds' "$warp")

                jq --argjson new_outbounds "$outbounds_block" '.outbounds = $new_outbounds' "$file" >temp_config.json
                mv temp_config.json "$file"
                systemctl start SH

                whiptail --msgbox "WARP is enabled now" 10 30
                clear
            fi
        else
            whiptail --msgbox "WARP is not installed yet" 10 30
            clear
        fi
    else
        whiptail --msgbox "Hysteria2 is not installed yet." 10 30
        clear
    fi
}

toggle_warp_ws() {
    file="/etc/ws/config.json"
    warp="/etc/sbw/proxy.json"

    if [ -e "$file" ]; then
        if [ -e "$warp" ]; then
            systemctl stop WS

            if jq -e '.outbounds[0].type == "wireguard"' "$file" &>/dev/null; then
                new_json='{
                "tag": "direct",
                "type": "direct"
                }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"
                systemctl start WS

                whiptail --msgbox "WARP is disabled now" 10 30
                clear
            else
                outbounds_block=$(jq -c '.outbounds' "$warp")

                jq --argjson new_outbounds "$outbounds_block" '.outbounds = $new_outbounds' "$file" >temp_config.json
                mv temp_config.json "$file"
                systemctl start WS

                whiptail --msgbox "WARP is enabled now" 10 30
                clear
            fi
        else
            whiptail --msgbox "WARP is not installed yet" 10 30
            clear
        fi
    else
        whiptail --msgbox "WebSocket is not installed yet." 10 30
        clear
    fi
}

toggle_warp_grpc() {
    file="/etc/grpc/config.json"
    warp="/etc/sbw/proxy.json"

    if [ -e "$file" ]; then
        if [ -e "$warp" ]; then
            systemctl stop GS

            if jq -e '.outbounds[0].type == "wireguard"' "$file" &>/dev/null; then
                new_json='{
                "tag": "direct",
                "type": "direct"
                }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"
                systemctl start WS

                whiptail --msgbox "WARP is disabled now" 10 30
                clear
            else
                outbounds_block=$(jq -c '.outbounds' "$warp")

                jq --argjson new_outbounds "$outbounds_block" '.outbounds = $new_outbounds' "$file" >temp_config.json
                mv temp_config.json "$file"
                systemctl start GS

                whiptail --msgbox "WARP is enabled now" 10 30
                clear
            fi
        else
            whiptail --msgbox "WARP is not installed yet" 10 30
            clear
        fi
    else
        whiptail --msgbox "gRPC is not installed yet." 10 30
        clear
    fi
}

toggle_warp_naive() {
    file="/etc/naive/config.json"
    warp="/etc/sbw/proxy.json"

    if [ -e "$file" ]; then
        if [ -e "$warp" ]; then
            systemctl stop NS

            if jq -e '.outbounds[0].type == "wireguard"' "$file" &>/dev/null; then
                new_json='{
                "tag": "direct",
                "type": "direct"
                }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"
                systemctl start NS

                whiptail --msgbox "WARP is disabled now" 10 30
                clear
            else
                outbounds_block=$(jq -c '.outbounds' "$warp")

                jq --argjson new_outbounds "$outbounds_block" '.outbounds = $new_outbounds' "$file" >temp_config.json
                mv temp_config.json "$file"
                systemctl start NS

                whiptail --msgbox "WARP is enabled now" 10 30
                clear
            fi
        else
            whiptail --msgbox "WARP is not installed yet" 10 30
            clear
        fi
    else
        whiptail --msgbox "Naive is not installed yet." 10 30
        clear
    fi
}

check_OS() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        OS=Debian
        VER=$(cat /etc/debian_version)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi

    if [ "$OS" == "Ubuntu" ] || [ "$OS" == "Debian" ]; then
        systemPackage="apt"
    elif [ "$OS" == "CentOS" ] || [ "$OS" == "Red Hat" ]; then
        systemPackage="yum"
    else
        echo "Unsupported OS"
        exit 1
    fi
}

check_system_info() {
    if [[ $(type -p systemd-detect-virt) ]]; then
        VIRT=$(systemd-detect-virt)
    elif [[ $(type -p hostnamectl) ]]; then
        VIRT=$(hostnamectl | awk '/Virtualization/{print $NF}')
    elif [[ $(type -p virt-what) ]]; then
        VIRT=$(virt-what)
    fi

    [ -s /etc/os-release ] && SYS="$(grep -i pretty_name /etc/os-release | cut -d \" -f2)"
    [[ -z "$SYS" && $(type -p hostnamectl) ]] && SYS="$(hostnamectl | grep -i system | cut -d : -f2)"
    [[ -z "$SYS" && $(type -p lsb_release) ]] && SYS="$(lsb_release -sd)"
    [[ -z "$SYS" && -s /etc/lsb-release ]] && SYS="$(grep -i description /etc/lsb-release | cut -d \" -f2)"
    [[ -z "$SYS" && -s /etc/redhat-release ]] && SYS="$(grep . /etc/redhat-release)"
    [[ -z "$SYS" && -s /etc/issue ]] && SYS="$(grep . /etc/issue | cut -d '\' -f1 | sed '/^[ ]*$/d')"

    REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "amazon linux" "arch linux" "alpine")
    RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Arch" "Alpine")
    EXCLUDE=("")
    MAJOR=("9" "16" "7" "7" "" "")

    for int in "${!REGEX[@]}"; do [[ $(tr 'A-Z' 'a-z' <<<"$SYS") =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break; done
    [ -z "$SYSTEM" ] && error " $(text 5) "

    for ex in "${EXCLUDE[@]}"; do [[ ! $(tr 'A-Z' 'a-z' <<<"$SYS") =~ $ex ]]; done &&
    [[ "$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)" -lt "${MAJOR[int]}" ]] && error " $(text_eval 6) "

    KERNEL=$(uname -r)
    ARCHITECTURE=$(uname -m)
}

check_dep() {
    check_OS
    if [ "$OS" == "Ubuntu" ] || [ "$OS" == "Debian" ]; then
        dependencies=("wget" "whiptail" "qrencode" "jq" "certbot" "openssl" "python3" "python3-pip")
    elif [ "$OS" == "CentOS" ] || [ "$OS" == "Red Hat" ]; then
        dependencies=("wget" "newt" "qrencode" "jq" "certbot" "openssl" "python3" "python3-pip")
    fi

    for package in "${dependencies[@]}"; do
        if ! dpkg -s $package >/dev/null 2>&1 && ! rpm -q $package >/dev/null 2>&1; then
            echo "Package $package is not installed. Installing..."
            $systemPackage update
            $systemPackage install -y $package
        else
            echo "Package $package is already installed."
        fi
    done

    python_dependencies=("httpx" "requests")

    for package in "${python_dependencies[@]}"; do
        if ! python3 -c "import $package" >/dev/null 2>&1; then
            echo "Python package $package is not installed. Installing..."
            pip3 install $package
            pip3 uninstall urllib3 -y
        else
            echo "Python package $package is already installed."
        fi
    done
}

get_cpu_usage() {
    cpu_info=($(grep 'cpu ' /proc/stat))
    prev_idle="${cpu_info[4]}"
    prev_total=0

    for value in "${cpu_info[@]}"; do
        prev_total=$((prev_total + value))
    done

    sleep 1

    cpu_info=($(grep 'cpu ' /proc/stat))
    idle="${cpu_info[4]}"
    total=0

    for value in "${cpu_info[@]}"; do
        total=$((total + value))
    done

    delta_idle=$((idle - prev_idle))
    delta_total=$((total - prev_total))
    cpu_usage=$(awk "BEGIN {printf \"%.2f\", 100 * (1 - $delta_idle / $delta_total)}")
}

get_ram_usage() {
    memory_info=$(free | grep Mem)
    total_memory=$(echo "$memory_info" | awk '{print $2}')
    used_memory=$(echo "$memory_info" | awk '{print $3}')
    memory_usage=$(awk "BEGIN {printf \"%.2f\", $used_memory / $total_memory * 100}")
}

get_storage_usage() {
    storage_info=$(df / | awk 'NR==2{print $3,$2}')
    used_storage=$(echo "$storage_info" | awk '{print $1}')
    total_storage=$(echo "$storage_info" | awk '{print $2}')
    storage_usage=$(awk "BEGIN {printf \"%.2f\", $used_storage / $total_storage * 100}")
}

check_system_ip() {
    IP4=$(wget -4 -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 http://ip-api.com/json/) &&
    WAN4=$(expr "$IP4" : '.*query\":[ ]*\"\([^"]*\).*') &&
    COUNTRY=$(expr "$IP4" : '.*country\":[ ]*\"\([^"]*\).*') &&
    ISP=$(expr "$IP4" : '.*isp\":[ ]*\"\([^"]*\).*')

    IP6=$(wget -6 -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://api.ip.sb/geoip) &&
    WAN6=$(expr "$IP6" : '.*ip\":[ ]*\"\([^"]*\).*')
}

check_and_display_process_status() {
    PROCESS_NAME="$1"
    CUSTOM_NAME="$2"
    JSON_FILE="$3"
    PID=$(pgrep -o -x "$PROCESS_NAME")

    if [ -n "$PID" ]; then
        echo -n -e "$CUSTOM_NAME: \e[32m✔\e[0m"
    else
        echo -n -e "$CUSTOM_NAME: \e[31m✘\e[0m"
    fi

    if [ -e "$JSON_FILE" ]; then
        if jq -e '.outbounds[0].type == "wireguard"' "$JSON_FILE" &>/dev/null; then
            echo -e " - warp: \e[32m✔\e[0m"
        else
            echo -e " - warp: \e[31m✘\e[0m"
        fi
    else
        echo
    fi
}

root_check() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script requires root privileges. Please run it as root!"
        exit 1
    fi
}

add_alias() {
    if ! grep -qxF 'alias sci="bash <(curl -fsSL https://bit.ly/config-installer)"' ~/.bashrc; then
        echo 'alias sci="bash <(curl -fsSL https://bit.ly/config-installer)"' >> ~/.bashrc
        source ~/.bashrc
    fi
}

get_ssl() {
    SERVICE_TYPE="$1"
    DOMAIN="$2"
    RESTART_SERVICES=()

    stop_service() {
        PROCESS=$(ps -p $1 -o comm=)
        SERVICE=$(systemctl list-units --all | grep $PROCESS | awk '{print $1}')

        if [[ -n "$SERVICE" ]]; then
            echo "Stopping $SERVICE"
            systemctl stop "$SERVICE"
            RESTART_SERVICES+=("$SERVICE")
        else
            echo "No service found for PID $1"
        fi
    }

    check_and_stop_service() {
        local PORT_PIDS=$(lsof -i:"$1" | awk '/LISTEN/ {print $2}')

        for PID in $PORT_PIDS; do
            stop_service "$PID"
        done
    }

    check_and_stop_service 80
    check_and_stop_service 443
    certbot certonly --standalone --agree-tos --register-unsafely-without-email -d "$DOMAIN"

    if [[ $? -eq 0 ]]; then
        echo "Certificate generated successfully"
    else
        if [ "$SERVICE_TYPE" == "ws" ]; then
            rm -f /usr/bin/WS
            rm -rf /etc/ws
            rm -f /etc/systemd/system/WS.service
        elif [ "$SERVICE_TYPE" == "naive" ]; then
            rm -f /usr/bin/NS
            rm -rf /etc/naive
            rm -f /etc/systemd/system/NS.service
        elif [ "$SERVICE_TYPE" == "grpc" ]; then
            rm -f /usr/bin/GS
            rm -rf /etc/grpc
            rm -f /etc/systemd/system/GS.service    
        fi

        systemctl daemon-reload

        for SERVICE in "${RESTART_SERVICES[@]}"; do
            systemctl start "$SERVICE"
        done

        echo "Certificate generation failed!"
        exit 1
    fi

    for SERVICE in "${RESTART_SERVICES[@]}"; do
        systemctl start "$SERVICE"
    done
}

get_selfsigned_cert() {
    protocol="$1"
    mkdir /root/selfcert && cd /root/selfcert || exit
    openssl genrsa -out ca.key 2048
    openssl req -new -x509 -days 3650 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Google, Inc./CN=Google Root CA" -out ca.crt
    openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Google, Inc./CN=*.google.com" -out server.csr
    openssl x509 -req -extfile <(printf "subjectAltName=DNS:google.com,DNS:www.google.com") -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
    mv server.crt /etc/$protocol/server.crt
    mv server.key /etc/$protocol/server.key
    cd || exit
    rm -rf /root/selfcert
}

install_core() {
    Protocol="$1"
    mkdir /root/singbox && cd /root/singbox || exit
    LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
    LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
    LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-arm64.tar.gz"
    wget "$LINK"
    tar -xf "sing-box-${LATEST_VERSION}-linux-arm64.tar.gz"
    cp "sing-box-${LATEST_VERSION}-linux-arm64/sing-box" "/usr/bin/$Protocol"
    cd && rm -rf singbox
}

set_ufw() {
    protocol="$1"

    if ufw status | grep -q "Status: active"; then
        ufw disable

        if [ "$protocol" == "tcp" ]; then
            ufw allow "$user_port"
        elif [ "$protocol" == "udp" ]; then
            ufw allow "$user_port"/udp
        fi

        sleep 0.5
        echo "y" | ufw enable
        ufw reload
        echo 'UFW is Optimized.'
        sleep 0.5
    else
        echo "UFW is not active"
    fi
}

add_hysteria_user() {
    config_file="/etc/hysteria2/server.json"

    if [ -e "$config_file" ]; then
        name_regex="^[A-Za-z0-9]+$"
        name=$(whiptail --inputbox "Enter the user's name:" 10 30 2>&1 >/dev/tty)

        if [[ "$name" =~ $name_regex ]]; then
            user_exists=$(jq --arg name "$name" '.inbounds[0].users | map(select(.name == $name)) | length' "$config_file")

            if [ "$user_exists" -eq 0 ]; then
                password=$(openssl rand -hex 8)

                jq --arg name "$name" --arg password "$password" '.inbounds[0].users += [{"name": $name, "password": $password}]' "$config_file" >tmp_config.json
                mv tmp_config.json "$config_file"

                systemctl restart SH

                whiptail --msgbox "User added successfully!" 10 30
                clear
            else
                whiptail --msgbox "User already exists!" 10 30
                clear
            fi
        else
            whiptail --msgbox "Invalid characters. Use only A-Z and 0-9." 10 30
            clear
        fi
    else
        whiptail --msgbox "Hysteria2 is not installed yet." 10 30
        clear
    fi
}

remove_hysteria_user() {
    config_file="/etc/hysteria2/server.json"

    if [ -e "$config_file" ]; then
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select a user to remove:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_index=$(echo "$user_choice" | awk '{print $1}')
            jq "del(.inbounds[0].users[$user_index])" "$config_file" >tmp_config.json
            mv tmp_config.json "$config_file"

            systemctl restart SH

            whiptail --msgbox "User removed successfully!" 10 30
            clear
        fi
    else
        whiptail --msgbox "Hysteria2 is not installed yet." 10 30
        clear
    fi
}

add_tuic_user() {
    config_file="/etc/tuic/server.json"

    if [ -e "$config_file" ]; then
        name_regex="^[A-Za-z0-9]+$"
        name=$(whiptail --inputbox "Enter the user's name:" 10 30 2>&1 >/dev/tty)

        if [[ "$name" =~ $name_regex ]]; then
            user_exists=$(jq --arg name "$name" '.inbounds[0].users | map(select(.name == $name)) | length' "$config_file")

            if [ "$user_exists" -eq 0 ]; then
                password=$(openssl rand -hex 8)

                uuid=$(cat /proc/sys/kernel/random/uuid)

                jq --arg name "$name" --arg password "$password" --arg uuid "$uuid" '.inbounds[0].users += [{"name": $name, "password": $password, "uuid": $uuid}]' "$config_file" >tmp_config.json
                mv tmp_config.json "$config_file"

                systemctl restart TS

                whiptail --msgbox "User added successfully!" 10 30
                clear
            else
                whiptail --msgbox "User already exists!" 10 30
                clear
            fi
        else
            whiptail --msgbox "Invalid characters. Use only A-Z and 0-9." 10 30
            clear
        fi
    else
        whiptail --msgbox "TUIC is not installed yet." 10 30
        clear
    fi
}

remove_tuic_user() {
    config_file="/etc/tuic/server.json"

    if [ -e "$config_file" ]; then
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select a user to remove:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_index=$(echo "$user_choice" | awk '{print $1}')
            jq "del(.inbounds[0].users[$user_index])" "$config_file" >tmp_config.json
            mv tmp_config.json "$config_file"

            systemctl restart TS

            whiptail --msgbox "User removed successfully!" 10 30
            clear
        fi
    else
        whiptail --msgbox "TUIC is not installed yet." 10 30
        clear
    fi
}

add_reality_user() {
    config_file="/etc/reality/config.json"

    if [ -e "$config_file" ]; then
        name_regex="^[A-Za-z0-9]+$"
        name=$(whiptail --inputbox "Enter the user's name:" 10 30 2>&1 >/dev/tty)

        if [[ "$name" =~ $name_regex ]]; then
            user_exists=$(jq --arg name "$name" '.inbounds[0].users | map(select(.name == $name)) | length' "$config_file")

            if [ "$user_exists" -eq 0 ]; then
                uuid=$(cat /proc/sys/kernel/random/uuid)
                transport_exists=$(jq '.inbounds[0].transport' "$config_file")
                type_value=$(jq -r '.inbounds[0].transport.type' "$config_file")

                if [ -z "$transport_exists" ] || ([ -n "$transport_exists" ] && [ "$type_value" != "grpc" ]); then
                    jq --arg name "$name" --arg uuid "$uuid" '.inbounds[0].users += [{"name": $name, "uuid": $uuid, "flow": "xtls-rprx-vision"}]' "$config_file" >tmp_config.json
                elif [ -n "$transport_exists" ] && [ "$type_value" = "grpc" ]; then
                    jq --arg name "$name" --arg uuid "$uuid" '.inbounds[0].users += [{"name": $name, "uuid": $uuid}]' "$config_file" >tmp_config.json
                fi

                mv tmp_config.json "$config_file"
                systemctl restart RS
                whiptail --msgbox "User added successfully!" 10 30
                clear
            else
                whiptail --msgbox "User already exists!" 10 30
                clear
            fi
        else
            whiptail --msgbox "Invalid characters. Use only A-Z and 0-9." 10 30
            clear
        fi
    else
        whiptail --msgbox "Reality is not installed yet." 10 30
        clear
    fi
}

remove_reality_user() {
    config_file="/etc/reality/config.json"

    if [ -e "$config_file" ]; then
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select a user to remove:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_index=$(echo "$user_choice" | awk '{print $1}')
            jq "del(.inbounds[0].users[$user_index])" "$config_file" >tmp_config.json
            mv tmp_config.json "$config_file"

            systemctl restart RS

            whiptail --msgbox "User removed successfully!" 10 30
            clear
        fi
    else
        whiptail --msgbox "Reality is not installed yet." 10 30
        clear
    fi
}

add_shadowtls_user() {
    config_file="/etc/shadowtls/config.json"

    if [ -e "$config_file" ]; then
        name_regex="^[A-Za-z0-9]+$"
        name=$(whiptail --inputbox "Enter the user's name:" 10 30 2>&1 >/dev/tty)

        if [[ "$name" =~ $name_regex ]]; then
            user_exists=$(jq --arg name "$name" '.inbounds[0].users | map(select(.name == $name)) | length' "$config_file")

            if [ "$user_exists" -eq 0 ]; then
                password=$(openssl rand -hex 8)

                jq --arg name "$name" --arg password "$password" '.inbounds[0].users += [{"name": $name, "password": $password}]' "$config_file" >tmp_config.json
                mv tmp_config.json "$config_file"

                systemctl restart ST

                whiptail --msgbox "User added successfully!" 10 30
                clear
            else
                whiptail --msgbox "User already exists!" 10 30
                clear
            fi
        else
            whiptail --msgbox "Invalid characters. Use only A-Z and 0-9." 10 30
            clear
        fi
    else
        whiptail --msgbox "ShadowTLS is not installed yet." 10 30
        clear
    fi
}

remove_shadowtls_user() {
    config_file="/etc/shadowtls/config.json"

    if [ -e "$config_file" ]; then
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select a user to remove:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_index=$(echo "$user_choice" | awk '{print $1}')
            jq "del(.inbounds[0].users[$user_index])" "$config_file" >tmp_config.json
            mv tmp_config.json "$config_file"

            systemctl restart ST

            whiptail --msgbox "User removed successfully!" 10 30
            clear
        fi
    else
        whiptail --msgbox "ShadowTLS is not installed yet." 10 30
        clear
    fi
}

add_ws_user() {
    config_file="/etc/ws/config.json"

    if [ -e "$config_file" ]; then
        name_regex="^[A-Za-z0-9]+$"
        name=$(whiptail --inputbox "Enter the user's name:" 10 30 2>&1 >/dev/tty)

        if [[ "$name" =~ $name_regex ]]; then
            user_exists=$(jq --arg name "$name" '.inbounds[0].users | map(select(.name == $name)) | length' "$config_file")

            if [ "$user_exists" -eq 0 ]; then
                uuid=$(cat /proc/sys/kernel/random/uuid)

                jq --arg name "$name" --arg uuid "$uuid" '.inbounds[0].users += [{"name": $name, "uuid": $uuid}]' "$config_file" >tmp_config.json
                mv tmp_config.json "$config_file"

                systemctl restart WS

                whiptail --msgbox "User added successfully!" 10 30
                clear
            else
                whiptail --msgbox "User already exists!" 10 30
                clear
            fi
        else
            whiptail --msgbox "Invalid characters. Use only A-Z and 0-9." 10 30
            clear
        fi
    else
        whiptail --msgbox "WebSocket is not installed yet." 10 30
        clear
    fi
}

remove_ws_user() {
    config_file="/etc/ws/config.json"

    if [ -e "$config_file" ]; then
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select a user to remove:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_index=$(echo "$user_choice" | awk '{print $1}')
            jq "del(.inbounds[0].users[$user_index])" "$config_file" >tmp_config.json
            mv tmp_config.json "$config_file"

            systemctl restart WS

            whiptail --msgbox "User removed successfully!" 10 30
            clear
        fi
    else
        whiptail --msgbox "WebSocket is not installed yet." 10 30
        clear
    fi
}

add_grpc_user() {
    config_file="/etc/grpc/config.json"

    if [ -e "$config_file" ]; then
        name_regex="^[A-Za-z0-9]+$"
        name=$(whiptail --inputbox "Enter the user's name:" 10 30 2>&1 >/dev/tty)

        if [[ "$name" =~ $name_regex ]]; then
            user_exists=$(jq --arg name "$name" '.inbounds[0].users | map(select(.name == $name)) | length' "$config_file")

            if [ "$user_exists" -eq 0 ]; then
                uuid=$(cat /proc/sys/kernel/random/uuid)

                jq --arg name "$name" --arg uuid "$uuid" '.inbounds[0].users += [{"name": $name, "uuid": $uuid}]' "$config_file" >tmp_config.json
                mv tmp_config.json "$config_file"

                systemctl restart GS

                whiptail --msgbox "User added successfully!" 10 30
                clear
            else
                whiptail --msgbox "User already exists!" 10 30
                clear
            fi
        else
            whiptail --msgbox "Invalid characters. Use only A-Z and 0-9." 10 30
            clear
        fi
    else
        whiptail --msgbox "gRPC is not installed yet." 10 30
        clear
    fi
}

remove_grpc_user() {
    config_file="/etc/grpc/config.json"

    if [ -e "$config_file" ]; then
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.name)"' "$config_file")
        user_choice=$(whiptail --menu "Select a user to remove:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_index=$(echo "$user_choice" | awk '{print $1}')
            jq "del(.inbounds[0].users[$user_index])" "$config_file" >tmp_config.json
            mv tmp_config.json "$config_file"

            systemctl restart GS

            whiptail --msgbox "User removed successfully!" 10 30
            clear
        fi
    else
        whiptail --msgbox "gRPC is not installed yet." 10 30
        clear
    fi
}

add_naive_user() {
    config_file="/etc/naive/config.json"

    if [ -e "$config_file" ]; then
        name_regex="^[A-Za-z0-9]+$"
        name=$(whiptail --inputbox "Enter the user's name:" 10 30 2>&1 >/dev/tty)

        if [[ "$name" =~ $name_regex ]]; then
            user_exists=$(jq --arg name "$name" '.inbounds[0].users | map(select(.username == $name)) | length' "$config_file")

            if [ "$user_exists" -eq 0 ]; then
                password=$(openssl rand -hex 8)

                jq --arg username "$name" --arg password "$password" '.inbounds[0].users += [{"username": $username, "password": $password}]' "$config_file" >tmp_config.json && mv tmp_config.json "$config_file"

                systemctl restart NS

                whiptail --msgbox "User added successfully!" 10 30
                clear
            else
                whiptail --msgbox "User already exists!" 10 30
                clear
            fi
        else
            whiptail --msgbox "Invalid characters. Use only A-Z and 0-9." 10 30
            clear
        fi
    else
        whiptail --msgbox "Naive is not installed yet." 10 30
        clear
    fi
}

remove_naive_user() {
    config_file="/etc/naive/config.json"

    if [ -e "$config_file" ]; then
        users=$(jq -r '.inbounds[0].users | to_entries[] | "\(.key) \(.value.username)"' "$config_file")
        user_choice=$(whiptail --menu "Select a user to remove:" 25 50 10 $users 2>&1 >/dev/tty)

        if [ -n "$user_choice" ]; then
            user_index=$(echo "$user_choice" | awk '{print $1}')
            jq "del(.inbounds[0].users[$user_index])" "$config_file" >tmp_config.json
            mv tmp_config.json "$config_file"

            systemctl restart NS

            whiptail --msgbox "User removed successfully!" 10 30
            clear
        fi
    else
        whiptail --msgbox "Naive is not installed yet." 10 30
        clear
    fi
}
