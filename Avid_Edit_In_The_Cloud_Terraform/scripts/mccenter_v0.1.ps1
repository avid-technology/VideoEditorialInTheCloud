<#
    .SYNOPSIS
        Configure Windows 10 Workstation with Avid ProTools.

    .DESCRIPTION
        Configure Windows 10 Workstation with Avid ProTools.

        Example command line: .\setupMachine.ps1 Avid ProTools
#>
[CmdletBinding(DefaultParameterSetName = "Standard")]
param (
    [string]
    [ValidateNotNullOrEmpty()]
    $MCAMInstallerUrl,
    $DomainName,
    $domain_admin_username,
    $domain_admin_password
)

filter Timestamp {"$(Get-Date -Format o): $_"}

function
Write-Log($message) {
    $msg = $message | Timestamp
    Write-Output $msg
}

function
DownloadFileOverHttp($Url, $DestinationPath) {
    $secureProtocols = @()
    $insecureProtocols = @([System.Net.SecurityProtocolType]::SystemDefault, [System.Net.SecurityProtocolType]::Ssl3)

    foreach ($protocol in [System.Enum]::GetValues([System.Net.SecurityProtocolType])) {
        if ($insecureProtocols -notcontains $protocol) {
            $secureProtocols += $protocol
        }
    }
    [System.Net.ServicePointManager]::SecurityProtocol = $secureProtocols

    # make Invoke-WebRequest go fast: https://stackoverflow.com/questions/14202054/why-is-this-powershell-code-invoke-webrequest-getelementsbytagname-so-incred
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest $Url -UseBasicParsing -OutFile $DestinationPath -Verbose
    Write-Log "$DestinationPath updated"
}

function
Install-ChocolatyAndPackages {
    
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    Write-Log "choco Install Google Chrome"
    choco install -y googlechrome -ignore-checksum

    Write-Log "choco install -y 7zip.install"
    choco install -y 7zip.install

    #Write-Log "install Microsoft Azure Storage Explorer 1.17.0"
    #choco install microsoftazurestorageexplorer

}

function
Install-MediaCentralControlCenter {
    
    Write-Log "downloading MediaCentral Installer"
    $MCAMDestinationPath = "D:\AzureData\MediaCentralAssetManagement.zip"
    
    Write-Log $DestinationPath
    DownloadFileOverHttp $MCAMInstallerUrl $MCAMDestinationPath

    # unzip MediaCentral Asset Management
    Write-Log "unzip MediaCentral Asset Management"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($MCAMDestinationPath, "D:\AzureData\")

    # Create Logs folder
    New-Item -Path "C:\" -Name "Logs" -ItemType "directory"
    
    # Create Data Mam folder
    New-Item -Path "C:\" -Name "Data_MAM" -ItemType "directory"

    # Create Local Security Group MC_Administrators
    New-LocalGroup -Name "MC_Administrators"

    # Add mc_service to Local Administrator group
    Add-LocalGroupMember -Group "Administrators" -Member "ABC0\mc_service"

    # Add mc_service to Local MC_Administrators group
    Add-LocalGroupMember -Group "MC_Administrators" -Member "ABC0\mc_service"
}

function
Add-HostDomain {
    
    $password = $domain_admin_password | ConvertTo-SecureString -asPlainText -Force
    $username = "$DomainName\$domain_admin_username" 
    $credential = New-Object System.Management.Automation.PSCredential($username,$password)

    Add-Computer -DomainName $DomainName -Credential $credential

}

try {
    $dest = "D:\AzureData"
    New-Item -Path $dest -ItemType directory -Force

    try {
            Write-Log "Installing chocolaty and packages"
            Install-ChocolatyAndPackages
        }
        catch {
            # chocolaty is best effort
        }

        Install-MediaCentralControlCenter

        Write-Log "Add server to Domain"
        if ([string]::IsNullOrWhiteSpace(${DomainName})) {
                    Write-Log "Not added to any domain as no domain specified by user"
            } else {
                    Add-HostDomain
            }
        
}
catch {
    Write-Error $_
}

