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

Describe Start-CMDownloadContent -Tag 'Unit' {
InModuleScope $ProjectName {
    Context "When calling the function with valid input" {
        BeforeAll {
            $packageID = "AAA00103"
            $destinationLocationType = "Custom"
            $destinationVariableName = "TestDestinationVariableName"
            $customLocationPath = "C:\Test\Custom\Location"
            Mock Set-TSVariable {}
            Mock Write-LogEntry {}
            Mock Start-OSDDownloadContent {}
        }
        It "Should set the task sequence variables correctly" {
            Start-CMDownloadContent -PackageID $packageID -DestinationLocationType $destinationLocationType -DestinationVariableName $destinationVariableName -CustomLocationPath $customLocationPath
            Assert-MockCalled Set-TSVariable -ParameterFilter { $Name -eq "OSDDownloadDownloadPackages" -and $Value -eq $packageID } -Times 1
            Assert-MockCalled Set-TSVariable -ParameterFilter { $Name -eq "OSDDownloadDestinationLocationType" -and $Value -eq $destinationLocationType } -Times 1
            Assert-MockCalled Set-TSVariable -ParameterFilter { $Name -eq "OSDDownloadDestinationVariable" -and $Value -eq $destinationVariableName } -Times 1
        }
        It "Should call the Start-OSDDownloadContent function with the correct file path in Windows" {
            $mockPath = "C:\Windows\CCM\OSDDownloadContent.exe"
            Mock Test-Path { return $false }
            Mock Join-Path { return $mockPath }
            Mock Start-OSDDownloadContent -ParameterFilter { $FilePath -eq $mockPath } -MockWith { }
            Start-CMDownloadContent -PackageID $packageID -DestinationLocationType $destinationLocationType -DestinationVariableName $destinationVariableName -CustomLocationPath $customLocationPath
            Assert-MockCalled Start-OSDDownloadContent -ParameterFilter { $FilePath -eq "C:\Windows\CCM\OSDDownloadContent.exe" } -Times 1
        }
        It "Should call the Start-OSDDownloadContent function with the correct file path in WinPE" {
            $mockPath = "OSDDownloadContent.exe"
            Mock Test-Path { return $true }
            Mock Join-Path { return $mockPath }
            Mock Start-OSDDownloadContent -ParameterFilter { $FilePath -eq $mockPath } -MockWith { }
            Start-CMDownloadContent -PackageID $packageID -DestinationLocationType $destinationLocationType -DestinationVariableName $destinationVariableName -CustomLocationPath $customLocationPath
            Assert-MockCalled Start-OSDDownloadContent -ParameterFilter { $FilePath -eq "OSDDownloadContent.exe" } -Times 1
        }
    }
    Context "When calling the function with invalid input" {
        BeforeAll {
            $packageID = "AAA00103"
            $destinationLocationType = "Custom"
            $destinationVariableName = "TestDestinationVariableName"
            $customLocationPath = "C:\Test\Custom\Location"
            Mock Write-LogEntry {}
            Mock Start-OSDDownloadContent {}
            Mock Test-Path {throw}
            Mock Set-TSVariable {}
        }
        It "Should throw an error" {
            { Start-CMDownloadContent -PackageID $packageID -DestinationLocationType $destinationLocationType -DestinationVariableName $destinationVariableName -CustomLocationPath $customLocationPath } | Should -Throw 'An error occurred while attempting to download package content.'
        }
    }
}
}
