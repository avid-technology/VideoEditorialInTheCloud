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
    $DomainName,
    [ValidateNotNullOrEmpty()]
    $DomainPassword
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

    #Write-Log "install Microsoft Azure Storage Explorer 1.17.0"
    #choco install microsoftazurestorageexplorer

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

    $domainsplit                        = $DomainName.Split(".")
    $domain                             = $domainsplit[0]
    $topdomain                          = $domainsplit[1] 
    $netBIOSname                        = $domain.ToUpper()
    $encrypted_password                 = ConvertTo-SecureString $DomainPassword -AsPlainText -Force

    #Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

    #Import-Module ADDSDeployment

    $forestProperties = @{
    DomainName                          = $DomainName
    DomainNetbiosName                   = $netBIOSname
    SafeModeAdministratorPassword       = $encrypted_password
    CreateDnsDelegation                 = $false
    InstallDns                          = $true
    NoRebootOnCompletion                = $true
    Force                               = $true
    }

    Install-ADDSForest @forestProperties

    Install-WindowsFeature DNS -IncludeManagementTools

    Restart-Computer
}
catch {
    Write-Error $_
}

