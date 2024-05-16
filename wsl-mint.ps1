param (
	[string]$VhdPath
)

$defaultVhdPath = "C:\MyApps\Virtual_Disks\WorkSpace.vhdx"
if (-not $VhdPath) {
	$VhdPath = $defaultVhdPath
}

$distroName = "Mint"
$mPointName = "projects"
$fsType	 = "ext4"

function Test-Admin {
	$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
 	$currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Umount-All {
	param (
		[string]$VhdPath
	)

	try {
		wsl --unmount \\?\$VhdPath 2>&1 | Out-Null
		Dismount-VHD -Path $VhdPath 2>&1 | Out-Null
	} catch {
		Write-Error "Failed to unmount VHD: $_"
		exit 1
	}
}

function Stop-Wsl {
	wsl -d $distroName --shutdown
}

function Start-Wsl {
	param (
		[string]$VhdPath
	)

	try {
		if (-Not (Test-Path -Path $VhdPath)) {
			throw "VHD file at path '$VhdPath' does not exist."
		}

		wsl -d $distroName --mount --vhd $VhdPath --name $mPointName --type $fsType
		Write-Host "WSL with Linux Mint started and VHD mounted successfully."
	} catch {
		Write-Error "Failed to mount VHD: $_"
		exit 1
	}
}

function Wsl-Attach {
	wsl -d $distroName
}

function Main {
	param (
		[string]$VhdPath
	)

	if (-not (Test-Admin)) {
		Write-Error "This script requires administrative privileges!"
		exit 1
	}

	try {
		Umount-All -VhdPath $VhdPath
		Stop-Wsl
		Start-Wsl -VhdPath $VhdPath
		Wsl-Attach
	} catch {
		Write-Error "An error occurred: $_"
		exit 1
	}
}

Main -VhdPath $VhdPath
