#!/bin/bash

up() {
  sudo ipset restore -f {MAINDIR}/data/chnroute.ipset

  sudo iptables -t nat -N SHADOWSOCKS

  # Allow connection to the server
  sudo iptables -t nat -A SHADOWSOCKS -d "$1" -j RETURN

  # Allow connection to reserved networks
  sudo iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
  sudo iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
  sudo iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
  sudo iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
  sudo iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
  sudo iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
  sudo iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
  sudo iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN

  # Allow connection to chinese IPs
  sudo iptables -t nat -A SHADOWSOCKS -p tcp -m set --match-set chnroute dst -j RETURN
  sudo iptables -t nat -A SHADOWSOCKS -p udp -m set --match-set chnroute dst -j RETURN
  sudo iptables -t nat -A SHADOWSOCKS -p icmp -m set --match-set chnroute dst -j RETURN

  # Redirect to Shadowsocks
  sudo iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-port 1080
  sudo iptables -t nat -A SHADOWSOCKS -p udp -j REDIRECT --to-port 1080
  sudo iptables -t nat -A SHADOWSOCKS -p icmp -j REDIRECT --to-port 1080

  # 将SHADOWSOCKS链中所有的规则追加到OUTPUT链中
  sudo iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS
  sudo iptables -t nat -A OUTPUT -p udp -j SHADOWSOCKS
  sudo iptables -t nat -A OUTPUT -p icmp -j SHADOWSOCKS
}

down() {
  sudo iptables -t nat -D OUTPUT -p icmp -j SHADOWSOCKS
  sudo iptables -t nat -D OUTPUT -p udp -j SHADOWSOCKS
  sudo iptables -t nat -D OUTPUT -p tcp -j SHADOWSOCKS
  sudo iptables -t nat -F SHADOWSOCKS
  sudo iptables -t nat -X SHADOWSOCKS
  sudo ipset destroy chnroute
}

case $1 in
  "start" )
    up $2
    ;;
  "stop" )
    down
    ;;
  * )
    echo "usage: xwall {start,stop}"
    echo "    start {server_ip}   Run Xwall service with shadowsocks server address."
    echo "    stop                Shutdown Xwall service."
    ;;
esac