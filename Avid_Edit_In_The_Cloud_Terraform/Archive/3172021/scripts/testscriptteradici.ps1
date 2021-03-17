# Copyright (c) 2021 Teradici Corporation
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

$pcoip_registration_code = "0000"
$NVIDIA_DRIVER_URL = "https://eitcstore01.blob.core.windows.net/installers/461.09_grid_win10_server2016_server2019_64bit_azure_swl.exe"
$NVIDIA_DRIVER_FILENAME = "nvidia.exe"
$tenant_id = ""
$AgentLocation = 'C:\Program Files\Teradici\PCoIP Agent\'
$LOG_FILE = "C:\Teradici\provisioning.log"
$NVIDIA_DIR = "C:\Program Files\NVIDIA Corporation\NVSMI"
$PCOIP_AGENT_FILENAME = ""
$PCOIP_AGENT_LOCATION_URL = "https://downloads.teradici.com/win/stable/"

$DATA = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$DATA.Add("pcoip_registration_code", "${pcoip_registration_code}")
$DATA.Add("ad_service_account_password", "${ad_service_account_password}")

$global:restart = $false

# Retry function, defaults to trying for 5 minutes with 10 seconds intervals
function Retry([scriptblock]$Action, $Interval = 10, $Attempts = 30) {
    $Current_Attempt = 0

    while ($true) {
        $Current_Attempt++
        $rc = $Action.Invoke()

        if ($?) { return $rc }

        if ($Current_Attempt -ge $Attempts) {
            Write-Error "--> ERROR: Failed after $Current_Attempt attempt(s)." -InformationAction Continue
            Throw
        }

        Write-Information "--> Attempt $Current_Attempt failed. Retrying in $Interval seconds..." -InformationAction Continue
        Start-Sleep -Seconds $Interval
    }
}


Function Get-AccessToken
(
    [string]$application_id,
    [string]$aad_client_secret,
    [string]$oath2Uri
) {
    $body = 'grant_type=client_credentials'
    $body += '&client_id=' + $application_id
    $body += '&client_secret=' + [Uri]::EscapeDataString($aad_client_secret)
    $body += '&resource=' + [Uri]::EscapeDataString("https://vault.azure.net")
    $response = Invoke-RestMethod -Method POST -Uri $oath2Uri -Headers @{} -Body $body

    return $response.access_token
}

Function Decrypt-Credentials {
    $oath2Uri = "https://login.microsoftonline.com/${tenant_id}/oauth2/token"
    $accessToken = Get-AccessToken ${application_id} ${aad_client_secret} $oath2Uri

    $pcoipRegCodeQueryUrl = "${pcoip_registration_code}" + '?api-version=7.0'       
    $headers = @{ 'Authorization' = "Bearer $accessToken"; "Content-Type" = "application/json" }
    $response = Invoke-RestMethod -Method GET -Ur $pcoipRegCodeQueryUrl -Headers $headers
    $DATA."pcoip_registration_code" = $response.value

    $adAdminPasswordCodeQueryUrl = "${ad_service_account_password}" + '?api-version=7.0'       
    $headers = @{ 'Authorization' = "Bearer $accessToken"; "Content-Type" = "application/json" }
    $response = Invoke-RestMethod -Method GET -Ur $adAdminPasswordCodeQueryUrl -Headers $headers
    $DATA."ad_service_account_password" = $response.value
}

function Nvidia-is-Installed {
    if (!(test-path $NVIDIA_DIR)) {
        return $false
    }

    cd $NVIDIA_DIR
    & .\nvidia-smi.exe
    return $?
    return $false
}

function Nvidia-Install {
    "################################################################"
    "Installing NVIDIA driver..."
    "################################################################"

    if (Nvidia-is-Installed) {
        "--> NVIDIA driver is already installed. Skipping..."
        return
    }

    mkdir 'C:\Nvidia'
    $driverDirectory = "C:\Nvidia"

    # $nvidiaInstallerUrl = $NVIDIA_DRIVER_URL + $NVIDIA_DRIVER_FILENAME
    $destFile = $driverDirectory + "\" + $NVIDIA_DRIVER_FILENAME
    $wc = New-Object System.Net.WebClient

    "--> Downloading NVIDIA GRID driver from $NVIDIA_DRIVER_URL..."
    Retry -Action { $wc.DownloadFile($NVIDIA_DRIVER_URL, $destFile) }
    "--> NVIDIA GRID driver downloaded."

    "--> Installing NVIDIA GRID Driver..."
    $ret = Start-Process -FilePath $destFile -ArgumentList "/s /noeula /noreboot" -PassThru -Wait

    if (!(Nvidia-is-Installed)) {
        "--> ERROR: Failed to install NVIDIA GRID driver."
        exit 1
    }

    "--> NVIDIA GRID driver installed successfully."
    # $global:restart = $true
    #Restart-Computer -Force
}

function PCoIP-Agent-is-Installed {
    Get-Service "PCoIPAgent"
    return $?
}

