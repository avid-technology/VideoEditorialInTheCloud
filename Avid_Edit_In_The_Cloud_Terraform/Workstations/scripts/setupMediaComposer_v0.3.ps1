<#
    .SYNOPSIS
        Configure Windows 10 Workstation with Avid ProTools.

    .DESCRIPTION
        Configure Windows 10 Workstation with Avid ProTools.

        Example command line: .\setupMachine.ps1 Avid ProTools
#>
[CmdletBinding(DefaultParameterSetName = "Standard")]
param(
    [string]
    [ValidateNotNullOrEmpty()]
    $TeradiciKey,
    [ValidateNotNullOrEmpty()]
    $TeradiciURL,
    [ValidateNotNullOrEmpty()]
    $MediaComposerURL,
    [ValidateNotNullOrEmpty()]
    $AvidNexisInstallerUrl,
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

    Write-Log "choco install -y 7zip.install"
    choco install -y 7zip.install

    Write-Log "choco Install Microsoft C++ Redistributions"
    choco install -y vcredist2008
    choco install -y vcredist2012
    choco install -y vcredist2013
    choco install -y vcredist2017

    Write-Log "choco Install Google Chrome"
    choco install -y googlechrome -ignore-checksum

    Write-Log "Enable the Audio service for Windows Server"
    Set-Service Audiosrv -StartupType Automatic
    Start-Service Audiosrv

    # Download Quicktime on desktop
    Write-Log "Download Quicktime"
    $QuicktimeURL = "https://secure-appldnld.apple.com/QuickTime/031-43075-20160107-C0844134-B3CD-11E5-B1C0-43CA8D551951/QuickTimeInstaller.exe"
    DownloadFileOverHttp $QuicktimeURL "C:\Users\Public\Desktop\QuicktimeInstaller.exe"

    # $msiexecPath = "C:\Windows\System32\msiexec.exe"
    # Start-Process "D:\AzureData\QuicktimeInstaller.exe" -ArgumentList "/extract", "D:\AzureData" -Wait
    # Start-Process $msiexecPath -ArgumentList "/i", "D:\AzureData\AppleSoftwareUpdate.msi", "/passive", "/quiet", "/norestart" -Wait
    # Start-Process $msiexecPath -ArgumentList "/i", "D:\AzureData\AppleApplicationSupport.msi", "/passive", "/quiet", "/norestart" -Wait
    # Start-Process $msiexecPath -ArgumentList "/i", "D:\AzureData\Quicktime.msi", "/quiet", "/passive", "/norestart", "/L*V D:/AzureData/qt_install.log" -Wait

    # $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    # if ($osInfo.ProductType -eq 1){
    # Write-Log "Windows Desktop.No need to disable ServerManager"
    # } 
    # else {
    # Write-Log "Disable ServerManager on Windows Server"
    # Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose
    # }

}

