address = "219.100.37.134"
#Install
sudo apt-get update > /dev/null
sudo apt-get -y install strongswan xl2tpd net-tools > /dev/null
#StrongSwan
sudo curl -s -L -o /etc/ipsec.conf https://raw.githubusercontent.com/IT12666/subs_translate/Test/ipsec.conf
sed -ri "s!n.n.n.n!$address!g" /etc/ipsec.conf 
!echo ': PSK "vpn"' > /etc/ipsec.secrets
#xl2tpd-1
sudo curl -s -L -o /etc/tmp.conf https://raw.githubusercontent.com/IT12666/subs_translate/Test/xl2tpd.conf
sudo cat /etc/tmp.conf >> /etc/xl2tpd/xl2tpd.conf
sed -ri "s!n.n.n.n!$address!g" /etc/xl2tpd/xl2tpd.conf
rm -f /etc/tmp.conf
#xl2tpd-2
sudo curl -s -L -o /etc/ipsec.conf https://raw.githubusercontent.com/IT12666/subs_translate/Test/ipsec.conf
sudo cat /etc/ipsec.conf
#Connect
sudo mkdir -p /var/run/xl2tpd && sudo touch /var/run/xl2tpd/l2tp-control
sudo service xl2tpd restart && sudo service ipsec restart && sleep 8
sudo ipsec up L2TP-PSK && sleep 8
sudo bash -c 'echo "c myVPN" > /var/run/xl2tpd/l2tp-control' && sleep 8
ifconfig
