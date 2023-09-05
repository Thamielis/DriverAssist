#region Function Confirm-OSName
function Confirm-OSName {
    <#
    .SYNOPSIS
    Confirm the OS name value from the driver package object
    .DESCRIPTION
    This function will confirm the OS name value from the driver package object
    .PARAMETER DriverPackageInput
    Specify the OS name value from the driver package object
    .PARAMETER OSImageData
    Specify the computer data object
    .EXAMPLE
    Confirm-OSName -DriverPackageInput $DriverPackageInput -OSImageData $OSImageData
    .INPUTS
    System.String, System.Management.Automation.PSCustomObject
    .OUTPUTS
    System.Boolean
    .NOTES
    Testing as part of the DriverAssist module.
    .LINK
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "Specify the OS name value from the driver package object.")]
        [ValidateNotNullOrEmpty()]
        [string]$DriverPackageInput,
        [parameter(Mandatory = $true, HelpMessage = "Specify the Windows Operating System name.")]
        [ValidateNotNullOrEmpty()]
        [string]$OSName
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        if ($DriverPackageInput -like $OSName) {
            Write-LogEntry -Value "[+] Matched operating system name: $($OSName)" -Severity 1 -Source ${CmdletName}
            $result = $true
        }
        else {
            Write-LogEntry -Value "[!] Could not matched operating system name: $($OSName)" -Severity 2 -Source ${CmdletName}
            $result = $false
        }
    }
    end {
        return $result
    }
}
#endregion Function Confirm-OSName
