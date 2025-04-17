# 儲存成 UTF-8 with BOM，避免中文亂碼

param (
	[string]$VhdPath
)

# === 基本設定 ===
$defaultVhdPath = "D:\ws\Virtual_Disks\WorkSpace.vhdx"
$UserName   = "andrew"
$mPointName = "build-ssd"
$fsType	 = "ext4"

# === 依輸入或預設 ===
if (-not $VhdPath) {
	$VhdPath = $defaultVhdPath
}

# === 發行版選單 ===
Write-Host ""
Write-Host "請選擇要啟動的 WSL 發行版："
Write-Host "[1] Ubuntu-22.04"
Write-Host "[2] Mint-21.3"
#Write-Host "[3] Ubuntu-18.04"
$selection = Read-Host "請輸入選項編號 (預設 1)"

switch ($selection) {
    "2" { $distroName = "Mint" }
    default { $distroName = "Ubuntu-22.04" }
}

# === 共用函數 ===

function Exit-WithError($message) {
    Write-Error $message
    exit 1
}

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Check-DistroExists {
    param ([string]$DistroName)
    $existingDistros = wsl.exe --list --quiet | ForEach-Object { $_.Trim() }
    return $existingDistros -contains $DistroName
}

function Safe-Unmount {
    param ([string]$VhdPath)

    try {
        wsl --unmount \\?\$VhdPath 2>$null 3>$null
        Dismount-VHD -Path $VhdPath -ErrorAction SilentlyContinue | Out-Null
    } catch {
        # 安靜忽略任何錯誤
    }
}

function Stop-Wsl {
    try {
        wsl -d $distroName --shutdown 2>$null
    } catch {
        # 有時候可能本來就沒啟動，忽略錯誤
    }
}

function Start-Wsl {
    param ([string]$VhdPath)

    if (-not (Test-Path -Path $VhdPath)) {
        Exit-WithError "找不到 VHD 檔案：$VhdPath"
		}

    try {
        wsl --unmount \\?\$VhdPath 2>$null
		wsl -d $distroName --user $UserName --mount --vhd $VhdPath --name $mPointName --type $fsType
        Write-Host "✅ WSL 發行版 '$distroName' 已啟動並成功掛載 VHD！"
	} catch {
        Exit-WithError "掛載 VHD 失敗: $_"
	}
}

function Wsl-Attach {
	wsl -d $distroName
}

function Main {
    param ([string]$VhdPath)

	if (-not (Test-Admin)) {
        Exit-WithError "請以系統管理員權限執行此腳本！"
	}

	if (-not (Test-Path -Path $defaultVhdPath)) {
        Exit-WithError "找不到預設 VHD 檔案：$defaultVhdPath"
	}

	if (-not (Check-DistroExists -DistroName $distroName)) {
        Exit-WithError "找不到指定的 WSL 發行版 '$distroName'，請確認是否已正確安裝！"
	}

    Write-Host ""
    Write-Host "🔄 正在清理舊的掛載狀態..."
	Write-Host ""
    Safe-Unmount -VhdPath $VhdPath
		Stop-Wsl

	Write-Host ""
    Write-Host "🚀 正在啟動 WSL..."
	Write-Host ""
		Start-Wsl -VhdPath $VhdPath

	Write-Host ""
    Write-Host "🔗 連線到 WSL..."
	Write-Host ""
		Wsl-Attach
}

# === 執行主程式 ===
Main -VhdPath $VhdPath