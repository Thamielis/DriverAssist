#region Function Get-OSArchitecture
function Get-OSArchitecture {
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
        [parameter(Mandatory = $true, HelpMessage = "OS architecture data to be translated.")]
        [ValidateNotNullOrEmpty()]
        [string]$InputObject
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        switch -Wildcard ($InputObject) {
			"9" {
				$OSArchitecture = "x64"
			}
			"0" {
				$OSArchitecture = "x86"
			}
			"64*" {
				$OSArchitecture = "x64"
			}
			"32*" {
				$OSArchitecture = "x86"
			}
			default {
				Write-LogEntry -Value "[!] Unable to translate OS architecture using input object: $($InputObject)" -Severity 3 -Source ${CmdletName}
				$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
			}
		}
    }
    end {
        return $OSArchitecture
    }
}
#endregion Function Get-OSArchitecture
