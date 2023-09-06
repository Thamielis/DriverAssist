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

Describe Get-AdminServicePackage -Tag 'Unit' {
InModuleScope $ProjectName {
    Context "When calling the function with a valid filter" {
        BeforeAll {
            Mock Get-TSValue { return "test.fqdn" }
            Mock Get-AuthCredential { return [PSCredential]::Empty }
            Mock Write-LogEntry { }
            Mock Invoke-RestMethod { return @{
                value = @(
                    @{
                        Name = "ConfigMgr Client Package"
                        PackageID = "Package1ID"
                        Version = "1.0.0"
                    },
                    @{
                        Name = "=ConfigMgr Client Package2"
                        PackageID = "Package2ID"
                        Version = "2.0.0"
                    }
                )
            } }
        }
        It "Should call the AdminService endpoint with the expected URI" {
            Get-AdminServicePackage -Model "TestFilter"
            Should -Invoke Invoke-RestMethod -Times 1
        }
        It "Should return a non-empty array list of package objects" {
            $packages = Get-AdminServicePackage -Model "TestFilter"
            $packages[0].Name | Should -Be 'ConfigMgr Client Package'
            $packages.GetType().Name | Should -Be "Object[]"
        }
        It "Should return package objects with the expected properties" {
            $packages = Get-AdminServicePackage -Model "TestFilter"
            $packages[0].Name | Should -Be 'ConfigMgr Client Package'
            $packages[0].PackageID | Should -Be 'Package1ID'
            $packages[0].Version | Should -Be '1.0.0'
            $packages[1].Name | Should -Be '=ConfigMgr Client Package2'
            $packages[1].PackageID | Should -Be 'Package2ID'
            $packages[1].Version | Should -Be '2.0.0'
        }
    }
    Context "When calling the function with an invalid filter" {
        BeforeAll {
            # Mock Get-TSValue and Get-AuthCredential functions
            Mock Get-TSValue { return "test.fqdn" }
            Mock Get-AuthCredential { return [PSCredential]::Empty }
            Mock Write-LogEntry {}
            Mock Invoke-RestMethod { throw "Invalid filter" }
        }
        It "Should throw an error" {
            { Get-AdminServicePackage -Model "InvalidFilter" } | Should -Throw
        }
    }
}
}
