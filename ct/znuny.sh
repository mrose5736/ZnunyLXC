#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Antigravity
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://www.znuny.org/

## App Default Values
APP="Znuny"
var_tags="${var_tags:-ticketing;itsm}"
var_disk="${var_disk:-20}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-4096}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/znuny ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  msg_error "Znuny should be updated via the command line as per official documentation."
  exit
}

start
GITHUB_REPO="mrose5736/ZnunyLXC"
BRANCH="main"
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN} ${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}/znuny/index.pl${CL}"
echo -e "${INFO}${YW} Default credentials:${CL}"
echo -e "${TAB}${YW}Username: root@localhost${CL}"
echo -e "${TAB}${YW}Password: root${CL}"
