#region Function Test-AdminServiceData
function Test-AdminServiceData {
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
        # Validate that the correct value has been set as a TS environment variable or passed as parameter input for the service account user name used to authenticate against the AdminService
		if ([string]::IsNullOrEmpty($script:UserName)) {
			switch ($PSCmdLet.ParameterSetName) {
				"Debug" {
					Write-LogEntry -Value "[!] Required service account user name could not be determined from parameter input" -Severity 3 -Source ${CmdletName}
					$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
				}
				default {
					# Attempt to read TSEnvironment variable MDMUserName
					$script:UserName = Get-TSValue -Name "MDMUserName"
					if (-not ([string]::IsNullOrEmpty($script:UserName))) {
						# Obfuscate user name
						$ObfuscatedUserName = ConvertTo-ObfuscatedUserName -InputObject $script:UserName
						Write-LogEntry -Value "[+] Successfully read service account user name from TS environment variable 'MDMUserName': $($ObfuscatedUserName)" -Severity 1 -Source ${CmdletName}
					}
					else {
						Write-LogEntry -Value "[!] Required service account user name could not be determined from TS environment variable" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
				}
			}
		}
		else {
			# Obfuscate user name
			$ObfuscatedUserName = ConvertTo-ObfuscatedUserName -InputObject $script:UserName
			Write-LogEntry -Value "[+] Successfully read service account user name from parameter input: $($ObfuscatedUserName)" -Severity 1 -Source ${CmdletName}
		}
		# Validate the correct value has been set as a TS environment variable or passed as parameter input for the service account password used to authenticate against the AdminService
		if ([string]::IsNullOrEmpty($script:Password)) {
			switch ($script:PSCmdLet.ParameterSetName) {
				"Debug" {
					Write-LogEntry -Value "[-] Required service account password could not be determined from parameter input" -Severity 3 -Source ${CmdletName}
				}
				default {
					$script:Password = Get-TSValue -Name "MDMPassword"
					if (-not([string]::IsNullOrEmpty($script:Password))) {
						Write-LogEntry -Value "[+] Successfully read service account password from TS environment variable 'MDMPassword': ********" -Severity 1 -Source ${CmdletName}
					}
					else {
						Write-LogEntry -Value "[!] Required service account password could not be determined from TS environment variable" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
				}
			}
		}
		else {
			Write-LogEntry -Value "[+] Successfully read service account password from parameter input: ********" -Severity 1 -Source ${CmdletName}
		}
		# Validate that if the AdminService endpoint type is external. If so, additional required TS environment variables are available
		if ($script:AdminServiceEndpointType -like "External") {
			if ($script:PSCmdLet.ParameterSetName -notlike "Debug") {
				$script:ExternalEndpoint = Get-TSValue -Name "MDMExternalEndpoint"
				if (-not([string]::IsNullOrEmpty($script:ExternalEndpoint))) {
					Write-LogEntry -Value "[+] Successfully read external endpoint address for AdminService through CMG from TS environment variable 'MDMExternalEndpoint': $($script:ExternalEndpoint)" -Severity 1 -Source ${CmdletName}
				}
				else {
					Write-LogEntry -Value "[!] Required external endpoint address for AdminService through CMG could not be determined from TS environment variable" -Severity 3 -Source ${CmdletName}
					$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
				}
				$script:ClientID = Get-TSValue -Name "MDMClientID"
				if (-not([string]::IsNullOrEmpty($script:ClientID))) {
					Write-LogEntry -Value "[+] Successfully read client identification for AdminService through CMG from TS environment variable 'MDMClientID': $($script:ClientID)" -Severity 1 -Source ${CmdletName}
				}
				else {
					Write-LogEntry -Value "[!] Required client identification for AdminService through CMG could not be determined from TS environment variable" -Severity 3 -Source ${CmdletName}
					$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
				}
				$script:TenantName = Get-TSValue -Name "MDMTenantName"
				if (-not([string]::IsNullOrEmpty($script:TenantName))) {
					Write-LogEntry -Value "[+] Successfully read client identification for AdminService through CMG from TS environment variable 'MDMTenantName': $($script:TenantName)" -Severity 1 -Source ${CmdletName}
				}
				else {
					Write-LogEntry -Value "[!] Required client identification for AdminService through CMG could not be determined from TS environment variable" -Severity 3 -Source ${CmdletName}
					$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
				}
				$script:ApplicationIDURI = Get-TSValue -Name "MDMApplicationIDURI"
				if (-not([string]::IsNullOrEmpty($script:ApplicationIDURI))) {
					Write-LogEntry -Value "[+] Successfully read Application ID URI from TS environment variable 'MDMApplicationIDURI': $($script:ApplicationIDURI)" -Severity 1 -Source ${CmdletName}
				}
				else {
					Write-LogEntry -Value "[+] Using standard Application ID URI value: https://ConfigMgrService" -Severity 2 -Source ${CmdletName}
					$script:ApplicationIDURI = "https://ConfigMgrService"
				}
			}
		}
    }
    end {
    }
}
#endregion Function Test-AdminServiceData
