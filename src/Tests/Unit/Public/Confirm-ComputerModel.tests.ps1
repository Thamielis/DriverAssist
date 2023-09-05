$ProjectRoot = "$PSScriptRoot\..\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectRoot\*\*\*.psd1).Where{
    ($_.Directory.Name -match 'src' -or $_.Directory.Name -eq $_.BaseName) -and
    $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
}).BaseName
#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ProjectName, "$ProjectName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ProjectName -ErrorAction 'SilentlyContinue') { Remove-Module -Name $ProjectName -Force }
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

Describe Confirm-ComputerModel -Tag 'Unit' {
InModuleScope $ProjectName {
    BeforeAll {
        Mock Write-LogEntry { }
    }
    Context 'When comparing the computer model' {
        BeforeAll {
            $script:fakeComputerModel = @{
                Model = 'HP EliteBook 840 G3'
            }
        }
        It 'it returns true for the custom object for confirmation' {
            $DriverPackageDetails = [PSCustomObject]@{ Model = 'HP EliteBook 840 G3'}
            $result = Confirm-ComputerModel -DriverPackageInput $DriverPackageDetails.Model -ComputerData $script:fakeComputerModel
            $result.Detected | Should -Be $true
            Should -Invoke Write-LogEntry -Exactly -Times 1
        }
        It 'it returns false for the custom object for confirmation' {
            $DriverPackageDetails = [PSCustomObject]@{ Model = 'Optiplex'}
            $result = Confirm-ComputerModel -DriverPackageInput $DriverPackageDetails.Model -ComputerData $script:fakeComputerModel
            $result.Detected | Should -Be $false
            Should -Invoke Write-LogEntry -Exactly -Times 1
        }
    }
}
}
