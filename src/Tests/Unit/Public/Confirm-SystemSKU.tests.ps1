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

Describe Confirm-SystemSKU -Tag 'Unit' {
InModuleScope $ProjectName {
    BeforeAll {
            $script:computerData = [PSCustomObject]@{
            SystemSKU = "ABC123"
        }
        Mock Write-LogEntry { }
    }
    Context "When calling the function with a single SystemSKU input that matches the computer data" {
        It "Should return a PSCustomObject with Detected set to true and SystemSKUValue set to the matched SystemSKU" {
            $driverPackageInput = "ABC123"
            $result = Confirm-SystemSKU -DriverPackageInput $driverPackageInput -ComputerData $computerData
            $result | Should -BeOfType [PSCustomObject]
            $result.Detected | Should -Be $true
            $result.SystemSKUValue | Should -Be $driverPackageInput
        }
    }

    Context "When calling the function with a single SystemSKU input that does not match the computer data" {
        It "Should return a PSCustomObject with Detected set to false and SystemSKUValue set to an empty string" {
            $driverPackageInput = "DEF456"
            $result = Confirm-SystemSKU -DriverPackageInput $driverPackageInput -ComputerData $computerData
            $result | Should -BeOfType [PSCustomObject]
            $result.Detected | Should -Be $false
            $result.SystemSKUValue | Should -Be ""
        }
    }

    Context "When calling the function with multiple SystemSKU inputs and one matches the computer data" {
        It "Should return a PSCustomObject with Detected set to true and SystemSKUValue set to the matched SystemSKU" {
            $driverPackageInput = "ABC123;DEF456;GHI789"
            $result = Confirm-SystemSKU -DriverPackageInput $driverPackageInput -ComputerData $computerData
            $result | Should -BeOfType [PSCustomObject]
            $result.Detected | Should -Be $true
            $result.SystemSKUValue | Should -Be "ABC123"
        }
    }

    Context "When calling the function with multiple SystemSKU inputs and none match the computer data" {
        It "Should return a PSCustomObject with Detected set to false and SystemSKUValue set to an empty string" {
            $driverPackageInput = "DEF456,GHI789"
            $result = Confirm-SystemSKU -DriverPackageInput $driverPackageInput -ComputerData $computerData
            $result | Should -BeOfType [PSCustomObject]
            $result.Detected | Should -Be $false
            $result.SystemSKUValue | Should -Be ""
        }
    }
}
}
