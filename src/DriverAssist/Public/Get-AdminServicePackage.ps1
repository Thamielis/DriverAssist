#region Function Get-AdminServicePackage
function Get-AdminServicePackage {
    <#
    .SYNOPSIS
    Retrieves a list of driver items from the AdminService using the FQDN of the ConfigMgr site server API and the resource path.
    .DESCRIPTION
    Retrieves a list of driver items from the AdminService API using the FQDN of the ConfigMgr site server API and the resource path.
    .PARAMETER Filter
    The filter for the AdminService API call, e.g. 'Optiplex 2600' for the SMS_Package resource.
    .EXAMPLE
    Get-AdminServicePackage -Filter 'Optiplex 2600'
    .EXAMPLE
    Get-AdminServicePackage -Filter 'Latitude 7400'
    .INPUTS
    None
    .OUTPUTS
    System.Collections.ArrayList
    .NOTES
    This function only works within a Task Sequence environment. It uses the Get-AuthCredential and Set-AdminServiceURL functions from the DriverAssist module.
    Testing as part of the DriverAssist module.
    .LINK
    This function only works within a Task Sequence environment.
    https://github.com/adamaayala/DriverAssist
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify the filter for the AdminService API call, e.g. 'Optiplex 2600'")]
        [string]$Model
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        # Get the AdminService FQDN from the TS environment variable set by the task sequence
        $adminServiceFQDN = Get-TSValue -Name "XAdminServiceFQDN"
        # Constuct an new array list object to hold the returned AdminService package objects
        $packageArray = New-Object -TypeName System.Collections.ArrayList
    }
    process {
        try {
            # Get the credential object from the Get-AuthCredential function
            Write-LogEntry -Value "[i] Retrieving credential object from Get-AuthCredential function" -Severity 1 -Source ${CmdletName}
            $script:credential = Get-AuthCredential
            # Construct the AdminService URI using the FQDN of the ConfigMgr site server API and the resource path
            $adminServiceURI = "https://$($adminServiceFQDN)/AdminService/wmi/SMS_Package?`$filter=contains(Name,'$($Model)')"
            Write-LogEntry -Value "[i] Calling AdminService endpoint with URI: $($adminServiceUri)" -Severity 1 -Source ${CmdletName}
            $adminServiceResponse = Invoke-RestMethod -Method Get -Uri $adminServiceURI -Credential $script:credential
            if ($adminServiceResponse) {
                Write-LogEntry -Value "[+] Successfully retrieved available package items from AdminService endpoint for $($Model)" -Severity 1 -Source ${CmdletName}
            }
        }
        catch {
            Write-LogEntry -Value "[!] Failed to retrieve available package items from AdminService endpoint. Error message: $($PSItem.Exception.Message)" -Severity 3 -Source ${CmdletName}
            throw "Failed to retrieve available package items from AdminService endpoint"
        }
        # Add returned driver package objects to array list
        if ($null -ne $adminServiceResponse.value) {
            foreach ($package in $AdminServiceResponse.value) {
                $packageArray.Add($package) | Out-Null
            }
        }
    }
    end {
        return $packageArray
    }
}
#endregion Function Get-AdminServicePackage