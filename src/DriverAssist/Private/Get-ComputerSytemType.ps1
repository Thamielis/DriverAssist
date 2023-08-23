#region Function Get-ComputerSytemType
function Get-ComputerSytemType {
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
        $ComputerSystemType = Get-WmiObject -Class "Win32_ComputerSystem" | Select-Object -ExpandProperty "Model"
		if ($ComputerSystemType -notin @("Virtual Machine", "VMware Virtual Platform", "VirtualBox", "HVM domU", "KVM", "VMWare7,1")) {
			Write-LogEntry -Value "[+] Supported computer platform detected, script execution allowed to continue" -Severity 1 -Source ${CmdletName}
		}
		else {
			if ($script:PSCmdlet.ParameterSetName -like "Debug") {
				Write-LogEntry -Value "[-] Unsupported computer platform detected, virtual machines are not supported but will be allowed in DebugMode" -Severity 2 -Source ${CmdletName}
			}
			else {
				Write-LogEntry -Value "[!] Unsupported computer platform detected, virtual machines are not supported" -Severity 3 -Source ${CmdletName}
				$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
			}
		}
    }
    end {
    }
}
#endregion Function Get-ComputerSytemType
