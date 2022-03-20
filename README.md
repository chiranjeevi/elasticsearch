# elasticsearch
Setup AWS ES with filebeat to push logs

- Create an AWS ES and an EC2 instance
- Created an AWS ES cluster with public and allowed access to given below EC2 instance to avoid authentication/authorization setup, but make sure you setup prod grade with SAML/Cognito authentication
- Install filebeat on EC2 and push the logs to AWS ES without logstash
- Versions used:
  AWS ES: v7.10.0
  FileBeat: filebeat-7.12.1-linux-x86_64
  
Download the OSS filebeat from https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.10.0-linux-x86_64.tar.gz on linux instance
Configure the filebeat.yaml file as below
```
setup.ilm.enabled: false
setup.template.enabled: false
output.elasticsearch:
  hosts: ["search-xxxx-n2p2gwbr5xybaqw37cdqxb4yqy.us-east-1.es.amazonaws.com:443"]
  protocol: "https"
  index: "demologs-%{+yyyy.MM.dd}"
```
Make sure the extracted filebeat dir has root access
`chown -R root:root filebeat-7.12.1-linux-x86_64`
Run the below command to start filebeat service
`sudo  ./filebeat -e -c filebeat.yml`
Observe for below line in logs to see sucessfull connection to AWS ES
`[publisher_pipeline_output]     pipeline/output.go:151  Connection to backoff(elasticsearch(https://search-xxxx-n2p2gwbr5xybaqw37cdqxb4yqy.us-east-1.es.amazonaws.com:443)) established
`
