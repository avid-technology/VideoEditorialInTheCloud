<# Custom Script for Windows to install a file from Azure Storage using the staging folder created by the deployment script #>
param (

)

filter Timestamp {"$(Get-Date -Format o): $_"}

function
Write-Log($message) {
    $msg = $message | Timestamp
    Write-Output $msg
}

function
Install-ChocolatyAndPackages {
    
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    Write-Log "choco Install Google Chrome"
    choco install -y googlechrome -ignore-checksum

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

}
catch {
    Write-Error $_
}

