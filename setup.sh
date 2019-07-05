#!/usr/bin/env bash

# Copyright 2019 The Godu Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

INSTALLER_DIR="$(dirname "${0}")"

[ ! -d "/tmp/install" ] && mkdir -p /tmp/install
[ ! -d "$INSTALLER_DIR/.init" ] && mkdir -p $INSTALLER_DIR/.init

if [ -f "${INSTALLER_DIR}/hack/install/func.sh" ]; then
	source "${INSTALLER_DIR}/hack/install/func.sh" || (
        curl --fail --silent --location -o /tmp/stdlib.sh https://code.godu.dev/godu/func/raw/master/func.sh || {
	        exit 1
        }
        source /tmp/stdlib.sh
        rm /tmp/stdlib.sh
    )
fi

umask 022

sudo=""
[ -z "${UID}" ] && UID="$(id -u)"
[ "${UID}" -ne "0" ] && fatal "only support root(UID 0)"
export PATH="${PATH}:/usr/local/bin:/usr/local/sbin"

while [[ $# -ge 1 ]]; do
    case $1 in
        --imagepre)
            shift
            IMAGE_PREFIX="$1"
            shift
        ;;
        --domain)
            shift
            DOMAIN="$1"
            shift
        ;;
        --cookie)
            shift
            COOKIE_SECRET="$1"
            shift
        ;;
        --token)
            shift
            TOKEN_SECRET="$1"
            shift
        ;;
        --secret)
            shift
            SECRET_KEY="$1"
            shift
        ;;
        --redispwd)
            shift
            REDIS_PASSWORD="$1"
            shift
        ;;
        --dbpwd)
            shift
            DB_PASSWORD="$1"
            shift
        ;;
        --mquser)
            shift
            MQ_USER="$1"
            shift
        ;;
        --mqpwd)
            shift
            MQ_PWD="$1"
            shift
        ;;
        --user)
            shift
            CODO_USER="$1"
            shift
        ;;
        --password)
            shift
            CODO_PASS="$1"
            shift
        ;;
        *)
            echo "Invaild option $1"
            exit 1
        ;;
    esac
done

case "$lsb_dist" in
	ubuntu|debian|centos)
        :
	;;
	*)
        notice "not support $lsb_dist"
	;;
esac

install_cmd(){
    case "$lsb_dist" in
	    ubuntu|debian|centos)
	    	run apt update
            run apt install -y ${@}
            # run pip install -U pip
            # rm -rf /usr/bin/pip
            # ln -s /usr/local/bin/pip /usr/bin/pip
	    ;;
	    centos)
            yum makecache fast 
            yum install epel-release -y
            run yum makecache fast
            run yum install -y ${@}
	    ;;
    esac
}

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

get_default_ip(){
	ip=$(ip addr | grep inet | grep -Ev 'inet6|docker0| lo' | awk '{print $2}' | awk -F/ '{print $1}' | head -1)
	echo ${ip}
}

precheck::check_port(){
    local portlist=(53 80 443 3306 6060)
    local check_fail_num=0
    for port in ${portlist[@]}; do
        netstat -pantu | awk '{print $4}' | awk -F: '{print $2}' | sort -ru | grep "\b$port\b" && ((check_fail_num+=1)) || sleep 1
        if [ "$check_fail_num" != 0 ]; then
            notice "port ${port} is already used"
        fi
    done
    if [ "$check_fail_num" == 0 ]; then
	    touch $INSTALLER_DIR/.init/.port_check
    else
        notice "port is already used, please check port in: ${portlist[@]}"
    fi
}

prepare::check(){
    local HOMEPAGE="https://www.baidu.com"
    if [ "$(uname -m)" != "x86_64" ]; then
        fatal "Static binary versions of codo are available only for 64bit Intel/AMD CPUs (x86_64), but yours is: $(uname -m)."
    fi
    if [ "$(uname -s)" != "Linux" ]; then
    	fatal "Static binary versions of codo are available only for Linux, but this system is $(uname -s)"
    fi
    info "prepare check system" "passed"
    curl -s $HOMEPAGE -o /dev/null 2>/dev/null
    if [ "$?" -eq 0 ]; then
        info "prepare check network" "passed"
    else
        notice "Unable to connect to internet"
    fi
    [ -z "$IP" ] && IP=$( get_default_ip )
    INET_IP=${IP%%.*}
    ip r | grep $IP > /dev/null  && info "prepare check ip $IP" "passed" || notice "Current Node does not exist $IP"
    sed -i "s#172.20.0.101#$IP#g" inventory/hosts
    #sed -i -r  "s/(^codo_core_ip: ).*/\1$IP/" roles/codo/defaults/main.yml
    sed -i "s#172.20.0.101#$IP#g" roles/codo/defaults/main.yml
    if [ "$INET_IP" == "172" ]; then
        echo "$IP" | grep -E '^172.30' && notice "内网ip所在内网IP段与docker0的内网段(172.30.0.0/16)冲突."
    fi
    info "prepare check ip cidr" "passed"
    if [ ! -f "$INSTALLER_DIR/.init/.port_check" ]; then
        precheck::check_port
    fi
    info "prepare check port" "passed"
}

