#region Function ConvertTo-ObfuscatedUserName
function ConvertTo-ObfuscatedUserName {
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
        [parameter(Mandatory = $true, HelpMessage = "Specify the user name string to be obfuscated for log output.")]
        [ValidateNotNullOrEmpty()]
        [string]$InputObject
    )
    begin {
        $UserNameArray = $InputObject.ToCharArray()
    }
    process {
        for ($i = 0; $i -lt $UserNameArray.Count; $i++) {
			if ($UserNameArray[$i] -notmatch "@") {
				if ($i % 2) {
					$UserNameArray[$i] = "*"
				}
			}
		}
    }
    end {
        return -join @($UserNameArray)
    }
}
#endregion Function ConvertTo-ObfuscatedUserName
