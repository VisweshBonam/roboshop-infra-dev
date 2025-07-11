#!/bin/bash

dnf install ansible -y
component=$1
env=$2

ansible-pull -U https://github.com/VisweshBonam/ansible-roboshop-roles-tf.git -e component=$1 -e env=$2 "${component}.yaml"
