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
if (Get-Module -Name $ProjectName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ProjectName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

Describe Confirm-DriverPackage -Tag 'Unit' {
InModuleScope $ProjectName {
    Context "When calling the function with valid input" {
        BeforeAll {
            # Mock Confirm-SystemSKU, Confirm-ComputerModel, and Confirm-OSName functions
            Mock Confirm-SystemSKU { return @{ Detected = $true; SystemSKUValue = "0A52" } }
            Mock Confirm-ComputerModel { return @{ Detected = $true } }
            Mock Confirm-OSName { $true }
            Mock Write-LogEntry {}
            $testURI = "https://sccm2016.amaisd.org/AdminService/wmi/SMS_Package?`$filter=contains(Name,'Optiplex 7090')"
            $testData = Invoke-RestMethod -Method Get -Uri $testURI -UseDefaultCredentials
            $script:testOData = $testData.value
            $script:fakeComputerData = [PSCustomObject]@{
                Model = "OptiPlex 7090"
                SystemSKU = "0A52"
                OSName = "Windows 10"
                Manufacturer = "Dell"
            }
        }
        It "Should return a non-empty array list of driver package objects" {
            $driverPackageList = Confirm-DriverPackage -ComputerData $script:fakeComputerData  -DriverPackage $script:testOData
            $driverPackageList | Should -Not -BeNullOrEmpty
        }
        It "Should return driver package objects with the expected properties" {
            $driverPackageList = Confirm-DriverPackage -DriverPackage $script:testOData -ComputerDetectionMethod "SystemSKU" -ComputerData $script:fakeComputerData
            $driverPackageList[0].PackageName | Should -Be 'Drivers - Dell Optiplex 7090 - Windows 10 x64'
            $driverPackageList[0].PackageID | Should -Be 'ESC00103'
            $driverPackageList[0].PackageVersion | Should -Be '7090'

        }
    }
    # Context "When calling the function with invalid input" {
    #     BeforeAll {
    #         # Mock Confirm-SystemSKU, Confirm-ComputerModel, and Confirm-OSName functions
    #         Mock Confirm-SystemSKU { throw "Invalid input" }
    #         Mock Confirm-ComputerModel { throw "Invalid input" }
    #         Mock Confirm-OSName { throw "Invalid input" }
    #         Mock Write-LogEntry {}
    #         $testData = Get-Content -Path "D:\repos\DriverAssist\testdata\Bad_SMS_Package .json" | ConvertFrom-Json
    #         $script:testOData = $testData.value
    #         $script:fakeComputerData = [PSCustomObject]@{
    #             Model = "OptiPlex 7090"
    #             SystemSKU = "0A52"
    #             OSName = "Windows 10"
    #             Manufacturer = "Dell"
    #         }
    #     }
    #     It "Should throw an error" {
    #         { Confirm-DriverPackage -DriverPackageList @() -ComputerDetectionMethod "SystemSKU" -ComputerData @{} } | Should -Throw
    #     }
    # }
    # Context "When calling the function with a single driver package input that matches the computer data on Model" {
    #     BeforeAll {
    #         # Mock Confirm-ComputerModel and Confirm-OSName functions
    #         Mock Confirm-ComputerModel { return @{ Detected = $true; Model = "TestModel" } }
    #         Mock Confirm-OSName { return $true }
    #         Mock Write-LogEntry {}
    #         $testData = Get-Content -Path "D:\repos\DriverAssist\testdata\Bad_SMS_Package .json" | ConvertFrom-Json
    #         $script:testOData = $testData.value
    #         $script:fakeComputerData = [PSCustomObject]@{
    #             Model = "OptiPlex 7090"
    #             SystemSKU = "0A52"
    #             OSName = "Windows 10"
    #             Manufacturer = "Dell"
    #         }
    #     }
    #     It "Should return driver package objects with the expected properties" {
    #         Confirm-DriverPackage -DriverPackage $script:testOData  -ComputerDetectionMethod "SystemSKU" -ComputerData $script:fakeComputerData
    #         Should -Invoke Write-LogEntry -Exactly -Times 5
    #     }
    # }
}
}
