#!/bin/bash

sudo dnf install ansible -y

component=$1
environment=$2

ansible-pull -U https://github.com/VisweshBonam/ansible-roboshop-roles-tf.git -e env=$2 "${component}.yaml"
