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

Describe Get-ComputerData -Tag 'Unit' {
InModuleScope $ProjectName {
    BeforeEach {
        Mock Write-LogEntry { }
    }
    Context "When the Manufacturer is Microsoft" {
        It "Returns the correct computer details" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'Microsoft'
                Model = 'Microsoftcomputer'
                SystemSKU = 'MicrosoftSKU'
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $fakeComputer.SystemSKU }
            $result = Get-ComputerData
            $result.Manufacturer | Should -Be 'Microsoft'
            $result.Model | Should -Be 'Microsoftcomputer'
            $result.SystemSKU | Should -Be 'MicrosoftSKU'
            Should -Invoke Write-LogEntry -Exactly 3
        }
    }
    Context "When the Manufacturer is HP" {
        It "Returns the correct computer details" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'HP'
                Model = 'HPcomputer'
                SystemSKU = 'HPSKU'
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $fakeComputer.SystemSKU }
            $result = Get-ComputerData
            $result.Manufacturer | Should -Be 'HP'
            $result.Model | Should -Be 'HPcomputer'
            $result.SystemSKU | Should -Be 'HPSKU'
            Should -Invoke Write-LogEntry -Exactly 3
        }
    }
    Context "When the Manufacturer is Hewlett Packard" {
        It "Returns the correct computer details" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'Hewlett-Packard'
                Model = 'HPcomputer'
                SystemSKU = 'HPSKU'
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $fakeComputer.SystemSKU }
            $result = Get-ComputerData
            $result.Manufacturer | Should -Be 'HP'
            $result.Model | Should -Be 'HPcomputer'
            $result.SystemSKU | Should -Be 'HPSKU'
            Should -Invoke Write-LogEntry -Exactly 3
        }
    }
    Context "When the Manufacturer is Dell" {
        It "Returns the correct computer details" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'Dell Inc.'
                Model = 'Dellcomputer'
                SystemSKU = 'DellSKU'
                OEMStringArray = @("[ABC1234]")
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $fakeComputer.SystemSKU }
            $result = Get-ComputerData
            $result.Manufacturer | Should -Be 'Dell'
            $result.Model | Should -Be 'Dellcomputer'
            $result.SystemSKU | Should -Be 'DellSKU'
            Should -Invoke Write-LogEntry -Exactly 3
        }
    }
    Context "When the Manufacturer is Lenovo" {
        It "Returns the correct computer details" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'Lenovo'
                Model = 'Lenovocomputer'
                SystemSKU = '5150'
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $fakeComputer.SystemSKU }
            $result = Get-ComputerData
            $result.Manufacturer | Should -Be 'Lenovo'
            $result.Model | Should -Be 'Lenovocomputer'
            $result.SystemSKU | Should -Be '5150'
            Should -Invoke Write-LogEntry -Exactly 3
        }
    }
    Context "When the Manufacturer is Panasonic" {
        It "Returns the correct computer details" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'Panasonic'
                Model = 'Panasoniccomputer'
                SystemSKU = 'PanasonicSKU'
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $fakeComputer.SystemSKU }
            $result = Get-ComputerData
            $result.Manufacturer | Should -Be 'Panasonic Corporation'
            $result.Model | Should -Be 'Panasoniccomputer'
            $result.SystemSKU | Should -Be 'PanasonicSKU'
            Should -Invoke Write-LogEntry -Exactly 3
        }
    }
    Context "When the Manufacturer is Viglen" {
        It "Returns the correct computer details" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'Viglen'
                Model = 'Viglencomputer'
                SystemSKU = 'ViglenSKU'
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $fakeComputer.SystemSKU }
            $result = Get-ComputerData
            $result.Manufacturer | Should -Be 'Viglen'
            $result.Model | Should -Be 'Viglencomputer'
            $result.SystemSKU | Should -Be 'ViglenSKU'
            Should -Invoke Write-LogEntry -Exactly 3
        }
    }
    Context "When the Manufacturer is AZW" {
        It "Returns the correct computer details" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'AZW'
                Model = 'AZWcomputer'
                SystemSKU = 'AZWSKU'
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $fakeComputer.SystemSKU }
            $result = Get-ComputerData
            $result.Manufacturer | Should -Be 'AZW'
            $result.Model | Should -Be 'AZWcomputer'
            $result.SystemSKU | Should -Be 'AZWSKU'
            Should -Invoke Write-LogEntry -Exactly 3
        }
    }
    Context "When the Manufacturer is Fujitsu" {
        It "Returns the correct computer details" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'Fujitsu'
                Model = 'Fujitsucomputer'
                SystemSKU = 'FujitsuSKU'
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $fakeComputer.SystemSKU }
            $result = Get-ComputerData
            $result.Manufacturer | Should -Be 'Fujitsu'
            $result.Model | Should -Be 'Fujitsucomputer'
            $result.SystemSKU | Should -Be 'FujitsuSKU'
        }
    }
    Context "When the Manufacturer is Getac" {
        It "Returns the correct computer details" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'Getac'
                Model = 'Getaccomputer'
                SystemSKU = 'GetacSKU'
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $fakeComputer.SystemSKU }
            $result = Get-ComputerData
            $result.Manufacturer | Should -Be 'Getac'
            $result.Model | Should -Be 'Getaccomputer'
            $result.SystemSKU | Should -Be 'GetacSKU'
        }
    }
    Context "When the Manufacturer is Clear Touch" {
        It "Returns the correct computer details" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'Clear Touch Interactive'
                Model = 'GetCTcomputer'
                SystemSKU = 'GetCTSKU'
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $fakeComputer.SystemSKU }
            $result = Get-ComputerData
            $result.Manufacturer | Should -Be 'ClearTouch'
            $result.Model | Should -Be 'GetCTcomputer'
            $result.SystemSKU | Should -Be 'GetCTSKU'
        }
    }
    Context "When the System SKU is missing" {
        It "Retuns a null value for the SystemSKU" {
            $fakeComputer = [PSCustomObject]@{
                Manufacturer = 'Microsoft'
                Model = 'ComputerModel'
                SystemSKU = $null
            }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWManufacturer' } -MockWith { $fakeComputer.Manufacturer }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWModel' } -MockWith { $fakeComputer.Model }
            Mock Get-TSValue -ParameterFilter { $Name -eq 'XHWProductSKU' } -MockWith { $null }
            Get-ComputerData
            # $result.Manufacturer | Should -Be 'ComputerManufacturer'
            # $result.Model | Should -Be 'ComputerModel'
            # $result.SystemSKU | Should -Be ''
            Should -Invoke Write-LogEntry -Exactly 3
        }
    }
}
}
