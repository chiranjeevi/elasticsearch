#!/bin/bash

echo "Install Filebeat"
wget -O /root/ https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.10.0-linux-x86_64.tar.gz

tar -zxvf filebeat-7.10.0-linux-x86_64.tar.gz
cd /root/filebeat-7.10.0-linux-x86_64
tar -zxvf /root/filebeat-oss-7.12.1-linux-x86_64.tar.gz -C /root/
sed -i 's/localhost:9200/${es_cluster}:443/g' /root/filebeat-7.12.1-linux-x86_64/filebeat.yml
sed -i 's/#protocol: \"https\"/protocol: \"https\"/g' /root/filebeat-7.12.1-linux-x86_64/filebeat.yml
systemctl start jenkins
echo "setup.ilm.enabled: false" >> /root/filebeat-7.12.1-linux-x86_64/filebeat.yml
echo "setup.template.enabled: false" >> /root/filebeat-7.12.1-linux-x86_64/filebeat.yml
/root/filebeat-7.12.1-linux-x86_64/filebeat modules enable system
/root/filebeat-7.12.1-linux-x86_64/filebeat -e -c /root/filebeat-7.12.1-linux-x86_64/filebeat.yml &

echo "successgully installed Filebeat"



