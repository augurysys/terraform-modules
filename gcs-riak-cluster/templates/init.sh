#!/bin/bash

if [ ! -d /mnt/disks/local-ssd ]; then\
  sudo yum install mdadm -y;\
  sudo mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sdb /dev/sdc
  sudo mkdir -p /mnt/disks/local-ssd;\
  sudo mkfs.ext4 -F /dev/md0;\
  sudo mount -o discard,defaults /dev/md0 /mnt/disks/local-ssd;\
  sudo chmod a+w /mnt/disks/local-ssd;\
  echo UUID=`sudo blkid -s UUID -o value /dev/md0` /mnt/disks/local-ssd ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab 
fi;\


sudo /bin/sh -c 'echo "riak soft nofile 65536" >> /etc/security/limits.conf'; \
sudo /bin/sh -c 'echo "riak hard nofile 200000" >> /etc/security/limits.conf'; \
sudo /bin/sh -c 'echo "ulimit -n 200000" >> /etc/default/riak'

sudo yum install -y wget; \
sudo yum install -y java-1.8.0-openjdk; \
wget http://s3.amazonaws.com/downloads.basho.com/riak_ts/1.5/1.5.2/rhel/7/riak-ts-1.5.2-1.el7.centos.x86_64.rpm; \
sudo yum install riak-ts-1.5.2-1.el7.centos.x86_64.rpm -y

LOCAL_IP=`curl http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip -H "Metadata-Flavor: Google"`

sudo tee /etc/riak/riak.conf << EOM
log.console = file
log.console.level = info
log.console.file = \$(platform_log_dir)/console.log
log.error.file = \$(platform_log_dir)/error.log
log.syslog = off
log.crash = on
log.crash.file = \$(platform_log_dir)/crash.log
log.crash.maximum_message_size = 64KB
log.crash.size = 10MB
log.crash.rotation = \$D0
log.crash.rotation.keep = 5
nodename = riak@$LOCAL_IP
distributed_cookie = riak
erlang.async_threads = 64
erlang.max_ports = 262144
dtrace = off
platform_bin_dir = /usr/sbin
platform_data_dir = /mnt/disks/local-ssd
platform_etc_dir = /etc/riak
platform_lib_dir = /usr/lib64/riak/lib
platform_log_dir = /var/log/riak
listener.http.internal = ${LOCAL_IP}:8098
listener.protobuf.internal = ${LOCAL_IP}:8087
anti_entropy = active
storage_backend = leveldb
object.format = 1
object.size.warning_threshold = 5MB
object.size.maximum = 50MB
object.siblings.warning_threshold = 25
object.siblings.maximum = 100
bitcask.data_root = \$(platform_data_dir)/bitcask
bitcask.io_mode = erlang
riak_control = off
riak_control.auth.mode = off
leveldb.maximum_memory.percent = 90
leveldb.compression = on
leveldb.compression.algorithm = lz4
search = on
search.solr.start_timeout = 30s
search.solr.port = 8093
search.solr.jmx_port = 8985
search.solr.jvm_options = -d64 -Xms3g -Xmx3g -XX:+UseStringCache -XX:+UseCompressedOops
EOM


# Install docker
sudo yum install -y yum-utils \
device-mapper-persistent-data \
lvm2
sudo yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl enable docker
sudo systemctl start docker

sudo tee /etc/systemd/system/riak-exporter.service << EOM
[Unit]
Description=Promethus exporter for Riak metrics
After=docker.service

[Service]
TimeoutStartSec=0
EnvironmentFile=/etc/environment
ExecStartPre=-/usr/bin/docker stop riak-exporter 
ExecStartPre=-/usr/bin/docker rm -f riak-exporter
ExecStartPre=-/usr/bin/docker pull augury/prom-riak-exporter
ExecStart=/usr/bin/docker run --rm --name=riak-exporter -p :3000 -l SERVICE_NAME=prometheus-riak-exporter augury/prom-riak-exporter -target http://${LOCAL_IP}:8098
ExecStop=/usr/bin/docker stop riak-exporter
Restart=always
RestartSec=5
SyslogIdentifier=riak-exporter

[Install]
WantedBy=multi-user.target
EOM

sudo systemctl enable riak-exporter
sudo systemctl start riak-exporter

sudo systemctl enable riak
sudo service riak start

sudo yum install byobu -y --enablerepo=epel-testing
