#region Function Get-DeploymentType
function Get-DeploymentType {
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
        switch ($PSCmdlet.ParameterSetName) {
			"XMLPackage" {
				# Set required variables for XMLPackage parameter set
				$script:DeploymentMode = $Script:XMLDeploymentType
				$script:PackageSource = "XML Package Logic file"
				# Define the path for the pre-downloaded XML Package Logic file called DriverPackages.xml
				$script:XMLPackageLogicFile = (Join-Path -Path $TSEnvironment.Value("MDMXMLPackage01") -ChildPath "DriverPackages.xml")
				if (-not (Test-Path -Path $XMLPackageLogicFile)) {
					Write-LogEntry -Value "[!] Failed to locate required 'DriverPackages.xml' logic file for XMLPackage deployment type, ensure it has been pre-downloaded in a Download Package Content step before running this script" -Severity 3 -Source ${CmdletName}
				}
			}
			default {
				$script:DeploymentMode = $Script:PSCmdlet.ParameterSetName
				$script:PackageSource = "AdminService"
			}
		}
    }
    end {
    }
}
#endregion Function Get-DeploymentType
