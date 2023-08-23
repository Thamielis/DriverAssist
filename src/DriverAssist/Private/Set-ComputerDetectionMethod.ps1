#region Function Set-ComputerDetectionMethod
function Set-ComputerDetectionMethod {
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
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        if ($ComputerDetection.SystemSKUDetected -eq $true) {
			Write-LogEntry -Value "[+] Determined primary computer detection method: SystemSKU" -Severity 1 -Source ${CmdletName}
			return "SystemSKU"
		}
		else {
			Write-LogEntry -Value " - Determined fallback computer detection method: ComputerModel" -Severity 1 -Source ${CmdletName}
			return "ComputerModel"
		}
    }
    end {
    }
}
#endregion Function Set-ComputerDetectionMethod