prepare::install(){
    progress "Detect $lsb_dist required packages..."
    install_cmd sshpass python-pip pwgen expect curl net-tools git
    run pip install ansible -i https://pypi.tuna.tsinghua.edu.cn/simple
    [ ! -f "/root/.ssh/id_rsa.pub" ] && ssh-keygen -t rsa -f /root/.ssh/id_rsa -P ""
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
}

prepare::init(){
    [ ! -z "$IMAGE_PREFIX" ] &&  sed -i -r  "s/(^image_pre: ).*/\1$IMAGE_PREFIX/" roles/codo/defaults/main.yml
    [ ! -z "$DOMAIN" ] &&  sed -i -r  "s/ops.talk.com$/$DOMAIN/g" roles/codo/defaults/main.yml
    [ ! -z "$COOKIE_SECRET" ] &&  sed -i -r  "s/(^COOKIE_SECRET: ).*/\1$COOKIE_SECRET/" roles/codo/defaults/main.yml
    [ ! -z "$TOKEN_SECRET" ] &&  sed -i -r  "s/(^TOKEN_SECRET: ).*/\1$TOKEN_SECRET/" roles/codo/defaults/main.yml
    [ ! -z "$REDIS_PASSWORD" ] &&  sed -i -r  "s/(^REDIS_PASSWORD: ).*/\1$REDIS_PASSWORD/" roles/codo/defaults/main.yml
    [ ! -z "$SECRET_KEY" ] &&  sed -i -r  "s/(^SECRET_KEY: ).*/\1$SECRET_KEY/" roles/codo/defaults/main.yml
    [ ! -z "$DB_PASSWORD" ] &&  (
        sed -i -r  "s/(^DEFAULT_DB_DBPWD: ).*/\1$DB_PASSWORD/" roles/codo/defaults/main.yml
        sed -i -r  "s/(^READONLY_DB_DBPWD: ).*/\1$DB_PASSWORD/" roles/codo/defaults/main.yml
        sed -i -r  "s/(^MYSQL_ROOT_PASSWORD: ).*/\1$DB_PASSWORD/" roles/codo/defaults/main.yml
    )
    [ ! -z "$MQ_USER" ] &&  sed -i -r  "s/(^MQ_USER: ).*/\1$MQ_USER/" roles/codo/defaults/main.yml
    [ ! -z "$MQ_PWD" ] &&  sed -i -r  "s/(^MQ_PWD: ).*/\1$MQ_PWD/" roles/codo/defaults/main.yml
    [ ! -z "$CODO_USER" ] &&  sed -i -r  "s/(^CODO_USER: ).*/\1$CODO_USER/" roles/codo/defaults/main.yml
    [ ! -z "$CODO_PASS" ] &&  (
        CODO_PASS_MD5=$(echo -n $CODO_PASS | md5sum | awk '{print $1}')
        sed -i -r  "s/(^CODO_PASS: ).*/\1$CODO_PASS_MD5/" roles/codo/defaults/main.yml
    )
    info "prepare init ok"
}


progress "Prepare check && install"

prepare::check
prepare::install

prepare::init

progress "Installing Codo"

run ansible-playbook -i inventory/hosts setup.yml

progress "Successful installation"

core_ip=$(cat roles/codo/defaults/main.yml | grep codo_core_ip | awk '{print $2}')

info "访问地址:" "ui.${DOMAIN:-ops.talk.com}"
info "访问账号:" "${CODO_USER:-admin}/${CODO_PASS:-12345678}"
info "如无法正常访问,请调整DNS或者添加hosts" "dns: ${core_ip} 或者 hosts: ${core_ip} ui.${DOMAIN:-ops.talk.com}"