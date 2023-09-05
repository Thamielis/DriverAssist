#region Function Get-ComputerData
function Get-ComputerData {
    <#
    .SYNOPSIS
    Retrieves computer details from the Task Sequence environment provided by the UI Component
    .DESCRIPTION
    Retrieves computer details from the Task Sequence environment provided by the UI Component. The Manufacturer, Model, and SystemSKU variables.
    .EXAMPLE
    Get-ComputerData
    .INPUTS
    None
    .OUTPUTS
    System.Management.Automation.PSCustomObject
    .NOTES
    Testing as part of the DriverAssist module. This function is not intended to be used outside of the DriverAssist module.
    This function only works in a task sequence environment and after the UI component has been run.
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
        # Create a custom object for computer details gathered from the task sequence environment
        $computerDetails = [PSCustomObject]@{
            Manufacturer = $null
            Model        = (Get-TSValue -Name 'XHWModel')
            SystemSKU    = (Get-TSValue -Name 'XHWProductSKU')
        }
        # Gather computer details based upon specific computer manufacturer and normalize the manufacturer name
        $computerManufacturer = (Get-TSValue -Name 'XHWManufacturer').Trim()
        switch -Wildcard ($computerManufacturer) {
            "*Microsoft*"       { $ComputerDetails.Manufacturer = "Microsoft" }
            "*HP*"              { $ComputerDetails.Manufacturer = "HP" }
            "*Hewlett-Packard*" { $ComputerDetails.Manufacturer = "HP" }
            "*Dell*"            { $ComputerDetails.Manufacturer = "Dell" }
            "*Lenovo*"          { $ComputerDetails.Manufacturer = "Lenovo" }
            "*Panasonic*"       { $ComputerDetails.Manufacturer = "Panasonic Corporation" }
            "*Viglen*"          { $ComputerDetails.Manufacturer = "Viglen" }
            "*AZW*"             { $ComputerDetails.Manufacturer = "AZW" }
            "*Fujitsu*"         { $ComputerDetails.Manufacturer = "Fujitsu" }
            "*Getac*"           { $ComputerDetails.Manufacturer = "Getac" }
            "*Clear Touch*"     { $ComputerDetails.Manufacturer = "ClearTouch" }
        }
        Write-LogEntry -Value "[+] Computer manufacturer determined as: $($ComputerDetails.Manufacturer)" -Severity 1 -Source ${CmdletName}
        Write-LogEntry -Value "[+] Computer model determined as: $($ComputerDetails.Model)" -Severity 1 -Source ${CmdletName}
        if (-not([string]::IsNullOrEmpty($ComputerDetails.SystemSKU))) {
            Write-LogEntry -Value "[+] Computer SystemSKU determined as: $($ComputerDetails.SystemSKU)" -Severity 1 -Source ${CmdletName}
        }
        else {
            Write-LogEntry -Value "[-] Computer SystemSKU determined as: <null>" -Severity 2 -Source ${CmdletName}
        }
    }
    end {
        return $computerDetails
    }
}
#endregion Function Get-ComputerData