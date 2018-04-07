#!/bin/bash

MAINDIR="/usr/local/deepin-xwall"

generate_chnroute() {
  sudo ipset create chnroute hash:net maxelem 65536
  wget -qO- http://ftp.apnic.net/stats/apnic/delegated-apnic-latest | awk -F '|' '/CN/&&/ipv4/ {print $4 "/" 32-log($5)/log(2)}' | cat > chnroute.txt
  for ip in $(cat chnroute.txt); do
    sudo ipset add chnroute $ip
  done

  rm -f chnroute.txt

  sudo ipset save -f chnroute.ipset
  sudo ipset destroy chnroute
}

initial() {
  sudo mkdir -p $MAINDIR/{sbin,etc,data}
  sudo cp -f bin.sh $MAINDIR/sbin/xwall
  sudo sed -i "s?{MAINDIR}?$MAINDIR?g" $MAINDIR/sbin/xwall
  sudo chmod +x $MAINDIR/sbin/xwall

  sudo apt-get install -y wget shadowsocks-libev ipset > /dev/null
  sudo cp -f stubs/deepin-xwall.service.stub /lib/systemd/system/deepin-xwall.service
  sudo sed -i "7s/{SERVER_IP}/$1/" /lib/systemd/system/deepin-xwall.service
  sudo sed -i "s?{MAINDIR}?$MAINDIR?g" /lib/systemd/system/deepin-xwall.service
  sudo systemctl daemon-reload

  sudo cp -f stubs/shadowsocks.json.stub $MAINDIR/etc/shadowsocks.json
  sudo sed -i "2s/{SERVER_IP}/$1/" $MAINDIR/etc/shadowsocks.json
  sudo sed -i "3s/{SERVER_PORT}/$2/" $MAINDIR/etc/shadowsocks.json
  sudo sed -i "5s/{PASSWORD}/$3/" $MAINDIR/etc/shadowsocks.json
  sudo sed -i "7s/{METHOD}/$4/" $MAINDIR/etc/shadowsocks.json

  generate_chnroute
  sudo cp -f chnroute.ipset $MAINDIR/data

  echo 'done'
  echo '> now executes "sudo systemctl start deepin-xwall" to launch xwall service.'
}

destroy() {
  sudo systemctl stop deepin-xwall
  sudo systemctl disable deepin-xwall
  sudo rm -f /lib/systemd/system/deepin-xwall.service
  sudo systemctl daemon-reload
  # sudo apt remove -y shadowsocks-libev
  sudo rm -rf $MAINDIR
}

usage() {
  echo 'Usage: xwall {install,uninstall}'
  echo '    install {server_ip} {server_port} {password} {method}     Install deepin-xwall service with Shadowsocks server.'
  echo '    uninstall                                                 Uninstall deepin-xwall service.'
}

case "$1" in
  "install" )
    if [[ $# -ne 5 ]]; then
      usage
      exit
    fi
    initial $2 $3 $4 $5
    ;;
  "uninstall" )
    destroy
    ;;
  *)
    usage
    ;;
esac
