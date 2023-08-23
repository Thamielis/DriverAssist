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
        [parameter(Mandatory = $true, HelpMessage = "Specify the full local path to the downloaded driver package content.")]
        [ValidateNotNullOrEmpty()]
        [string]$ContentLocation
    )
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    }
    process {
        # Detect if downloaded driver package content is a compressed archive that needs to be extracted before drivers are installed
		$DriverPackageCompressedFile = Get-ChildItem -Path $ContentLocation -Filter "DriverPackage.*"
		if ($null -ne $DriverPackageCompressedFile) {
			Write-LogEntry -Value "[i] Downloaded driver package content contains a compressed archive with driver content" -Severity 1 -Source ${CmdletName}
			# Detect if compressed format is Windows native zip or 7-Zip exe
			switch -wildcard ($DriverPackageCompressedFile.Name) {
				"*.zip" {
					try {
						# Expand compressed driver package archive file
						Write-LogEntry -Value "[i] Attempting to decompress driver package content file: $($DriverPackageCompressedFile.Name)" -Severity 1 -Source ${CmdletName}
						Write-LogEntry -Value "[i] Decompression destination: $($ContentLocation)" -Severity 1 -Source ${CmdletName}
						Expand-Archive -Path $DriverPackageCompressedFile.FullName -DestinationPath $ContentLocation -Force -ErrorAction Stop
						Write-LogEntry -Value "[+] Successfully decompressed driver package content file" -Severity 1 -Source ${CmdletName}
					}
					catch [System.Exception] {
						Write-LogEntry -Value "[!] Failed to decompress driver package content file. Error message: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
					try {
						# Remove compressed driver package archive file
						if (Test-Path -Path $DriverPackageCompressedFile.FullName) {
							Remove-Item -Path $DriverPackageCompressedFile.FullName -Force -ErrorAction Stop
						}
					}
					catch [System.Exception] {
						Write-LogEntry -Value "[!] Failed to remove compressed driver package content file after decompression. Error message: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
				}
				"*.exe" {
					Write-LogEntry -Value "[i] Attempting to decompress 7-Zip driver package content file: $($DriverPackageCompressedFile.Name)" -Severity 1 -Source ${CmdletName}
					Write-LogEntry -Value "[i] Decompression destination: $($ContentLocation)" -Severity 1 -Source ${CmdletName}
					$ReturnCode = Start-Executable -FilePath $DriverPackageCompressedFile.FullName -Arguments "-o`"$($ContentLocation)`" -y"
					# Validate 7-Zip driver extraction
					if ($ReturnCode -eq 0) {
						Write-LogEntry -Value "[+] Successfully decompressed 7-Zip driver package content file" -Severity 1 -Source ${CmdletName}
					}
					else {
						Write-LogEntry -Value "[!] An error occurred while decompressing 7-Zip driver package content file. Return code from self-extracing executable: $($ReturnCode)" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
				}
				"*.wim" {
					try {
						# Create mount location for driver package WIM file
						$DriverPackageMountLocation = Join-Path -Path $ContentLocation -ChildPath "Mount"
						if (-not (Test-Path -Path $DriverPackageMountLocation)) {
							Write-LogEntry -Value "[i] Creating mount location directory: $($DriverPackageMountLocation)" -Severity 1 -Source ${CmdletName}
							New-Item -Path $DriverPackageMountLocation -ItemType "Directory" -Force | Out-Null
						}
					}
					catch [System.Exception] {
						Write-LogEntry -Value "[!] Failed to create mount location for WIM file. Error message: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
					try {
						# Expand compressed driver package WIM file
						Write-LogEntry -Value "[i] Attempting to mount driver package content WIM file: $($DriverPackageCompressedFile.Name)" -Severity 1 -Source ${CmdletName}
						Write-LogEntry -Value "[i] Mount location: $($DriverPackageMountLocation)" -Severity 1 -Source ${CmdletName}
						Mount-WindowsImage -ImagePath $DriverPackageCompressedFile.FullName -Path $DriverPackageMountLocation -Index 1 -ErrorAction Stop
						Write-LogEntry -Value "[+] Successfully mounted driver package content WIM file" -Severity 1 -Source ${CmdletName}
						Write-LogEntry -Value "[+] Copying items from mount directory" -Severity 1 -Source ${CmdletName}
						Get-ChildItem -Path $DriverPackageMountLocation | Copy-Item -destination $ContentLocation -Recurse -container
					}
					catch [System.Exception] {
						Write-LogEntry -Value "[!] Failed to mount driver package content WIM file. Error message: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
				}
			}
		}
		switch ($Script:DeploymentMode) {
			"BareMetal" {
				# Apply drivers recursively from downloaded driver package location
				Write-LogEntry -Value "[i] Attempting to apply drivers using dism.exe located in: $($ContentLocation)" -Severity 1 -Source ${CmdletName}
				# Determine driver injection method from parameter input
				switch ($DriverInstallMode) {
					"Single" {
						try {
							Write-LogEntry -Value "[i] DriverInstallMode is currently set to: $($DriverInstallMode)" -Severity 1 -Source ${CmdletName}
							# Get driver full path and install each driver seperately
							$DriverINFs = Get-ChildItem -Path $ContentLocation -Recurse -Filter "*.inf" -ErrorAction Stop | Select-Object -Property FullName, Name
							if ($null -ne $DriverINFs) {
								foreach ($DriverINF in $DriverINFs) {
									# Install specific driver
									Write-LogEntry -Value "[i] Attempting to install driver: $($DriverINF.FullName)" -Severity 1 -Source ${CmdletName}
									$ApplyDriverInvocation = Start-Executable -FilePath "dism.exe" -Arguments "/Image:$($TSEnvironment.Value('OSDTargetSystemDrive'))\ /Add-Driver /Driver:`"$($DriverINF.FullName)`""
									# Validate driver injection
									if ($ApplyDriverInvocation -eq 0) {
										Write-LogEntry -Value "[+] Successfully installed driver using dism.exe" -Severity 1 -Source ${CmdletName}
									}
									else {
										Write-LogEntry -Value "[!] An error occurred while installing driver. Continuing with warning code: $($ApplyDriverInvocation). See DISM.log for more details" -Severity 2 -Source ${CmdletName}
									}
								}
							}
							else {
								Write-LogEntry -Value "[!] An error occurred while enumerating driver paths, downloaded driver package does not contain any INF files" -Severity 3 -Source ${CmdletName}
								$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
							}
						}
						catch [System.Exception] {
							Write-LogEntry -Value "[!] An error occurred while installing drivers. See DISM.log for more details" -Severity 2 -Source ${CmdletName}
							$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
						}
					}
					"Recurse" {
						Write-LogEntry -Value "[i] DriverInstallMode is currently set to: $($DriverInstallMode)" -Severity 1 -Source ${CmdletName}
						# Apply drivers recursively
						$ApplyDriverInvocation = Start-Executable -FilePath "dism.exe" -Arguments "/Image:$($TSEnvironment.Value('OSDTargetSystemDrive'))\ /Add-Driver /Driver:$($ContentLocation) /Recurse"
						# Validate driver injection
						if ($ApplyDriverInvocation -eq 0) {
							Write-LogEntry -Value "[+] Successfully installed drivers recursively in driver package content location using dism.exe" -Severity 1 -Source ${CmdletName}
						}
						else {
							Write-LogEntry -Value "[!] An error occurred while installing drivers. Continuing with warning code: $($ApplyDriverInvocation). See DISM.log for more details" -Severity 2 -Source ${CmdletName}
						}
					}
				}
			}
			"OSUpgrade" {
				# For OSUpgrade, don't attempt to install drivers as this is handled by setup.exe when used together with OSDUpgradeStagedContent
				Write-LogEntry -Value "[+] Driver package content downloaded successfully and located in: $($ContentLocation)" -Severity 1 -Source ${CmdletName}
				# Set OSDUpgradeStagedContent task sequence variable
				Write-LogEntry -Value "[i] Attempting to set OSDUpgradeStagedContent task sequence variable with value: $($ContentLocation)" -Severity 1
				Set-TSVariable -Name "OSDUpgradeStagedContent" -Value "$($ContentLocation)"
				Write-LogEntry -Value "[+] Successfully completed driver package staging process" -Severity 1 -Source ${CmdletName}
			}
			"DriverUpdate" {
				# Apply drivers recursively from downloaded driver package location
				Write-LogEntry -Value "[+] Driver package content downloaded successfully, attempting to apply drivers using pnputil.exe located in: $($ContentLocation)" -Severity 1 -Source ${CmdletName}
				$ApplyDriverInvocation = Start-Executable -FilePath "powershell.exe" -Arguments "pnputil /add-driver $(Join-Path -Path $ContentLocation -ChildPath '*.inf') /subdirs /install | Out-File -FilePath (Join-Path -Path $($LogsDirectory) -ChildPath 'Install-Drivers.txt') -Force"
				Write-LogEntry -Value "[+] Successfully installed drivers" -Severity 1 -Source ${CmdletName} -Source
			}
			"PreCache" {
				# Driver package content downloaded successfully, log output and exit script
				Write-LogEntry -Value "[+] Driver package content successfully downloaded and pre-cached to: $($ContentLocation)" -Severity 1 -Source ${CmdletName}
			}
		}
		# Cleanup potential compressed driver package content
		if ($null -ne $DriverPackageCompressedFile) {
			switch -wildcard ($DriverPackageCompressedFile.Name) {
				"*.wim" {
					try {
						# Attempt to dismount compressed driver package content WIM file
						Write-LogEntry -Value "[i] Attempting to dismount driver package content WIM file: $($DriverPackageCompressedFile.Name)" -Severity 1 -Source ${CmdletName}
						Write-LogEntry -Value "[i] Mount location: $($DriverPackageMountLocation)" -Severity 1 -Source ${CmdletName} -Source ${CmdletName}
						Dismount-WindowsImage -Path $DriverPackageMountLocation -Discard -ErrorAction Stop
						Write-LogEntry -Value "[+] Successfully dismounted driver package content WIM file" -Severity 1 -Source ${CmdletName} -Source ${CmdletName}
					}
					catch [System.Exception] {
						Write-LogEntry -Value "[!] Failed to dismount driver package content WIM file. Error message: $($_.Exception.Message)" -Severity 3 -Source ${CmdletName}
						$PSCmdlet.ThrowTerminatingError((New-TerminatingErrorRecord))
					}
				}
			}
		}
    }
    end {
    }
}
#endregion Function Install-DriverPackageContent
