# Copyright (c) 2021 Teradici Corporation
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

#!/bin/bash

LOG_FILE="/var/log/teradici/provisioning.log"
CAC_BIN_PATH="/usr/sbin/cloud-access-connector"
INSTALL_DIR="/root"
CAC_INSTALL_LOG="/var/log/teradici/cac-install.log"

#AD_SERVICE_ACCOUNT_USERNAME=${ad_service_account_username}
#AD_SERVICE_ACCOUNT_PASSWORD=${ad_service_account_password}
#CAC_TOKEN=${cac_token}
#PCOIP_REGISTRATION_CODE=${pcoip_registration_code}
#DOMAIN_NAME=${domain_name}
#DOMAIN_CONTROLLER_IP=${domain_controller_ip}
#APPLICATION_ID=${application_id}
#AAD_CLIENT_SECRET=${aad_client_secret}
#TENANT_ID=${tenant_id}

AD_SERVICE_ACCOUNT_USERNAME="sa_teradici"
AD_SERVICE_ACCOUNT_PASSWORD="Avid1234567$"
CAC_TOKEN="eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJjb25uZWN0b3JOYW1lIjoiYWJjMC1jYWMtMDAiLCJvd25lclVwbiI6ImJlbmphbWluLmdoaXNAYXZpZC5jb20iLCJ0ZW5hbnRJZCI6IjY1ODc0ZjlkLWY1YmQtNGQxYS05ZTAwLTFiNGM0OTRjOGFjNCIsIm9pZCI6IjVmNGVkNDIzNThmYjViMDAxM2EzYmEyZCIsImRlcGxveW1lbnRJZCI6IjVmNGVkNDIzYWIzZWJlMDAxMjJiNDAwNyIsIm93bmVyT2lkIjoiMmQ4OGE5YTItOTY2ZS00ZTAxLTg1ZTUtN2M5NDIwNTBiNTRhIiwidG9rZW5UeXBlIjoiY29ubmVjdG9yIiwic2NvcGVzIjp7ImtleXNfdGVuYW50Ijp7ImFjdGlvbnMiOlsiY3JlYXRlIl19fSwianRpIjoiNjZkNDdlMzUtYmEyNC00NWIzLThkMTEtZDcwNzgyMGZlOWNiIiwiaWF0IjoxNjE1MjM4Nzk5LCJleHAiOjE2MTUyNDU5OTl9.NI7h9LbZDHz35DvXJ6c9_qQT-veK7lazq_VuY3zx6x-yNrsrhHgKBoHW4TGH6_rr3GYGsam_D7nrMoRPe_UBmA"
PCOIP_REGISTRATION_CODE="BD8RGL3WLN0Z@2E14-1017-AE71-80FA"
DOMAIN_NAME="abc0.internal"
DOMAIN_CONTROLLER_IP="10.5.0.4"
APPLICATION_ID="tutu"
AAD_CLIENT_SECRET="tutu"
TENANT_ID=""

cd $INSTALL_DIR

log() {
    local message="$1"
    echo "[$(date)] $message"
}

retry() {
    local timeout="$1"
    local interval="$2"
    local command="$3"
    local log_message="$4"
    local err_message="$5"

    until $command
    do
        if [ $timeout -le 0 ]
        then
            log $err_message
            break
        fi

        log "$log_message Retrying in $interval seconds... (Timeout in $timeout seconds)"

        timeout=$((timeout-interval))
        sleep $interval
    done
}

check_connector_installed() {
    if [[ -f "$CAC_BIN_PATH" ]]; then
        log "--> Connector already installed. Skipping provisioning script..."
        exit 0
    fi
}

config_network() {
    if [[ ! -f $PCOIP_NETWORK_CONF_FILE ]]; then
        log "--> Configuring network..."
        # Note the indented HEREDOC lines must be preceded by tabs, not spaces
        cat <<- EOF > $PCOIP_NETWORK_CONF_FILE
			# System Control network settings for CAC
			net.core.rmem_max=160000000
			net.core.rmem_default=160000000
			net.core.wmem_max=160000000
			net.core.wmem_default=160000000
			net.ipv4.udp_mem=120000 240000 600000
			net.core.netdev_max_backlog=2000
			EOF

        sysctl -p $PCOIP_NETWORK_CONF_FILE
    fi
}