function PCoIP-Agent-Install {
    "################################################################"
    "Installing PCoIP graphics agent..."
    "################################################################"

    if (PCoIP-Agent-is-Installed) {
        "--> PCoIP graphics agent is already installed. Skipping..."
        return
    }

    $agentInstallerDLDirectory = "C:\Teradici"
    if (![string]::IsNullOrEmpty($PCOIP_AGENT_FILENAME)) {
        "--> Using user-specified PCoIP graphics agent filename..."
        $agent_filename = $PCOIP_AGENT_FILENAME
    }
    else {
        "--> Using default latest PCoIP graphics agent..."
        $agent_latest = $PCOIP_AGENT_LOCATION_URL + "latest-graphics-agent.json"
        $wc = New-Object System.Net.WebClient

        "--> Checking for the latest PCoIP graphics agent version from $agent_latest..."
        $string = Retry -Action { $wc.DownloadString($agent_latest) }

        $agent_filename = $string | ConvertFrom-Json | Select-Object -ExpandProperty "filename"
    }
    $pcoipAgentInstallerUrl = $PCOIP_AGENT_LOCATION_URL + $agent_filename
    $destFile = $agentInstallerDLDirectory + '\' + $agent_filename
    $wc = New-Object System.Net.WebClient

    "--> Downloading PCoIP graphics agent from $pcoipAgentInstallerUrl..."
    Retry -Action { $wc.DownloadFile($pcoipAgentInstallerUrl, $destFile) }
    "--> Teradici PCoIP graphics agent downloaded: $agent_filename"

    "--> Installing Teradici PCoIP graphics agent..."
    Start-Process -FilePath $destFile -ArgumentList "/S /nopostreboot _?$destFile" -PassThru -Wait

    if (!(PCoIP-Agent-is-Installed)) {
        "--> ERROR: Failed to install PCoIP graphics agent."
        exit 1
    }

    "--> Teradici PCoIP graphics agent installed successfully."
    $global:restart = $true
}

function PCoIP-Agent-Register {
    "################################################################"
    "Registering PCoIP agent..."
    "################################################################"

    cd 'C:\Program Files\Teradici\PCoIP Agent'

    "--> Checking for existing PCoIP License..."
    & .\pcoip-validate-license.ps1
    if ( $LastExitCode -eq 0 ) {
        "--> Found valid license."
        return
    }

    # License registration may have intermittent failures
    $Interval = 10
    $Timeout = 600
    $Elapsed = 0

    do {
        $Retry = $false
        & .\pcoip-register-host.ps1 -RegistrationCode $DATA."pcoip_registration_code"
        # The script already produces error message

        if ( $LastExitCode -ne 0 ) {
            if ($Elapsed -ge $Timeout) {
                "--> ERROR: Failed to register PCoIP agent."
                exit 1
            }

            "--> Retrying in $Interval seconds... (Timeout in $($Timeout-$Elapsed) seconds)"
            $Retry = $true
            Start-Sleep -Seconds $Interval
            $Elapsed += $Interval
        }
    } while ($Retry)

    "--> PCoIP agent registered successfully."
}

function Join-Domain 
(
    [string]$domain_name,
    [string]$ad_service_account_username,
    [string]$ad_service_account_password
) {
    $obj = Get-WmiObject -Class Win32_ComputerSystem

    if ($obj.PartOfDomain) {
        if ($obj.Domain -ne "$domain_name") {
            "ERROR: Trying to join '$domain_name' but computer is already joined to '$obj.Domain'"
            continue
        }

        "Computer already part of the '$obj.Domain' domain."
        return
    } 

    "Computer not part of a domain. Joining $domain_name..."

    $username = "$ad_service_account_username" + "@" + "$domain_name"
    $password = ConvertTo-SecureString $DATA."ad_service_account_password" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($username, $password)

    # Looping in case Domain Controller is not yet available
    $Interval = 10
    $Timeout = 3600
    $Elapsed = 0

    do {
        Try {
            $Retry = $false
            # Don't do -Restart here because there is no log showing the restart
            Add-Computer -DomainName "$domain_name" -Credential $cred -Verbose -Force -ErrorAction Stop
        }

        # The same Error, System.InvalidOperationException, is thrown in these cases: 
        # - when Domain Controller not reachable (retry waiting for DC to come up)
        # - when password is incorrect (retry because user might not be added yet)
        # - when computer is already in domain
        Catch [System.InvalidOperationException] {
            $_.Exception.Message
            if (($Elapsed -ge $Timeout) -or ($_.Exception.GetType().FullName -match "AddComputerToSameDomain,Microsoft.PowerShell.Commands.AddComputerCommand")) {
                exit 1
            }

            "Retrying in $Interval seconds... (Timeout in $($Timeout-$Elapsed) seconds)"
            $Retry = $true
            Start-Sleep -Seconds $Interval
            $Elapsed += $Interval
        }
        Catch {
            $_.Exception.Message
            exit 1
        }
    } while ($Retry)

    $obj = Get-WmiObject -Class Win32_ComputerSystem
    if (!($obj.PartOfDomain) -or ($obj.Domain -ne "$domain_name") ) {
        "ERROR: failed to join $domain_name"
        exit 1
    }

    "Successfully joined $domain_name"
    $global:restart = $true
}

Start-Transcript -path $LOG_FILE -append

"--> Script running as user '$(whoami)'."
if ([string]::IsNullOrWhiteSpace("${tenant_id}")) {
    Write-Output "Not using Key Vault Secrets. Skipping .."
}
else {
    Write-Output "Decrypting Key Vault Secrets .."
    Decrypt-Credentials
}

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

Nvidia-Install

PCoIP-Agent-Install

if ("${pcoip_registration_code}" -ne "null") {
    PCoIP-Agent-Register
}

#Write-Output "Joining Domain"

#Join-Domain $domain_name $ad_service_account_username $ad_service_account_password

#$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
#if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
#    "--> Running as Administrator..."
#}
#else {
#    "--> Not running as Administrator..."
#}

##if ($global:restart) {
#    "--> Restart required. Restarting..."
#    Restart-Computer -Force
#}
#else {
#    "--> No restart required."
#}