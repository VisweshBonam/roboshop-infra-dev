#!/bin/bash

component=$1
env=$2

dnf install ansible -y

ansible-pull -U https://github.com/VisweshBonam/ansible-roboshop-roles-tf.git -e component=$1 -e env=$2 "$1.yaml"