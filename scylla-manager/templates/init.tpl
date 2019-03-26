#!/bin/bash

sudo yum install epel-release wget -y
sudo wget -O /etc/yum.repos.d/scylla.repo http://repositories.scylladb.com/scylla/repo/79ea3dc7-f84d-49e4-8ec8-541b566a73d7/centos/scylladb-2018.1.repo
sudo curl -o /etc/yum.repos.d/scylla-manager.repo -L http://repositories.scylladb.com/scylla/repo/7ca049ac-45bc-49d8-a522-30764eb95fae/centos/scylladb-manager-1.3.repo
sudo yum install scylla-enterprise -y
sudo scylla_io_setup
sudo yum install scylla-manager-server scylla-manager-client -y

sudo systemctl enable scylla-server
sudo systemctl start scylla-server

sudo systemctl enable scylla-manager
sudo systemctl start scylla-manager

sudo mkdir -p /home/scylla-manager
echo "${service_account_json}" | base64 --decode > /home/scylla-manager/service-account.json
sudo chown -R scylla-manager:scylla-manager /home/scylla-manager

sudo usermod --shell /bin/bash scylla-manager

sudo su scylla-manager -c '/bin/gcloud auth activate-service-account --key-file=/home/scylla-manager/service-account.json'
sudo su scylla-manager -c '/bin/gcloud compute --quiet --project "production-02cb28ec" ssh --zone "us-east1-b" "scylladb-production-1" -- exit'
sudo su scylla-manager -c '/bin/gcloud compute --quiet --project "production-02cb28ec" ssh --zone "us-east1-c" "scylladb-production-2" -- exit'
sudo su scylla-manager -c '/bin/gcloud compute --quiet --project "production-02cb28ec" ssh --zone "us-east1-d" "scylladb-production-3" -- exit'
sudo su scylla-manager -c '/bin/gcloud compute --quiet --project "research-150008" ssh --zone "us-east1-b" "scylladb-research-1" -- exit'
sudo su scylla-manager -c '/bin/gcloud compute --quiet --project "research-150008" ssh --zone "us-east1-c" "scylladb-research-2" -- exit'
sudo su scylla-manager -c '/bin/gcloud compute --quiet --project "research-150008" ssh --zone "us-east1-d" "scylladb-research-3" -- exit'

sudo su scylla-manager -c 'scyllamgr_ssh_setup  --manager-user scylla-manager --manager-identity-file /home/scylla-manager/scylla-manager \
--user scylla-manager --identity-file /home/scylla-manager/.ssh/google_compute_engine --discover ${scylladb_node}; \
sctool cluster add --host=${scylladb_node} --name=prod-cluster --ssh-user=scylla-manager --ssh-identity-file=/home/scylla-manager/.ssh/google_compute_engine'
