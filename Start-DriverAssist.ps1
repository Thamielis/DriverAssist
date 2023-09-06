<#
#>
[CmdletBinding()]
param (
)
begin { }
process {
    ##*=============================================
    ##* FUNCTION LISTINGS
    ##*=============================================
    #region FunctionListings
    #Region '.\Public\Close-TSProgressDialog.ps1' 0
    function Close-TSProgressDialog() {
        Confirm-TSProgressUISetup
        $script:TaskSequenceProgressUi.CloseProgressDialog()
    }
    #EndRegion '.\Public\Close-TSProgressDialog.ps1' 17
    #Region '.\Public\Confirm-TSEnvironmentSetup.ps1' 0
    function Confirm-TSEnvironmentSetup {
        if ($null -eq $script:TaskSequenceEnvironment) {
            try {
                $script:TaskSequenceEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment
            }
            catch {
                throw "Unable to connect to the Task Sequence Environment! Please verify you are in a running Task Sequence Environment.`n`nErrorDetails:`n$_"
            }
        }
    }
    #EndRegion '.\Public\Confirm-TSEnvironmentSetup.ps1' 23
    #Region '.\Public\Confirm-TSProgressUISetup.ps1' 0
    function Confirm-TSProgressUISetup {
        if ($null -eq $script:TaskSequenceProgressUi) {
            try {
                $script:TaskSequenceProgressUi = New-Object -ComObject Microsoft.SMS.TSProgressUI
            }
            catch {
                throw "Unable to connect to the Task Sequence Progress UI! Please verify you are in a running Task Sequence Environment. Please note: TSProgressUI cannot be loaded during a prestart command.`n`nErrorDetails:`n$_"
            }
        }
    }
    #EndRegion '.\Public\Confirm-TSProgressUISetup.ps1' 23
    #Region '.\Public\Get-TSAllValues.ps1' 0

    function Get-TSAllValues() {
        Confirm-TSEnvironmentSetup
        $Values = New-Object -TypeName System.Object
        foreach ($Variable in $script:TaskSequenceEnvironment.GetVariables()) {
            $Values | Add-Member -MemberType NoteProperty -Name $Variable -Value "$($script:TaskSequenceEnvironment.Value($Variable))"
        }
        return $Values
    }
    #EndRegion '.\Public\Get-TSAllValues.ps1' 21
    #Region '.\Public\Get-TSValue.ps1' 0
    function Get-TSValue {
        param(
            [Parameter(Mandatory=$true)]
            [string]$Name
        )
        Confirm-TSEnvironmentSetup
        return $script:TaskSequenceEnvironment.Value($Name)
    }
    #EndRegion '.\Public\Get-TSValue.ps1' 23
    #Region '.\Public\Get-TSVariables.ps1' 0
    function Get-TSVariables() {
        Confirm-TSEnvironmentSetup
        $allVar = @()
        foreach ($variable in $script:TaskSequenceEnvironment.GetVariables()) {
            $allVar += $variable
        }
        return $allVar
    }
    #EndRegion '.\Public\Get-TSVariables.ps1' 21
    #Region '.\Public\Set-TSVariable.ps1' 0
    function Set-TSVariable() {
        param(
            [Parameter(Mandatory=$true)]
            [string]$Name,
            [Parameter(Mandatory=$true)]
            [string]$Value
        )
        Confirm-TSEnvironmentSetup
        try {
            $script:TaskSequenceEnvironment.Value($Name) = $Value
            return $true
        }
        catch {
            return $false
        }
    }
    #EndRegion '.\Public\Set-TSVariable.ps1' 39
    #Region '.\Public\Show-TSActionProgress.ps1' 0
    function Show-TSActionProgress {
        param(
            [Parameter(Mandatory=$true)]
            [string]$Message,
            [Parameter(Mandatory=$true)]
            [long]$Step,
            [Parameter(Mandatory=$true)]
            [long]$MaxStep
        )
        Confirm-TSProgressUISetup
        Confirm-TSEnvironmentSetup
        $script:TaskSequenceProgressUi.ShowActionProgress($script:TaskSequenceEnvironment.Value("_SMSTSOrgName"), $script:TaskSequenceEnvironment.Value("_SMSTSPackageName"), $script:TaskSequenceEnvironment.Value("_SMSTSCustomProgressDialogMessage"), $script:TaskSequenceEnvironment.Value("_SMSTSCurrentActionName"), [Convert]::ToUInt32($script:TaskSequenceEnvironment.Value("_SMSTSNextInstructionPointer")), [Convert]::ToUInt32($script:TaskSequenceEnvironment.Value("_SMSTSInstructionTableSize")), $Message, $Step, $MaxStep)
    }
    #EndRegion '.\Public\Show-TSActionProgress.ps1' 56
    #Region '.\Public\Show-TSErrorDialog.ps1' 0
    function Show-TSErrorDialog() {
        param(
            [Parameter(Mandatory=$true)]
            [string]$OrganizationName,
            [Parameter(Mandatory=$true)]
            [string]$CustomTitle,
            [Parameter(Mandatory=$true)]
            [string]$ErrorMessage,
            [Parameter(Mandatory=$true)]
            [long] $ErrorCode,
            [Parameter(Mandatory=$true)]
            [long] $TimeoutInSeconds,
            [Parameter(Mandatory=$true)]
            [bool] $ForceReboot,
            [Parameter()] #Required for SCCM 1901 Tech Preview and newer clients
            [string]$TSStepName
        )
        Confirm-TSProgressUISetup
        Confirm-TSEnvironmentSetup
        [int]$Reboot = switch($ForceReboot) {
            $True {1}
            $False {0}
        }
        if([string]::IsNullOrEmpty($TSStepName)) {
            $script:TaskSequenceProgressUi.ShowErrorDialog($OrganizationName, $script:TaskSequenceEnvironment.Value("_SMSTSPackageName"), $CustomTitle, $ErrorMessage, $ErrorCode, $TimeoutInSeconds, $Reboot)
        }
        else {
            $script:TaskSequenceProgressUi.ShowErrorDialog($OrganizationName, $script:TaskSequenceEnvironment.Value("_SMSTSPackageName"), $CustomTitle, $ErrorMessage, $ErrorCode, $TimeoutInSeconds, $Reboot, $TSStepName)
        }
    }
    #EndRegion '.\Public\Show-TSErrorDialog.ps1' 68
    #Region '.\Public\Show-TSMessage.ps1' 0
    function Show-TSMessage() {
        param(
            [Parameter(Mandatory=$true)]
            [string]$Message,
            [Parameter(Mandatory=$true)]
            [string]$Title,
            [Parameter(Mandatory=$true)]
            [ValidateRange(0,6)]
            [long] $Type
        )
        Confirm-TSProgressUISetup
        $script:TaskSequenceProgressUi.ShowMessage($Message, $Title, $Type)
    }
    #EndRegion '.\Public\Show-TSMessage.ps1' 46
    #Region '.\Public\Show-TSProgress.ps1' 0
    function Show-TSProgress() {
        param(
            [Parameter(Mandatory=$true)]
            [string]$CurrentAction,
            [Parameter(Mandatory=$true)]
            [long]$Step,
            [Parameter(Mandatory=$true)]
            [long]$MaxStep
        )
        Confirm-TSProgressUISetup
        Confirm-TSEnvironmentSetup
        $script:TaskSequenceProgressUi.ShowTSProgress($script:TaskSequenceEnvironment.Value("_SMSTSOrgName"), $script:TaskSequenceEnvironment.Value("_SMSTSPackageName"), $script:TaskSequenceEnvironment.Value("_SMSTSCustomProgressDialogMessage"), $CurrentAction, $Step, $MaxStep)
    }
    #EndRegion '.\Public\Show-TSProgress.ps1' 54
    #Region '.\Public\Show-TSRebootDialog.ps1' 0
    function Show-TSRebootDialog() {
        param(
            [Parameter(Mandatory=$true)]
            [string]$OrganizationName,
            [Parameter(Mandatory=$true)]
            [string]$CustomTitle,
            [Parameter(Mandatory=$true)]
            [string]$Message,
            [Parameter(Mandatory=$true)]
            [long] $TimeoutInSeconds
        )
        Confirm-TSProgressUISetup
        Confirm-TSEnvironmentSetup
        $script:TaskSequenceProgressUi.ShowRebootDialog($OrganizationName, $script:TaskSequenceEnvironment.Value("_SMSTSPackageName"), $CustomTitle, $Message, $TimeoutInSeconds)
    }
    #EndRegion '.\Public\Show-TSRebootDialog.ps1' 41



    #region Function Confirm-ComputerModel
    function Confirm-ComputerModel {
        <#
        .SYNOPSIS
        Confirm the computer model matches the driver package
        .DESCRIPTION
        Confirm the computer model matches the driver package
        .PARAMETER DriverPackageInput
        Specify the computer model value from the driver package object
        .EXAMPLE
        Confirm-ComputerModel -DriverPackageInput $DriverPackage.Model -ComputerData $ComputerData
        .INPUTS
        [string]DriverPackageInput
        .OUTPUTS
        [bool]True or False
        .NOTES
        Testing as part of the DriverAssist module.
        .LINK
        https://github.com/adamaayala/DriverAssist
        #>
        [CmdletBinding()]
        param (
            [parameter(Mandatory = $true, HelpMessage = "Specify the computer model value from the driver package object.")]
            [ValidateNotNullOrEmpty()]
            [string]$DriverPackageInput,
            [parameter(Mandatory = $true, HelpMessage = "Specify the computer data object.")]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject]$ComputerData
        )
        begin {
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        }
        process {
            # Construct custom object for return value
            $ModelDetectionResult = [PSCustomObject]@{ Detected = $null }
            if ($DriverPackageInput -like $ComputerData.Model) {
                # Computer model match found
                Write-LogEntry -Value "[+] Matched computer model: $($ComputerData.Model)" -Severity 1 -Source ${CmdletName}
                # Set properties for custom object for return value
                $ModelDetectionResult.Detected = $true
            }
            else {
                # Computer model match was not found
                Write-LogEntry -Value "[!] Did not match computer model" -Severity 1 -Source ${CmdletName}
                # Set properties for custom object for return value
                $ModelDetectionResult.Detected = $false
            }
        }
        end {
            return $ModelDetectionResult
        }
    }
    #endregion Function Confirm-ComputerModel


    #region Function Confirm-DriverPackage
    function Confirm-DriverPackage {
        <#
        .SYNOPSIS
        Confirm the driver package matches the computer data from the Get-ComputerData function
        .DESCRIPTION
        Confirm the driver package matches the computer data from the Get-ComputerData function
        .PARAMETER ComputerData
        Specify the computer data object from Get-ComputerData function
        .PARAMETER OSImageData
        Specify the OS Image data object from Get-OSImageDetails function
        .PARAMETER DriverPackage
        Specify the driver package object to be validated. This is the output from the Get-AdminServicePackage function.
        .EXAMPLE
        Confirm-DriverPackage -ComputerData $ComputerData -DriverPackage $DriverPackage
        .INPUTS
        System.Management.Automation.PSCustomObject, System.Object[]
        .OUTPUTS
        [System.Object[]]DriverPackage
        .NOTES
        Testing as part of the DriverAssist module.
        .LINK
        https://github.com/adamaayala/DriverAssist
        #>
        [CmdletBinding()]
        param (
            [parameter(Mandatory = $true, HelpMessage = "Specify the computer data object from Get-ComputerDetails function.")]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject]$ComputerData,
            [parameter(Mandatory = $true, HelpMessage = "Specify the driver package object to be validated. This is the output from the Get-AdminServicePackage function.")]
            [ValidateNotNullOrEmpty()]
            [System.Object[]]$DriverPackage,
            [Parameter(Mandatory = $false, HelpMessage = "Specify the detection method to use for matching driver packages with computer data.")]
            [string]$ComputerDetectionMethod = "SystemSKU"
        )
        begin {
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            # Construct an new array list object to hold the returned driver package objects for filtering
            $DriverPackageList = New-Object -TypeName "System.Collections.ArrayList"
        }
        process {
            #region Filter Driver Packages
            # Sort all driver package objects by package name property
            $driverPackages = $DriverPackage | Sort-Object -Property PackageName
            $driverPackagesCount = ($driverPackages | Measure-Object).Count
            Write-LogEntry -Value "[i] Initial count of driver packages before starting filtering process: $($driverPackagesCount)" -Severity 1 -Source ${CmdletName}

            # Filter out driver packages that do not match with the vendor
            Write-LogEntry -Value "[i] Filtering driver package results to detected computer manufacturer: $($ComputerData.Manufacturer)" -Severity 1 -Source ${CmdletName}
            $driverPackages = $driverPackages | Where-Object { $_.Manufacturer -like $ComputerData.Manufacturer }
            $driverPackagesCount = ($driverPackages | Measure-Object).Count
            Write-LogEntry -Value "[i] Count of driver packages after filter processing: $($driverPackagesCount)" -Severity 1 -Source ${CmdletName}

            # Filter out driver packages that do not contain any value in the package description
            Write-LogEntry -Value "[i] Filtering driver package results to only include packages that have data added to the description field" -Severity 1 -Source ${CmdletName}
            $driverPackages = $driverPackages | Where-Object { $_.Description -ne ([string]::Empty) }
            $driverPackagesCount = ($driverPackages | Measure-Object).Count
            Write-LogEntry -Value "[i] Count of driver packages after filter processing: $($driverPackagesCount)" -Severity 1 -Source ${CmdletName}
            #endregion Filter Driver Packages

            foreach ($driverPackageItem in $driverPackages) {
                # Construct custom object to hold values for current driver package properties used for matching with current computer data
                $driverPackageDetails = [PSCustomObject]@{
                    PackageName    = $driverPackageItem.Name
                    PackageID      = $driverPackageItem.PackageID
                    PackageVersion = $driverPackageItem.Version
                    DateCreated    = $driverPackageItem.SourceDate
                    Manufacturer   = $driverPackageItem.Manufacturer
                    Model          = $null
                    SystemSKU      = $driverPackageItem.Description.Split(":").Replace("(", "").Replace(")", "")[1]
                    OSName         = $null
                }

                # Add driver package model data depending on manufacturer to custom driver package data object
                $driverPackageDetails.Model = $driverPackageItem.Name.Replace($driverPackageItem.Manufacturer, "").Replace(" - ", ":").Split(":").Trim()[1]

                # Add driver package OS name data to custom driver package data object
                if ($driverPackageItem.Name -match "^.*Windows.*(?<OSName>(10|11)).*") { $driverPackageDetails.OSName = -join @("Windows ", $Matches.OSName) }
                switch ($ComputerDetectionMethod) {
                    "SystemSKU" {
                        if ([string]::IsNullOrEmpty($driverPackageDetails.SystemSKU)) {
                            Write-LogEntry -Value "[i] [DriverPackage:$($driverPackageDetails.PackageID)]: Driver package was skipped due to missing SystemSKU values in description field" -Severity 2 -Source ${CmdletName}
                        }
                        else {
                            # Attempt to match against SystemSKU
                            $ComputerDetectionMethodResult = Confirm-SystemSKU -DriverPackageInput $driverPackageDetails.SystemSKU -ComputerData $ComputerData -ErrorAction Stop
                            # Fall back to using computer model as the detection method instead of SystemSKU
                            if ($ComputerDetectionMethodResult.Detected -eq $false) {
                                $ComputerDetectionMethodResult = Confirm-ComputerModel -DriverPackageInput $driverPackageDetails.Model -ComputerData $ComputerData
                            }
                        }
                    }
                    "ComputerModel" {
                        # Attempt to match against computer model
                        $ComputerDetectionMethodResult = Confirm-ComputerModel -DriverPackageInput $driverPackageDetails.Model -ComputerData $ComputerData
                    }
                }
                if ($ComputerDetectionMethodResult.Detected -eq $true) {
                    # Attempt to match against OS name
                    $OSNameDetectionResult = Confirm-OSName -DriverPackageInput $driverPackageDetails.OSName -OSName 'Windows 10'
                    if ($OSNameDetectionResult -eq $true) {
                        # Increase detection counter since OS name detection was successful
                        # Update the SystemSKU value for the custom driver package data object to account for multiple values from original driver package data
                        if ($ComputerDetectionMethod -like "SystemSKU") {
                            $driverPackageDetails.SystemSKU = $ComputerDetectionMethodResult.SystemSKUValue
                        }
                    }
                    $driverPackageList.Add($driverPackageDetails) | Out-Null
                }
            }
        }
        end {
            return $driverPackageList
        }
    }
    #endregion Function Confirm-DriverPackage

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


    #region Function Confirm-SystemSKU
    function Confirm-SystemSKU {
        <#
        .SYNOPSIS
        Confirm the driver package matches the computer data from the Get-ComputerData function based upon SystemSKU
        .DESCRIPTION
        Confirm the driver package matches the computer data from the Get-ComputerData function based upon SystemSKU
        .PARAMETER DriverPackageInput
        Specify the SystemSKU value from the driver package object.
        .PARAMETER ComputerData
        Specify the computer data object from the Get-ComputerData function
        .EXAMPLE
        Confirm-SystemSKU -DriverPackageInput "20FQ" -ComputerData $ComputerData
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
            [parameter(Mandatory = $true, HelpMessage = "Specify the SystemSKU value from the driver package object.")]
            [ValidateNotNullOrEmpty()]
            [string]$DriverPackageInput,
            [parameter(Mandatory = $true, HelpMessage = "Specify the computer data object.")]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject]$ComputerData
        )
        begin {
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        }
        process {
            # Handle multiple SystemSKU's from driver package input and determine the proper delimiter
            if ($DriverPackageInput -match ",") { $SystemSKUDelimiter = "," }
            if ($DriverPackageInput -match ";") { $SystemSKUDelimiter = ";" }
            # Remove any space characters from driver package input data, replace them with a comma instead and ensure there's no duplicate entries
            $DriverPackageInputArray = $DriverPackageInput.Replace(" ", ",").Split($SystemSKUDelimiter) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
            # Construct custom object for return value
            $SystemSKUDetectionResult = [PSCustomObject]@{
                Detected       = $null
                SystemSKUValue = $null
            }
            # Attempt to determine if the driver package input matches with the computer data input and account for multiple SystemSKU's by separating them with the detected delimiter
            if (-not ([string]::IsNullOrEmpty($SystemSKUDelimiter))) {
                # Construct table for keeping track of matched SystemSKU items
                $SystemSKUTable = @{ }
                # Attempt to match for each SystemSKU item based on computer data input
                foreach ($SystemSKUItem in $DriverPackageInputArray) {
                    if ((-not([string]::IsNullOrEmpty($ComputerData.SystemSKU))) -and ($ComputerData.SystemSKU -eq $SystemSKUItem)) {
                        # Add key value pair with match success
                        $SystemSKUTable.Add($SystemSKUItem, $true)
                        # Set custom object property with SystemSKU value that was matched on the detection result object
                        $SystemSKUDetectionResult.SystemSKUValue = $SystemSKUItem
                    }
                    else {
                        # Add key value pair with match failure
                        $SystemSKUTable.Add($SystemSKUItem, $false)
                    }
                }
                # Check if table contains a matched SystemSKU
                if ($SystemSKUTable.Values -contains $true) {
                    # SystemSKU match found based upon multiple items detected in computer data input
                    Write-LogEntry -Value "[+] Matched SystemSKU: $($ComputerData.SystemSKU)" -Severity 1 -Source ${CmdletName}
                    # Set custom object property that SystemSKU value that was matched on the detection result object
                    $SystemSKUDetectionResult.Detected = $true
                    return $SystemSKUDetectionResult
                }
                else {
                    # SystemSKU match was not found based upon multiple items detected in computer data input
                    # Set properties for custom object for return value
                    $SystemSKUDetectionResult.SystemSKUValue = ""
                    $SystemSKUDetectionResult.Detected = $false
                    return $SystemSKUDetectionResult
                }
            }
            elseif ($DriverPackageInput -match $ComputerData.SystemSKU) {
                # SystemSKU match found based upon single item detected in computer data input
                Write-LogEntry -Value "[+] Matched SystemSKU: $($ComputerData.SystemSKU)" -Severity 1 -Source ${CmdletName}
                # Set properties for custom object for return value
                $SystemSKUDetectionResult.SystemSKUValue = $ComputerData.SystemSKU
                $SystemSKUDetectionResult.Detected = $true
                return $SystemSKUDetectionResult
            }
            else {
                # None of the above methods worked to match SystemSKU from driver package input with computer data input
                # Set properties for custom object for return value
                $SystemSKUDetectionResult.SystemSKUValue = ""
                $SystemSKUDetectionResult.Detected = $false
                return $SystemSKUDetectionResult
            }
        }
        end {
        }
    }
    #endregion Function Confirm-SystemSKU


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


    #region Function Get-AuthCredential
    function Get-AuthCredential {
        <#
        .SYNOPSIS
        Constructs a PSCredential object for authentication
        .DESCRIPTION
        Constructs a PSCredential object for authentication.  The UserName and Password variables must be set prior to calling this function.
        .PARAMETER user
        UserName to use for authentication.
        .PARAMETER pass
        Password to use for authentication.
        .EXAMPLE
        $creds = Get-AuthCredential
        .INPUTS
        None
        .OUTPUTS
        System.Management.Automation.PSCredential
        .NOTES
        This function is only useful within a Task Sequence.
        Part of the DriverAssist module.
        .LINK
        https://github.com/adamaayala/DriverAssist
        #>
        [CmdletBinding()]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'SecureString is constructed from a variable that is not a literal string.')]
        param (
        )
        begin {
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            Write-LogEntry -Value "[i] Attempting to read service account credentials from TS environment variables" -Severity 1 -Source ${CmdletName}
            $user = Get-TSValue -Name "MDMUserName"
            $pass = Get-TSValue -Name "MDMPassword"
        }
        process {
            #region Validation
            if (-not ([string]::IsNullOrEmpty($user))) {
                Write-LogEntry -Value "[+] Successfully read service account user name from TS environment variable 'MDMUserName'" -Severity 1 -Source ${CmdletName}
            }
            else {
                Write-LogEntry -Value "[!] Required service account user name could not be determined from TS environment variable" -Severity 3 -Source ${CmdletName}
                throw "Required service account user name could not be determined from TS environment variable"
            }
            if (-not([string]::IsNullOrEmpty($pass))) {
                Write-LogEntry -Value "[+] Successfully read service account password from TS environment variable 'MDMPassword'" -Severity 1 -Source ${CmdletName}
            }
            else {
                Write-LogEntry -Value "[!] Required service account password could not be determined from TS environment variable" -Severity 3 -Source ${CmdletName}
                throw "Required service account password could not be determined from TS environment variable"
            }
            #endregion Validation
            # Construct PSCredential object for authentication and scope to the current session
            $encryptedPass = ConvertTo-SecureString -String $pass -AsPlainText -Force
            $script:credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @($user, $encryptedPass)
            Write-LogEntry -Value "[+] Set 'Credential' variable" -Severity 1 -Source ${CmdletName}
        }
        end {
            return $script:credential
        }
    }
    #endregion Function Get-AuthCredential


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

    #region Function Install-DriverPackageContent
    function Install-DriverPackageContent {
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
            # Full path to the driver package content files
            [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the full path to the driver package content files")]
            [ValidateNotNullOrEmpty()]
            [string]$ContentLocation
        )
        begin {
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            $DriverPackageFile = Get-ChildItem -Path $ContentLocation -Filter "DriverPackage.*"
        }
        process {
            try {
                # Create mount location for driver package WIM file
                $DriverPackageMountLocation = Join-Path -Path $ContentLocation -ChildPath "Mount"
                if (-not (Test-Path -Path $DriverPackageMountLocation)) {
                    Write-LogEntry -Value "[i] Creating mount location directory: $($DriverPackageMountLocation)" -Severity 1 -Source ${CmdletName}
                    New-Item -Path $DriverPackageMountLocation -ItemType "Directory" -Force | Out-Null
                }
            }
            catch [System.Exception] {
                Write-CMLogEntry -Value "[!] Failed to create mount location for WIM file. Error message: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
                throw "Failed to create mount location for WIM file"
            }
            try {
                # Expand compressed driver package WIM file
                Write-LogEntry -Value "[i] Attempting to mount driver package content WIM file: $($DriverPackageFile.Name)" -Severity 1 -Source ${CmdletName}
                Write-LogEntry -Value "[i] Mount location: $($DriverPackageMountLocation)" -Severity 1 -Source ${CmdletName}
                Mount-WindowsImage -ImagePath $DriverPackageFile.FullName -Path $DriverPackageMountLocation -Index 1 -ErrorAction Stop
                Write-LogEntry -Value "[+] Successfully mounted driver package content WIM file" -Severity 1 -Source ${CmdletName}
                Write-LogEntry -Value " - Copying items from mount directory" -Severity 1 -Source ${CmdletName}
                # Get-ChildItem -Path $DriverPackageMountLocation | Copy-Item -destination $ContentLocation -Recurse -container
            }
            catch [System.Exception] {
                Write-LogEntry -Value "[!] Failed to mount driver package content WIM file." -Severity 3 -Source ${CmdletName}
                throw "Failed to mount driver package content WIM file"
            }
        }
        end {
        }
    }
    #endregion Function Install-DriverPackageContent


    #region Function Start-CMDownloadContent
    function Start-CMDownloadContent {
        <#
        .SYNOPSIS
        This function is a wrapper for the OSDDownloadContent.exe executable that is used to download content during the OSD process.
        .DESCRIPTION
        This function is a wrapper for the OSDDownloadContent.exe executable that is used to download content during the OSD process. Specifically, it is used to download content during the Apply Driver Package step in the task sequence.
        .PARAMETER PackageID
        Specify a PackageID that will be downloaded during the OSD process.
        .PARAMETER DestinationLocationType
        Specify the download location type. Valid values are Custom, TSCache, and CCMCache.
        .PARAMETER DestinationVariableName
        Save the download location to the specified task sequence variable name.
        .PARAMETER CustomLocationPath
        When location type is specified as Custom, specify the custom path.
        .EXAMPLE
        Start-CMDownloadContent -PackageID "ABC00000" -DestinationLocationType "Custom" -DestinationVariableName "CustomLocation" -CustomLocationPath "C:\Temp"
        .INPUTS
        None
        .OUTPUTS
        None
        .NOTES
        This function is a wrapper for the OSDDownloadContent.exe executable that is used to download content during the OSD process.
        It is only used during OSD and will not work outside of the OSD process or outside of a task sequence.
        Testing as part of the DriverAssist module.
        .LINK
        https://github.com/adamaayala/DriverAssist
        #>
        [CmdletBinding()]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Not State Changing')]
        param (
            [Parameter(Mandatory = $true, HelpMessage = "Specify a PackageID that will be downloaded.")]
            [ValidateNotNullOrEmpty()]
            [ValidatePattern("^[A-Z0-9]{3}[A-F0-9]{5}$")]
            [string]$PackageID,
            [parameter(Mandatory = $true, HelpMessage = "Specify the download location type.")]
            [ValidateNotNullOrEmpty()]
            [ValidateSet("Custom", "TSCache", "CCMCache")]
            [string]$DestinationLocationType,
            [parameter(Mandatory = $true, HelpMessage = "Save the download location to the specified variable name.")]
            [ValidateNotNullOrEmpty()]
            [string]$DestinationVariableName,
            [parameter(Mandatory = $true, HelpMessage = "When location type is specified as Custom, specify the custom path.")]
            [ValidateNotNullOrEmpty()]
            [string]$CustomLocationPath
        )
        begin {
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        }
        process {
            # Set the task sequence variable: OSDDownloadDownloadPackages
            Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDownloadPackages to: $($PackageID)" -Severity 1 -Source ${CmdletName}
            Set-TSVariable -Name "OSDDownloadDownloadPackages" -Value "$($PackageID)"
            # Set the task sequence variable: OSDDownloadDestinationLocationType
            Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDestinationLocationType to: $($DestinationLocationType)" -Severity 1 -Source ${CmdletName}
            Set-TSVariable -Name "OSDDownloadDestinationLocationType" -Value "$($DestinationLocationType)"
            # Set the task sequence variable: OSDDownloadDestinationVariable
            Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDestinationVariable to: $($DestinationVariableName)" -Severity 1 -Source ${CmdletName}
            Set-TSVariable -Value "$($DestinationVariableName)" -Name "OSDDownloadDestinationVariable"
            # Set the task sequence variable: OSDDownloadDestinationPath
            if ($DestinationLocationType -like "Custom") {
                Write-LogEntry -Value "[+] Setting task sequence variable OSDDownloadDestinationPath to: $($CustomLocationPath)" -Severity 1 -Source ${CmdletName}
                Set-TSVariable -Name "OSDDownloadDestinationPath" -Value "$($CustomLocationPath)"
            }
            # Set SMSTSDownloadRetryCount to 1000 to overcome potential BranchCache issue that will cause 'SendWinHttpRequest failed. 80072efe'
            Set-TSVariable -Name "SMSTSDownloadRetryCount" -Value 1000
            try {
                if (Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\MiniNT) {
                    # We are in WinPE, so we need to use the OSDDownloadContent.exe executable from the boot image
                    Write-LogEntry -Value "[+] Starting package content download process (WinPE), this might take some time" -Severity 1
                    Start-OSDDownloadContent -FilePath "OSDDownloadContent.exe"
                }
                else {
                    # We are in Windows, so we need to use the OSDDownloadContent.exe executable from the CCM folder
                    Write-LogEntry -Value "[+] Starting package content download process (Windows), this might take some time" -Severity 1 -Source ${CmdletName}
                    Start-OSDDownloadContent -FilePath (Join-Path -Path $env:WINDIR -ChildPath "CCM\OSDDownloadContent.exe")
                }
                # Reset SMSTSDownloadRetryCount to 5 after attempted download
                Set-TSVariable -Name "SMSTSDownloadRetryCount" -Value 5
            }
            catch {
                Write-LogEntry -Value "[!] An error occurred while attempting to download package content." -Severity 3 -Source ${CmdletName}
                # Throw terminating error
                throw "An error occurred while attempting to download package content."
            }
        }
        end {
        }
    }
    #endregion Function Start-CMDownloadContent


    #region Function Start-DownloadDriverPackageContent
    function Start-DownloadDriverPackageContent {
        <#
        .SYNOPSIS
        Start the download process for the driver package content files using the Start-CMDownloadContent function. Returns the download location path.
        .DESCRIPTION
        Start the download process for the driver package content files using the Start-CMDownloadContent function. Returns the download location path.
        .PARAMETER DriverPackageList
        Specify a DriverPackageList that will be downloaded. This is the output from the Confirm-DriverPackage function.
        .PARAMETER DestinationLocationType
        Specify the destination location type. Valid values are: Custom, Package, or TaskSequence.
        .PARAMETER DestinationVariableName
        Specify the destination Task Sequence variable name.
        .PARAMETER CustomLocationPath
        Specify the custom location path.
        .EXAMPLE
        Start-DownloadDriverPackageContent -DriverPackageList $DriverPackageList
        .INPUTS
        None
        .OUTPUTS
        [string]DriverPackageContentLocation path
        .NOTES
        This function is a wrapper for the Start-CMDownloadContent function. It is only used during OSD and will not work outside of the OSD process or outside of a task sequence.
        Testing as part of the DriverAssist module.
        .LINK
        https://github.com/adamaayala/DriverAssist
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Not State Changing')]
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify a DriverPackageList that will be downloaded. This is the output from the Confirm-DriverPackage function.")]
            [ValidateNotNullOrEmpty()]$DriverPackageList,
            # Destination Location Type
            [Parameter(Mandatory = $false, HelpMessage = "Specify the destination location type. Valid values are: Custom, Package, or TaskSequence.")]
            [ValidateSet("Custom", "Package", "TaskSequence")]
            [string]$DestinationLocationType = "Custom",
            # Destination Variable Name
            [Parameter(Mandatory = $false, HelpMessage = "Specify the destination variable name.")]
            [string]$DestinationVariableName = "XOSDDriverPackage",
            # Custom Location Path
            [Parameter(Mandatory = $false, HelpMessage = "Specify the custom location path.")]
            [string]$CustomLocationPath = "%_SMSTSMDataPath%\DriverPackage"
        )
        begin {
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        }
        process {
            Write-LogEntry -Value "[i] Attempting to download content files for matched driver package: $($DriverPackageList[0].PackageName)" -Severity 1 -Source ${CmdletName}
            Start-CMDownloadContent -PackageID $DriverPackageList[0].PackageID -DestinationLocationType $DestinationLocationType -DestinationVariableName $DestinationVariableName -CustomLocationPath $CustomLocationPath
            # If download process was successful, meaning exit code from above function was 0, return the download location path
            $DriverPackageContentLocation = Get-TSValue -Name "$($DriverVariableName)01"
            Write-LogEntry -Value "[+] Driver package content files was successfully downloaded to: $($DriverPackageContentLocation)" -Severity 1 -Source ${CmdletName}
        }
        end {
            # Handle return value for successful download of driver package content files
            return $DriverPackageContentLocation
        }
    }
    #endregion Function Start-DownloadDriverPackageContent


    #region Function Start-OSDDownloadContent
    function Start-OSDDownloadContent {
        <#
        .SYNOPSIS
        Starts the OSD Download Content executable with optional arguments.
        .DESCRIPTION
        Starts the OSD Download Content executable with optional arguments. This is a wrapper for the OSDDownloadContent.exe executable that is used to download content during the OSD process.
        .PARAMETER Path
        Path to the OSDDownloadContent executable
        .PARAMETER Parameters
        Arguments to be passed to the executable
        .PARAMETER WindowStyle
        Style of the window of the process executed. Options: Normal, Hidden, Maximized, Minimized. Default: Normal.
        Note: Not all processes honor WindowStyle. WindowStyle is a recommendation passed to the process. They can choose to ignore it.
        Only works for native Windows GUI applications. If the WindowStyle is set to Hidden, UseShellExecute should be set to $true.
        .PARAMETER CreateNoWindow
        Specifies whether the process should be started with a new window to contain it. Only works for Console mode applications. UseShellExecute should be set to $false.
        Default is false.
        .PARAMETER IgnoreExitCodes
        List the exit codes to ignore or * to ignore all exit codes.
        .PARAMETER PriorityClass
        Specifies priority class for the process. Options: Idle, Normal, High, AboveNormal, BelowNormal, RealTime. Default: Normal
        .PARAMETER ContinueOnError
        Continue if an error occured while trying to start the process. Default: $false.
        .EXAMPLE
        Start-OSDDownloadContent -Path 'C:\Temp\OSDDownloadContent.exe' -Parameters '-Command "& { Write-Host "Test" }"'
        .INPUTS
        None
        .OUTPUTS
        System.Diagnostics.Process
        .NOTES
        .LINK
        https://github.com/adamaayala/DriverAssist
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Not State Changing')]
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true)]
            [Alias('FilePath')]
            [ValidateNotNullorEmpty()]
            [string]$Path,
            [Parameter(Mandatory = $false)]
            [Alias('Arguments')]
            [ValidateNotNullorEmpty()]
            [string[]]$Parameters,
            [Parameter(Mandatory = $false)]
            [ValidateSet('Normal', 'Hidden', 'Maximized', 'Minimized')]
            [Diagnostics.ProcessWindowStyle]$WindowStyle = 'Normal',
            [Parameter(Mandatory = $false)]
            [ValidateNotNullorEmpty()]
            [switch]$CreateNoWindow = $false,
            [Parameter(Mandatory = $false)]
            [ValidateNotNullorEmpty()]
            [string]$IgnoreExitCodes,
            [Parameter(Mandatory = $false)]
            [ValidateSet('Idle', 'Normal', 'High', 'AboveNormal', 'BelowNormal', 'RealTime')]
            [Diagnostics.ProcessPriorityClass]$PriorityClass = 'Normal',
            [Parameter(Mandatory = $false)]
            [ValidateNotNullorEmpty()]
            [bool]$UseShellExecute = $false,
            [Parameter(Mandatory = $false)]
            [ValidateNotNullorEmpty()]
            [bool]$ContinueOnError = $false
        )
        begin {
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        }
        process {
            try {
                $private:returnCode = $null
                # If the WindowStyle parameter is set to 'Hidden', set the UseShellExecute parameter to '$true'.
                if ($WindowStyle -eq 'Hidden') { $UseShellExecute = $true }
                try {
                    # Disable Zone checking to prevent warnings when running executables
                    $env:SEE_MASK_NOZONECHECKS = 1
                    # Using this variable allows capture of exceptions from .NET methods. Private scope only changes value for current function.
                    $private:previousErrorActionPreference = $ErrorActionPreference
                    $ErrorActionPreference = 'Stop'
                    # Define process
                    $processStartInfo = New-Object -TypeName 'System.Diagnostics.ProcessStartInfo' -ErrorAction 'Stop'
                    $processStartInfo.FileName = $Path
                    $processStartInfo.UseShellExecute = $UseShellExecute
                    $processStartInfo.ErrorDialog = $false
                    $processStartInfo.RedirectStandardOutput = $true
                    $processStartInfo.RedirectStandardError = $true
                    $processStartInfo.CreateNoWindow = $CreateNoWindow
                    if ($Parameters) { $processStartInfo.Arguments = $Parameters }
                    $processStartInfo.WindowStyle = $WindowStyle
                    if ($processStartInfo.UseShellExecute -eq $true) {
                        Write-LogEntry -Value '[i] UseShellExecute is set to true, standard output and error will not be available.' -Severity 1 -Source ${CmdletName}
                        $processStartInfo.RedirectStandardOutput = $false
                        $processStartInfo.RedirectStandardError = $false
                    }
                    $process = New-Object -TypeName 'System.Diagnostics.Process' -ErrorAction 'Stop'
                    $process.StartInfo = $processStartInfo
                    if ($processStartInfo.UseShellExecute -eq $false) {
                        # Add event handler to capture process's standard output redirection
                        [scriptblock]$processEventHandler = { if (-not [string]::IsNullOrEmpty($EventArgs.Data)) { $Event.MessageData.AppendLine($EventArgs.Data) } }
                        $stdOutBuilder = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList ('')
                        $stdOutEvent = Register-ObjectEvent -InputObject $process -Action $processEventHandler -EventName 'OutputDataReceived' -MessageData $stdOutBuilder -ErrorAction 'Stop'
                        $stdErrBuilder = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList ('')
                        $stdErrEvent = Register-ObjectEvent -InputObject $process -Action $processEventHandler -EventName 'ErrorDataReceived' -MessageData $stdErrBuilder -ErrorAction 'Stop'
                    }
                    # Start Process
                    if ($Parameters) {
                        if ($Parameters -match '-Command \&') {
                            Write-LogEntry -Value "[i] Executing [$Path [PowerShell scriptblock]]..." -Severity 1 -Source ${CmdletName}
                        }
                        else {
                            Write-LogEntry -Value "[i] Executing [$Path $Parameters]..." -Severity 1 -Source ${CmdletName}
                        }
                    }
                    else {
                        Write-LogEntry -Value "[i] Executing [$Path]..." -Severity 1 -Source ${CmdletName}
                    }
                    $null = $process.Start()
                    # Set priority
                    if ($PriorityClass -ne 'Normal') {
                        try {
                            if ($process.HasExited -eq $false) {
                                Write-LogEntry "[i] Changing the priority class for the process to [$PriorityClass]" -Severity 1 -Source ${CmdletName}
                                $process.PriorityClass = $PriorityClass
                            }
                            else {
                                Write-LogEntry -Value "[i] Cannot change the priority class for the process to [$PriorityClass], because the process has exited already." -Severity 1 -Source ${CmdletName}
                            }
                        }
                        catch {
                            Write-LogEntry -Value "[!] Failed to change the priority class for the process to [$PriorityClass]. $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
                        }
                    }

                    if ($processStartInfo.UseShellExecute -eq $false) {
                        $process.BeginOutputReadLine()
                        $process.BeginErrorReadLine()
                    }
                    # Instructs the Process component to wait indefinitely for the associated process to exit.
                    $process.WaitForExit()
                    # HasExited indicates that the associated process has terminated, either normally or abnormally. Wait until HasExited returns $true.
                    while (-not $process.HasExited) {
                        $process.Refresh(); Start-Sleep -Seconds 1
                    }
                    # Get the exit code for the process
                    try {
                        [int32]$returnCode = $process.ExitCode
                        Write-LogEntry -Value "[i] Process exit code: [$returnCode]" -Severity 1 -Source ${CmdletName}
                    }
                    catch [System.Management.Automation.PSInvalidCastException] {
                        # Catch exit codes that are out of int32 range
                        [int32]$returnCode = 60013
                    }
                    if ($processStartInfo.UseShellExecute -eq $false) {
                        # Unregister standard output and error event to retrieve process output
                        if ($stdOutEvent) {
                            Unregister-Event -SourceIdentifier $stdOutEvent.Name -ErrorAction 'Stop'; $stdOutEvent = $null
                        }
                        if ($stdErrEvent) {
                            Unregister-Event -SourceIdentifier $stdErrEvent.Name -ErrorAction 'Stop'; $stdErrEvent = $null
                        }
                        $stdOut = $stdOutBuilder.ToString() -replace $null, ''
                        $stdErr = $stdErrBuilder.ToString() -replace $null, ''
                        if ($stdErr.Length -gt 0) {
                            Write-LogEntry -Value "[!] Standard error output from the process: $stdErr" -Severity 3 -Source ${CmdletName}
                        }
                    }

                }
                finally {
                    if ($processStartInfo.UseShellExecute -eq $false) {
                        # Make sure the standard output and error event is unregistered
                        if ($stdOutEvent) {
                            Unregister-Event -SourceIdentifier $stdOutEvent.Name -ErrorAction 'SilentlyContinue'; $stdOutEvent = $null
                        }
                        if ($stdErrEvent) {
                            Unregister-Event -SourceIdentifier $stdErrEvent.Name -ErrorAction 'SilentlyContinue'; $stdErrEvent = $null
                        }
                    }
                    # Free resources associated with the process, this does not cause process to exit
                    if ($process) { $process.Dispose() }
                    # Re-enable Zone checking
                    Remove-Item -LiteralPath 'env:SEE_MASK_NOZONECHECKS' -ErrorAction 'SilentlyContinue'
                    if ($private:previousErrorActionPreference) {
                        $ErrorActionPreference = $private:previousErrorActionPreference
                    }
                }
                # Check to see whether we should ignore exit codes
                $ignoreExitCodeMatch = $false
                if ($ignoreExitCodes) {
                    # Check whether * was specified, which would tell us to ignore all exit codes
                    if ($ignoreExitCodes.Trim() -eq '*') {
                        $ignoreExitCodeMatch = $true
                    }
                    else {
                        # Split the processes on a comma
                        [Int32[]]$ignoreExitCodesArray = $ignoreExitCodes -split ','
                        foreach ($ignoreCode in $ignoreExitCodesArray) {
                            if ($returnCode -eq $ignoreCode) {
                                $ignoreExitCodeMatch = $true
                            }
                        }
                    }
                }
                # If the passthru switch is specified, return the exit code and any output from process
                if ($PassThru) {
                    Write-LogEntry -Value "[i] PassThru parameter specified, returning execution results object. Exit code: [$returnCode]" -Severity 1 -Source ${CmdletName}
                    [psobject]$ExecutionResults = New-Object -TypeName 'PSObject' -Property @{ ExitCode = $returnCode; StdOut = if ($stdOut) {
                            $stdOut
                        }
                        else {
                            ''
                        }; StdErr = if ($stdErr) {
                            $stdErr
                        }
                        else {
                            ''
                        }
                    }
                    Write-Output -InputObject ($ExecutionResults)
                }
                if ($ignoreExitCodeMatch) {
                    Write-LogEntry -Value "[+] Execution completed and the exit code [$returncode] is being ignored." -Severity 1 -Source ${CmdletName}
                }
                elseif ($returnCode -eq 0) {
                    Write-LogEntry -Value "[+] Execution completed successfully with exit code [$returnCode]." -Severity 1 -Source ${CmdletName}
                }
                else {
                    Write-LogEntry -Value "[!] Execution failed with exit code [$returnCode]." -Severity 3 -Source ${CmdletName}
                }
            }
            catch {
                if ([string]::IsNullOrEmpty([string]$returnCode)) {
                    [int32]$returnCode = 60002
                    Write-LogEntry -Value "[!] Function failed, setting exit code to [$returnCode]." -Severity 3 -Source ${CmdletName}
                    if (-not $ContinueOnError) {
                        throw "Function failed, setting exit code to [$returnCode]. $($_.Exception.Message)"
                    }
                }
                else {
                    Write-LogEntry "[!] Execution completed with exit code [$returnCode]. Function failed." -Severity 3 -Source ${CmdletName}
                }
                if ($PassThru) {
                    [psobject]$ExecutionResults = New-Object -TypeName 'PSObject' -Property @{
                        ExitCode = $returnCode; StdOut = if ($stdOut) {
                            $stdOut
                        }
                        else {
                            ''
                        }; StdErr = if ($stdErr) {
                            $stdErr
                        }
                        else {
                            ''
                        }
                    }
                    Write-Output -InputObject ($ExecutionResults)
                }
            }
        }
        end {
        }
    }
    #endregion Function Start-OSDDownloadContent

    #region Function Write-LogEntry
    function Write-LogEntry {
        <#
        .SYNOPSIS
        Writes a detailed and informational log entry
        .DESCRIPTION
        Writes a detailed and informational log entry
        .PARAMETER Value
        Writes an informational log entry
        .PARAMETER Severity
        Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.
        .PARAMETER Source
        Source of the log entry used for debugging purposes.
        .PARAMETER FileName
        Name of the log file that the entry will written to.
        .PARAMETER LogsDirectory
        Path to the logging directory.
        .EXAMPLE
        Write-LogEntry -Value "This is a message" -Severity 2
        Writes a log entry
        .INPUTS
        None
        .OUTPUTS
        None
        .NOTES
        Testing as part of the DriverAssist module.
        .LINK
        https://github.com/adamaayala/DriverAssist
        #>
        [CmdletBinding()]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Writes to the console for debugging purposes')]
        param (
            [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Value added to the log file.")]
            [ValidateNotNullOrEmpty()]
            [Alias("Message")]
            [string]$Value,
            [Parameter(Mandatory = $false, HelpMessage = "Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.")]
            [ValidateNotNullOrEmpty()]
            [ValidateSet("1", "2", "3")]
            [string]$Severity = 1,
            # Parameter help description
            [Parameter(Mandatory = $false, HelpMessage = "Source of the log entry used for debugging purposes.")]
            [ValidateNotNullOrEmpty()]
            [string]$Source = $([string]$parentFunctionName = [IO.Path]::GetFileNameWithoutExtension((Get-Variable -Name 'MyInvocation' -Scope 1 -ErrorAction 'SilentlyContinue').Value.MyCommand.Name); if ($parentFunctionName) {$parentFunctionName} else { 'Unknown' }),
            [Parameter(Mandatory = $false, HelpMessage = "Name of the log file that the entry will written to.")]
            [ValidateNotNullOrEmpty()]
            [string]$FileName = "DriverAssist.log", # Default the value for testing
            [Parameter(Mandatory = $false)]
            [string]$LogsDirectory
        )
        begin {
            # Get the logging file path
            if (Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\MiniNT) {
                $LogsDirectory = 'X:\Windows\TEMP'
            }
            else {
                $LogsDirectory = $env:TEMP
            }
            $logFilePath = Join-Path -Path $LogsDirectory -ChildPath $FileName
        }
        process {
            $Time = Get-Date -Format "HH:mm:ss.fff"
            $Date = Get-Date -Format "MM-dd-yyyy"
            $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
            $logText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""OSD"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"
            try {
                Out-File -InputObject $logText -Append -NoClobber -FilePath $logFilePath -ErrorAction Stop -Encoding default
                Write-Host "$($Value) :: Cmdlet : $($Source)"
            }
            catch [System.Exception] {
                Write-Warning -Message "Unable to append log entry to $($FileName) file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
            }
        }
        end {
        }
    }
    #endregion Function Write-LogEntry
    #endregion FunctionListings
    ##*=============================================
    ##* END FUNCTION LISTINGS
    ##*=============================================
    ##*=============================================
    ##* SCRIPT BODY
    ##*=============================================
    #region ScriptBody
    Write-LogEntry -Value "[i] ------------------------------ Starting DriverAssist Script" -Severity 1 -Source "DriverAssist"
    # Get the computer details. This function returns a custom object with the following properties: Manufacturer, Model, and SystemSKU
    Write-LogEntry -Value "[i] ------------------------------ Getting computer details" -Severity 1 -Source "DriverAssist"
    $computerData = Get-ComputerData
    # Get the driver package list using the ComputerData object Model property to filter the AdminServicePackage cmdlet
    Write-LogEntry -Value "[i] ------------------------------ Getting driver package list" -Severity 1 -Source "DriverAssist"
    $driverPackages = Get-AdminServicePackage -Model $computerData.Model
    # Confirm the driver package list and filter out any driver packages that do not match the SystemSKU
    Write-LogEntry -Value "[i] ------------------------------ Confirming driver package list" -Severity 1 -Source "DriverAssist"
    $driverPackageList = Confirm-DriverPackage -DriverPackage $driverPackages -ComputerData $computerData
    # If the driver package list is not empty, download the driver package content files
    if ($driverPackageList) {
        Write-LogEntry -Value "[i] ------------------------------ Starting download of driver package content files" -Severity 1 -Source "DriverAssist"
        $driverPackageContentLocation = Start-DownloadDriverPackageContent -DriverPackageList $driverPackageList
        # If the driver package content files were successfully downloaded, install the driver package content files
        # if ($driverPackageContentLocation) {
        #     Write-LogEntry -Value "[i] ------------------------------ Starting installation of driver package content files" -Severity 1 -Source "DriverAssist"
        #     Install-DriverPackageContent -ContentLocation $driverPackageContentLocation
        # }
    }

    #endregion ScriptBody
    ##*=============================================
    ##* END SCRIPT BODY
    ##*=============================================
}
end { }
