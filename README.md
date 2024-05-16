# start-wsl-with-vhd

Usage:

```
PS C:\MyApps> .\wsl-mint.ps1 .\Virtual_Disks\WorkSpace.vhdx
磁碟已成功裝載為 '/mnt/wsl/projects'。
注意: 如果您在 /etc/wsl.conf 中修改 automount.root 設定，位置會有所不同。
若要卸載並中斷連結磁碟，請執行 'wsl.exe --unmount \\?\C:\MyApps\Virtual_Disks\WorkSpace.vhdx'。
WSL with Linux Mint started and VHD mounted successfully.
```

OR:

```
PS C:\MyApps> .\wsl-mint.ps1
磁碟已成功裝載為 '/mnt/wsl/projects'。
注意: 如果您在 /etc/wsl.conf 中修改 automount.root 設定，位置會有所不同。
若要卸載並中斷連結磁碟，請執行 'wsl.exe --unmount \\?\C:\MyApps\Virtual_Disks\WorkSpace.vhdx'。
WSL with Linux Mint started and VHD mounted successfully.
```
