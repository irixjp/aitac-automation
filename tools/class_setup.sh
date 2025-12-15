#!/bin/bash -xe

set -e

# 引数の数をチェック
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 class_id student_num  dockerhub_username dockerhub_password"
    exit 1
fi

# 引数を変数にセット
class_id=$1
student_num=$2
dockerhub_username=$3
dockerhub_password=$4

# 変数の表示（必要に応じて）
echo "Class ID: $class_id"
echo "Student Num: $student_num"
echo "Docker Hub Username: $dockerhub_username"
echo "Docker Hub Password: $dockerhub_password"

ansible-playbook -i ec2_inventory ec2_instance_create.yml -e "class_id=${class_id}" -e "instance_num=${student_num}"

ansible-playbook -i ${class_id}_podman_inventory podman_install.yml

ansible-playbook -i ${class_id}_podman_inventory podman_container_deploy.yml -e "reg_username=${dockerhub_username}" -e "reg_password=${dockerhub_password}"

ansible-playbook -i ${class_id}_podman_inventory distributing_contents.yml

ansible-playbook -i nginx_inventory -i ${class_id}_class_env_info.txt nginx_class_config.yml -e "class_id=${class_id}"

