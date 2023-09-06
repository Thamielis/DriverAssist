#region Function Install-DriverPackageContent
function Install-DriverPackageContent {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER
    .EXAMPLE
    .INPUTS
    .OUTPUTS
    .NOTES
    Testing as part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    param (
        # Full path to the driver package content files
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the full path to the driver package content files")]
        [ValidateNotNullOrEmpty()]
        [string]$ContentLocation
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        $DriverPackageFile = Get-ChildItem -Path $ContentLocation -Filter "DriverPackage.wim"
    }
    process {
        try {
            # Create mount location for driver package WIM file
            $DriverPackageMountLocation = Join-Path -Path $ContentLocation -ChildPath "Mount"
            if (-not (Test-Path -Path $DriverPackageMountLocation)) {
                Write-LogEntry -Value "[i] Creating mount location directory: $($DriverPackageMountLocation)" -Severity 1 -Source ${CmdletName}
                New-Item -Path $DriverPackageMountLocation -ItemType "Directory" -Force | Out-Null
            }
        }
        catch [System.Exception] {
            Write-CMLogEntry -Value "[!] Failed to create mount location for WIM file. Error message: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
            throw "Failed to create mount location for WIM file"
        }
        try {
            # Expand compressed driver package WIM file
            Write-LogEntry -Value "[i] Attempting to mount driver package content WIM file: $($DriverPackageFile.Name)" -Severity 1 -Source ${CmdletName}
            Write-LogEntry -Value "[i] Mount location: $($DriverPackageMountLocation)" -Severity 1 -Source ${CmdletName}
            Mount-WindowsImage -ImagePath $DriverPackageFile.FullName -Path $DriverPackageMountLocation -Index 1 -ErrorAction Stop
            Write-LogEntry -Value "[+] Successfully mounted driver package content WIM file" -Severity 1 -Source ${CmdletName}
            Write-LogEntry -Value " - Copying items from mount directory" -Severity 1 -Source ${CmdletName}
            # Get-ChildItem -Path $DriverPackageMountLocation | Copy-Item -destination $ContentLocation -Recurse -container
        }
        catch [System.Exception] {
            Write-LogEntry -Value "[!] Failed to mount driver package content WIM file." -Severity 3 -Source ${CmdletName}
            throw "Failed to mount driver package content WIM file"
        }
    }
    end {
    }
}
#endregion Function Install-DriverPackageContent