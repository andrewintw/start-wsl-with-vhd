# 儲存成 UTF-8 with BOM，避免中文亂碼

# 設定要關閉的發行版清單
$distroList = @("Ubuntu-22.04", "Mint")  # 在這裡填入你的發行版名稱

function Shutdown-SpecificDistros {
    param (
        [array]$Distros
    )

    foreach ($distro in $Distros) {
        Write-Host "🚀正在關閉 WSL 發行版: $distro"
        try {
            # 使用 --distro 參數來確保關閉指定的發行版
            wsl -d $distro --shutdown
            Write-Host "✅$distro 發行版已成功關閉。"
        } catch {
            Write-Error "❌無法關閉 WSL 發行版 '$distro'，錯誤: $_"
        }
    }
}

# 呼叫關閉發行版函數
Shutdown-SpecificDistros -Distros $distroList

# 檢查 VHD 檔案是否存在，並進行卸載
$VhdPath = "D:\ws\Virtual_Disks\WorkSpace.vhdx"
if (Test-Path -Path $VhdPath) {
    Write-Host "🚀正在卸載 VHD: $VhdPath"
    wsl --unmount \\?\$VhdPath
    Write-Host "✅VHD 卸載成功。"
} else {
    Write-Host "❌VHD 檔案不存在，無法卸載。"
}
