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
    $ProToolsURL,
    [ValidateNotNullOrEmpty()]
    $TeradiciURL,
    [ValidateNotNullOrEmpty()]
    $AvidNEXISClientURL
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

    Write-Log "choco Install Google Chrome"
    choco install -y googlechrome -ignore-checksum

}

function
Install-ProTools {
    
    Write-Log "downloading ProTools"
    $DestinationPath = "C:\Users\Public\Desktop\ProTools.zip"

    Write-Log $DestinationPath
    DownloadFileOverHttp $ProToolsURL $DestinationPath
   
}

function
Install-Teradici {
    
    Set-Location -Path "D:\AzureData"
        
    Write-Log "Downloading Teradici"
    $TeradiciDestinationPath = "C:\Users\Public\Desktop\PCoIP_agent_release_installer_graphic.exe"


    Write-Log $DestinationPath
    DownloadFileOverHttp $TeradiciURL $TeradiciDestinationPath   
    
}

function 
Install-NexisClient {
   
    Write-Log "downloading Nexus Client"
    $NexisDestinationPath = "D:\AzureData\AvidNEXISClient.msi"
    
    Write-Log $DestinationPath
    DownloadFileOverHttp $AvidNEXISClientURL $NexisDestinationPath

    Start-Process -FilePath $NexisDestinationPath -ArgumentList "/quiet", "/passive", "/norestart" -Wait
    
}


try {
    # Set to false for debugging.  This will output the start script to
    # c:\AzureData\CustomDataSetupScript.log, and then you can RDP
    # to the windows machine, and run the script manually to watch
    # the output.
    if ($true) 
    {
        
        try {
            Write-Log "Installing chocolaty and packages"
            Install-ChocolatyAndPackages
        }
        catch {
            # chocolaty is best effort
        }   

        Write-Log "Create Download folder"
        mkdir D:\AzureData

        Write-Log "Call Install-Teradici"
        Install-Teradici

        Write-Log "Call Install-NexisCLient"
        Install-NexisClient

        Write-Log "Call Install-ProTools"
        Install-ProTools

        # Write-Log "Cleanup"
        # Remove-Item D:\AzureData -Force  -Recurse -ErrorAction SilentlyContinue
        
        Write-Log "Complete"

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
