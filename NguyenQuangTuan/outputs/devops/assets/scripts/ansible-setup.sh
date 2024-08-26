#!/bin/bash

# Install required packages
sudo apt update
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Install Ansible via pip
sudo apt install -y python3-pip
sudo pip3 install ansible