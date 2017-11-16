#!/usr/bin/env bash
##-------------------------------------------------------------------
## @copyright 2017 DennyZhang.com
## Licensed under MIT 
##   https://www.dennyzhang.com/wp-content/mit_license.txt
##
## File: run_chef_solo.sh
## Author : Denny <https://www.dennyzhang.com/contact>
## Description :
## --
## Created : <2017-11-15>
## Updated: Time-stamp: <2017-11-16 00:02:43>
##-------------------------------------------------------------------
set -e

function log() {
    local msg=$*
    date_timestamp=$(date +['%Y-%m-%d %H:%M:%S'])
    echo -ne "$date_timestamp $msg\n"
    
    if [ -n "$LOG_FILE" ]; then
        echo -ne "$date_timestamp $msg\n" >> "$LOG_FILE"
    fi
}

function get_community_cookbook(){
    log "get community cookbook"
    berks_cookbook_folder=${1?}
    cookbook_folder=${2?}
    cd "$cookbook_folder"
    mkdir -p "$berks_cookbook_folder"
    berks vendor "$berks_cookbook_folder"
    ls -lth "$berks_cookbook_folder"
}

function run_chef_solo() {
    berks_cookbook_folder=${1?}
    cookbook_folder=${2?}
    cookbook_name=${3?}
    cat > solo.rb << EOF
cookbook_path [File.expand_path(File.join(File.dirname(__FILE__), '..', "cookbooks")), '$berks_cookbook_folder']
EOF
    cat > node.json <<EOF
{
  "run_list": [ "recipe[$cookbook_name]" ]
}
EOF
    log "Apply chef update"
    chef-solo -c solo.rb -j node.json
}

[ -d /home/ec2-user/log ] || mkdir -p /home/ec2-user/log
LOG_FILE="/home/ec2-user/log/run_chef_solo.log"

# TODO: customize this
cookbook_name=${1:-"jenkins-demo-101"}
cookbook_folder="/home/ec2-user/${cookbook_name}"

get_community_cookbook "/tmp/berks_cookbooks" "$cookbook_folder"
run_chef_solo "/tmp/berks_cookbooks" "$cookbook_folder" "$cookbook_name"
## File: run_chef_solo.sh ends
