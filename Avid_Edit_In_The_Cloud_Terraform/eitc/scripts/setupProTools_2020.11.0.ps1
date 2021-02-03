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
    $nvidia_url,
    [ValidateNotNullOrEmpty()]
    $AvidNexisInstallerUrl
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

    Write-Log "choco Install Microsoft C++ Redistributions"
    choco install -y vcredist2008
    choco install -y vcredist2010
    choco install -y vcredist2012
    choco install -y vcredist2013
    choco install -y vcredist140

    Write-Log "choco Install ASIO4ALL"
    choco install -y asio4all
}

function
Install-ProTools {
    
    Write-Log "Downloading ProTools"
    #$DestinationPath = "C:\Users\Public\Desktop\ProTools.zip"
    $DestinationPath = "D:\AzureData\ProTools.zip"

    Write-Log $DestinationPath
    DownloadFileOverHttp $ProToolsURL $DestinationPath

    # Unzip Pro Tools
    Write-Log "Unzip Pro Tools"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($DestinationPath, "D:\AzureData\")

    #PreReqBasePath
    $PreReqBasePath = "D:\AzureData\Pro Tools\ISSetupPrerequisites"
                      
    #Install PACE License Support
    Write-Log "Installing PACE License Support"

    # Fixing the InstallShield response file...
    $PaceSetupIss = @"
[{5AC59014-E7D8-447e-ABE2-5D7FA0626522}-DlgOrder]
Dlg0={5AC59014-E7D8-447e-ABE2-5D7FA0626522}-SdWelcome-0
Count=4
Dlg1={5AC59014-E7D8-447e-ABE2-5D7FA0626522}-SdLicenseRtf-0
Dlg2={5AC59014-E7D8-447e-ABE2-5D7FA0626522}-SdStartCopy2-0
Dlg3={5AC59014-E7D8-447e-ABE2-5D7FA0626522}-SdFinish-0
[{5AC59014-E7D8-447e-ABE2-5D7FA0626522}-SdWelcome-0]
Result=1
[{5AC59014-E7D8-447e-ABE2-5D7FA0626522}-SdLicenseRtf-0]
Result=1
[{5AC59014-E7D8-447e-ABE2-5D7FA0626522}-SdStartCopy2-0]
Result=1
[{5AC59014-E7D8-447e-ABE2-5D7FA0626522}-SdFinish-0]
Result=1
bOpt1=0
bOpt2=0
"@
    Set-Content -Path "$PreReqBasePath\Pace License Support\setup.iss" -Value $PaceSetupIss
    $PaceLicenseSupportBaseName = "$PreReqBasePath\PACE License Support\License Support Win64.exe"
    Start-Process -FilePath "$PaceLicenseSupportBaseName" -ArgumentList "/s" -Wait


    #Install Avid Cloud Client Services
    Write-Log "Installing Avid Cloud Client Services"   
    Start-Process -FilePath "$PreReqBasePath\Avid Cloud Client\Avid_Cloud_Client_Services.exe" -ArgumentList "/s", "/v/qn" -Wait

    #Install AvidLink
    Write-Log "Installing AvidLink"   
    Start-Process -FilePath "$PreReqBasePath\AvidLink\AvidLinkSetup.exe" -ArgumentList "/s", "/v/qn" -Wait

    #Install Avid Codecs
    Write-Log "Installing Avid Codecs LE"
    Start-Process -FilePath "$PreReqBasePath\Avid Codecs\AvidCodecsLESetup.exe" -ArgumentList "/s", "/v/qn" -Wait

    # Install Pro Tools
    Start-Process -FilePath 'D:\AzureData\Pro Tools\Avid Pro Tools.msi' -ArgumentList "/quiet", "/passive", "/norestart" -Wait
}

function
Install-Teradici {
    Write-Log "Downloading Teradici"
    $TeradiciDestinationPath = "D:\AzureData\PCoIP_graphic_agent.exe"

    Write-Log $DestinationPath
    DownloadFileOverHttp $TeradiciURL $TeradiciDestinationPath   
    
    Write-Log "Installing Teradici PCoIP Graphics Agent" 
    Start-Process -FilePath $TeradiciDestinationPath ‑ArgumentList "/S /NoPostReboot _?$TeradiciDestinationPath" -Wait
}

function 
Install-NexisClient {
    Write-Log "downloading Nexis Client"
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

        Write-Log "Call Install-ProTools"
        Install-ProTools

        Write-Log "Call Install-NexisClient"
        Install-NexisClient

        #Write-Log "Call Install-Teradici"
        #Install-Teradici

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