function
Install-MediaComposer {
    
    Write-Log "downloading Media Composer"
    # TODO: dynamically generate names based on download usrl
    $DestinationPath = "D:\AzureData\Media_Composer.zip"
    Write-Log $DestinationPath
    DownloadFileOverHttp $MediaComposerURL $DestinationPath
   
    # unzip media composer first
    Write-Log "unzip media composer first"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($DestinationPath, "D:\AzureData\")
        
    #PreReqBasePath
    $PreReqBasePath = "D:\AzureData\MediaComposer\Installers\MediaComposer\ISSetupPrerequisites"
                      
    #Install PACE License Support
    Write-Log "Installing PACE License Support"
    New-Item -ItemType Directory -Force -Path "$PreReqBasePath\pace"

    $url_path   = $MediaComposerURL -split "/" # Split url between "/"
    $url_path2  = $url_path[-1] # take last element
    $regex = "\d{4}"
    $version=[regex]::matches($url_path2, $regex).value
    
    if($version -eq "2018"){
        $PaceLicenseSupportExe = "$PreReqBasePath\PACE License Support 4.0.3\License Support Win64.exe" # Path to Pace license for older media composer versions
        } 
        else 
        {
        $PaceLicenseSupportExe = "$PreReqBasePath\PACE License Support 5.0.3\License Support Win64.exe" # Path to Pace license for newer media composer versions
        }
    
    Start-Process -FilePath $PaceLicenseSupportExe -ArgumentList "/s", "/x", "/b$PreReqBasePath\pace", "/v/qn" -Wait
    Start-Process -FilePath "$PreReqBasePath\pace\PACE License Support Win64.msi" -ArgumentList "/quiet", "/passive", "/norestart" -Wait

    #Install Sentinel USB Driver
    Write-Log "Installing Sentinel USB Driver"
    New-Item -ItemType Directory -Force -Path "$PreReqBasePath\sentinel"
    Start-Process -FilePath "$PreReqBasePath\Sentinel USB 7.6.9 Driver\Sentinel Protection Installer 7.6.9.exe" -ArgumentList "/s", "/x", "/b$PreReqBasePath\sentinel", "/v/qn" -Wait
    Start-Process -FilePath "$PreReqBasePath\sentinel\Sentinel Protection Installer 7.6.9.msi" -ArgumentList "/quiet", "/passive", "/norestart" -Wait

    #Install Avid Cloud Client Services
    Write-Log "Installing Avid Cloud Client Services"   
    New-Item -ItemType Directory -Force -Path "$PreReqBasePath\avidcloudclientservices"
    Start-Process -FilePath "$PreReqBasePath\Avid Cloud Client Services\Avid_Cloud_Client_Services.exe" -ArgumentList "/s", "/x", "/b$PreReqBasePath\avidcloudclientservices", "/v/qn" -Wait
    Start-Process -FilePath "$PreReqBasePath\avidcloudclientservices\Avid Cloud Client Services.msi" -ArgumentList "/quiet", "/passive", "/norestart" -Wait

    #Install AvidLink
    Write-Log "Installing AvidLink"   
    New-Item -ItemType Directory -Force -Path "$PreReqBasePath\avidlinksetup"
    Start-Process -FilePath "$PreReqBasePath\AvidLink\AvidLinkSetup.exe" -ArgumentList "/s", "/x", "/b$PreReqBasePath\avidlinksetup", "/v/qn" -Wait
    Start-Process -FilePath "$PreReqBasePath\avidlinksetup\Avid Link.msi" -ArgumentList "/quiet", "/passive", "/norestart" -Wait

    #Install media composer first
    Write-Log "Install Media Composer"
    Start-Process -FilePath "D:\AzureData\MediaComposer\Installers\MediaComposer\Avid Media Composer.msi" -ArgumentList "/quiet", "/passive", "/norestart" -Wait
    Write-Log "Finished Installing Media Composer"
}

function
Install-Teradici {
    
    Set-Location -Path "D:\AzureData"
        
    Write-Log "Downloading Teradici"
    $TeradiciDestinationPath = "C:\Users\Public\Desktop\PCoIP_agent_release_installer_graphic.exe"

    Write-Log $DestinationPath
    DownloadFileOverHttp $TeradiciURL $TeradiciDestinationPath    
    
    #Write-Log "Install Teradici"
    #Start-Process -FilePath $TeradiciDestinationPath -ArgumentList "/S", "/NoPostReboot" -Verb RunAs -Wait
    
    #cd "C:\Program Files (x86)\Teradici\PCoIP Agent"

    #Write-Log "Register Teradici"   
    #& .\pcoip-register-host.ps1 -RegistrationCode $TeradiciKey

    #& .\pcoip-validate-license.ps1

    #Write-Log "Restart Teradici Service" 
    #restart-service -name PCoIPAgent
}

function 
Install-NexisClient {
   
    Write-Log "downloading Nexis Client"
    $NexisDestinationPath = "D:\AzureData\AvidNEXISClient.msi"
    Write-Log $DestinationPath
    DownloadFileOverHttp $AvidNexisInstallerUrl $NexisDestinationPath

    Start-Process -FilePath $NexisDestinationPath -ArgumentList "/quiet", "/passive", "/norestart" -Wait
    
}

function
Add-HostDomain {
    
    $password = $domain_admin_password | ConvertTo-SecureString -asPlainText -Force
    $username = "$DomainName\$domain_admin_username" 
    $credential = New-Object System.Management.Automation.PSCredential($username,$password)

    Add-Computer -DomainName $DomainName -Credential $credential

}

try {
    # Set to false for debugging.  This will output the start script to
    # c:\AzureData\CustomDataSetupScript.log, and then you can RDP
    # to the windows machine, and run the script manually to watch
    # the output.
    if ($true) 
    {
        
        Write-Log "Create Download folder"
        mkdir D:\AzureData   

        try {
            Write-Log "Installing chocolaty and packages"
            Install-ChocolatyAndPackages
        }
        catch {
            Write-Log "Chocolaty is best effort"
        }   

        # Write-Log "Call Install-Teradici"
        # Install-Teradici

        # Write-Log "Call Install-NexisCLient"
        # Install-NexisClient

        # Write-Log "Call Install-MediaComposer"
        # Install-MediaComposer

        # Write-Log "Add server to Domain"
        # if ([string]::IsNullOrWhiteSpace(${DomainName})) {
        #             Write-Log "Not added to any domain as no domain specified by user"
        #     } else {
        #             Add-HostDomain
        #     }
        
        # Write-Log "Complete"

        # Write-Log "Restart Computer"
        # Restart-Computer 
    }
    else {
        # keep for debugging purposes
        Write-Log "Set-ExecutionPolicy -ExecutionPolicy Unrestricted"
        Write-Log ".\CustomDataSetupScript.ps1 -TeradiciKey $TeradiciKey"
    }
}
catch {
    Write-Error $_
}