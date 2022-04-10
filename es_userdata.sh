#!/bin/bash

echo "Install Filebeat"
wget -O /root/filebeat-7.10.0-linux-x86_64.tar.gz https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.10.0-linux-x86_64.tar.gz

tar -zxvf /root/filebeat-7.10.0-linux-x86_64.tar.gz -C /root/
cd /root/filebeat-7.10.0-linux-x86_64
#tar -zxvf /root/filebeat-oss-7.12.1-linux-x86_64.tar.gz -C /root/
sed -i 's/localhost:9200/${es_cluster}:443/g' /root/filebeat-7.12.1-linux-x86_64/filebeat.yml
sed -i 's/#protocol: \"https\"/protocol: \"https\"/g' /root/filebeat-7.12.1-linux-x86_64/filebeat.yml
systemctl start jenkins
echo "setup.ilm.enabled: false" >> /root/filebeat-7.12.1-linux-x86_64/filebeat.yml
echo "setup.template.enabled: false" >> /root/filebeat-7.12.1-linux-x86_64/filebeat.yml
/root/filebeat-7.12.1-linux-x86_64/filebeat modules enable system
/root/filebeat-7.12.1-linux-x86_64/filebeat -e -c /root/filebeat-7.12.1-linux-x86_64/filebeat.yml &

echo "successgully installed Filebeat"

echo "Intall Packetbeat"
wget -O /root/packetbeat-oss-7.12.1-linux-x86_64.tar.gz https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-oss-7.12.1-linux-x86_64.tar.gz
tar -zxvf /root/packetbeat-oss-7.12.1-linux-x86_64.tar.gz
Update packetbeat.yaml 
setup.ilm.enabled: false
setup.pack.security.enabled: false
setup.xpack.graph.enabled: false
setup.xpack.watcher.enabled: false
setup.xpack.monitoring.enabled: false
setup.xpack.reporting.enabled: false

output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["search-test-xmuccn2ie224hszu56noofp6ti.us-east-1.es.amazonaws.com:443"]

  # Protocol - either `http` (default) or `https`.
  protocol: "https"
  #
start service
./packetbeat -e


./packetbeat -e -c packetbeat.yml  -I archivo.pcap -d "publish"
#----- Install tshark----
apt-get install wireshark
tshark --help