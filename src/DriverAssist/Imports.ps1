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

