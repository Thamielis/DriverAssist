#region Function Get-OSBuild
function Get-OSBuild {
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
        [parameter(Mandatory = $true, HelpMessage = "OS version data to be translated.")]
        [ValidateNotNullOrEmpty()]
        [string]$InputObject,
        [parameter(Mandatory = $true, HelpMessage = "OS name data to differentiate builds.")]
        [ValidateNotNullOrEmpty()]
        [string]$OSName
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        switch ($OSName) {
			"Windows 11" {
				switch (([System.Version]$InputObject).Build) {
					"22621" {
						$OSVersion = '22H2'
					}
					"22000" {
						$OSVersion = '21H2'
					}
					default {
						Write-LogEntry -Value "[!] Unable to translate OS version using input object: $($InputObject)" -Severity 3 -Source ${CmdletName}
						Write-LogEntry -Value "[!] Unsupported OS version detected" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
				}
			}
			"Windows 10" {
				switch (([System.Version]$InputObject).Build) {
					"19044" {
						$OSVersion = '21H2'
					}
					"19043" {
						$OSVersion = '21H1'
					}
					"19042" {
						$OSVersion = '20H2'
					}
					"19041" {
						$OSVersion = 2004
					}
					"18363" {
						$OSVersion = 1909
					}
					"18362" {
						$OSVersion = 1903
					}
					"17763" {
						$OSVersion = 1809
					}
					"17134" {
						$OSVersion = 1803
					}
					"16299" {
						$OSVersion = 1709
					}
					"15063" {
						$OSVersion = 1703
					}
					"14393" {
						$OSVersion = 1607
					}
					default {
						Write-LogEntry -Value "[!] Unable to translate OS version using input object: $($InputObject)" -Severity 3 -Source ${CmdletName}
						Write-LogEntry -Value "[!] Unsupported OS version detected" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
				}
			}
		}
    }
    end {
        return [string]$OSVersion
    }
}
#endregion Function Get-OSBuild