install_prereqs() {
    log "--> Installing wget, jq..."
    apt-get -y update
    apt install -y wget jq

    if [ $? -ne 0 ]
    then
        log "--> ERROR: Failed to install prerequisites. Exiting provisioning script..."
        exit 1
    fi
}

get_credentials() {
    if [[ -z "${tenant_id}" ]]; then
        log "Not getting secrets from Azure Key Vault. Exiting get_credentials..."
    else
        set +x
        log "Getting secrets from Azure Key Vault..."
        ACCESS_TOKEN=$(curl -X POST -d "grant_type=client_credentials&client_id=$APPLICATION_ID&client_secret=$AAD_CLIENT_SECRET&resource=https%3A%2F%2Fvault.azure.net" https://login.microsoftonline.com/$TENANT_ID/oauth2/token | jq ".access_token" -r)
        PCOIP_REGISTRATION_CODE=$(curl -X GET -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/json" --url "$PCOIP_REGISTRATION_CODE?api-version=2016-10-01" | jq -r '.value')
        AD_SERVICE_ACCOUNT_PASSWORD=$(curl -X GET -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/json" --url "$AD_SERVICE_ACCOUNT_PASSWORD?api-version=2016-10-01" | jq -r '.value')
        CAC_TOKEN=$(curl -X GET -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/json" --url "$CAC_TOKEN?api-version=2016-10-01" | jq -r '.value')
        set -x
    fi
}

download_cac() {
    log "--> Downloading CAC installer..."
    curl -L ${cac_installer_url} -o $INSTALL_DIR/cloud-access-connector.tar.gz
    tar xzvf $INSTALL_DIR/cloud-access-connector.tar.gz --no-same-owner -C /
}

wait_for_dc() {
    local timeout=25
    local interval=5

    # Wait for service account to be added. Do this last because it takes
    # a while for new AD user to be added in a new Domain Controller.
    # Note: using the domain controller IP instead of the domain name for
    #       the host is more resilient.

    log "--> Updating apt-get package list..."
    retry $timeout \
          $interval \
          "apt-get -qq update" \
          "--> Updating apt-get package list..." \
          "--> ERROR: Failed to update apt-get package list."

    log "--> Installing ldap_utils..."
    retry $timeout \
          $interval \
          "apt-get -qq install ldap-utils" \
          "--> Installing ldap_utils..." \
          "--> ERROR: Failed to install ldap-utils."

    timeout=1200
    interval=10

    set +x
    log "--> Ensure AD account is available..."
    retry $timeout \
          $interval \
          "ldapwhoami \
            -H ldap://$DOMAIN_CONTROLLER_IP \
            -D $AD_SERVICE_ACCOUNT_USERNAME@$DOMAIN_NAME \
            -w $AD_SERVICE_ACCOUNT_PASSWORD \
            -o nettimeout=1" \
          "--> Waiting for AD account $AD_SERVICE_ACCOUNT_USERNAME@$DOMAIN_NAME to become available." \
          "$DOMAIN_CONTROLLER_IP $AD_SERVICE_ACCOUNT_USERNAME@$DOMAIN_NAME $AD_SERVICE_ACCOUNT_PASSWORD "
          "--> ERROR: Timed out waiting for AD account $AD_SERVICE_ACCOUNT_USERNAME@$DOMAIN_NAME to become available. Continuing..."
    set -x
    # Check that the domain name can be resolved and that the LDAP port is accepting
    # connections. This could have been all done with the ldapwhoami command, but
    # due to a number of occasional cac-installation issues, such as "domain
    # controller unreachable" or "DNS error occurred" errors, check these explicitly
    # for logging and debug purposes.
    log "--> Ensure domain $DOMAIN_NAME can be resolved..."
    retry $timeout \
          $interval \
          "host $DOMAIN_NAME" \
          "--> Trying to resolve $DOMAIN_NAME." \
          "--> ERROR: Timed out trying to resolve $DOMAIN_NAME. Continuing..."

    log "--> Ensure domain $DOMAIN_NAME port 636 is reacheable..."
    retry $timeout \
          $interval \
          "netcat -vz $DOMAIN_NAME 636" \
          "--> Trying to contact $DOMAIN_NAME:636." \
          "--> ERROR: Timed out trying to contact $DOMAIN_NAME:636. Continuing..."
}

wait_for_lls() {
    local timeout=1200
    local interval=10
    local lls_health_check_url="http://${lls_ip}:7070/api/1.0/health"

    log "--> Performing LLS health check using endpoint $lls_health_check_url..."
    retry $timeout \
          $interval \
          # Need to escape Terraform template directive using %%
          "[ $(curl --silent --write-out "%%{http_code}\n" --output /dev/null $lls_health_check_url) -eq 200 ]" \
          "--> Performing LLS health check using endpoint $lls_health_check_url..." \
          "--> ERROR: Timed out trying to perform health check using endpoint $lls_health_check_url. Continuing..."
}

install_cac() {
    log "--> Installing Cloud Access Connector..."
    local retries=10
    local args=""

    log "--> Running command: $CAC_BIN_PATH install"
    log "--> CAC install options:"
    log "  -t <cac_token>"
    log "  --accept-policies"
    log "  --sa-user <ad_service_account_username>"
    log "  --sa-password <ad_service_account_password>"
    log "  --domain $DOMAIN_NAME"
    log "  --domain-group ${domain_group}"
    log "  --reg-code <pcoip_registration_code>"
    log "  --retrieve-agent-state true"
    log "  --sync-interval 5"

    # Set pipefail option to return status of the connector install command
    set -o pipefail

    if [ "${ssl_key}" ]
    then
        log "  --ssl-key <ssl_key>"
        log "  --ssl-cert <ssl_cert>"

        mv /tmp/${ssl_key} $INSTALL_DIR
        mv /tmp/${ssl_cert} $INSTALL_DIR

        args=$args"--ssl-key $INSTALL_DIR/${ssl_key} "
        args=$args"--ssl-cert $INSTALL_DIR/${ssl_cert} "
    else
        log "  --insecure"
        args=$args"--insecure "
    fi

    if [ "${lls_ip}" ]
    then
        log "  --local-license-server-url http://${lls_ip}:7070/request"
        args=$args"--local-license-server-url http://${lls_ip}:7070/request "
    fi

    set +x
    while true
    do
        $CAC_BIN_PATH install \
            -t $CAC_TOKEN \
            --accept-policies \
            --sa-user $AD_SERVICE_ACCOUNT_USERNAME \
            --sa-password "$AD_SERVICE_ACCOUNT_PASSWORD" \
            --domain $DOMAIN_NAME \
            --domain-group "${domain_group}" \
            --reg-code $PCOIP_REGISTRATION_CODE \
            --sync-interval 5 \
            $args \
            2>&1 | tee -a $CAC_INSTALL_LOG

        local rc=$?
        if [ $rc -eq 0 ]
        then
            log "--> Successfully installed Cloud Access Connector."
            break
        fi

        if [ $retries -eq 0 ]
        then
            log "--> ERROR: Failed to install Cloud Access Connector. No retries remaining."
            exit 1
        fi

        log "--> ERROR: Failed to install Cloud Access Connector. $retries retries remaining..."
        retries=$((retries-1))
        sleep 60
    done
    set -x
}

if [[ ! -f "$LOG_FILE" ]]
then
    mkdir -p "$(dirname $LOG_FILE)"
    touch "$LOG_FILE"
    chmod +644 "$LOG_FILE"
fi

log "$(date)"

# Print all executed commands to the terminal
set -x

# Redirect stdout and stderr to the log file
exec &>>$LOG_FILE

install_prereqs

get_credentials

check_connector_installed

config_network

download_cac

wait_for_dc

if [ "${lls_ip}" ]
then
    wait_for_lls
fi

install_cac

docker service ls

log "--> Provisioning script completed successfully."