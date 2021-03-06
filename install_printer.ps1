<#
    安装无线打印机驱动;
    在“win7旗舰版X86_64位”上测试通过
#>

$nasIP = '192.168.8.8'
$runUserName = $env:username
$driveNum = 'B'
$tmpDir = "C:\Users\$runUserName\Desktop\temp"
$fileName = 'LJM178-M181_UWWL_4_1_Full_WebPack_44.3.2218.exe'
# 随机获取1个系统空闲的网络驱动器号
$usableDriveName = ls function:[A-Z]: | where { ! (test-path $_.name) }| select -ExpandProperty name | Get-Random
<#
$usableDriveName = Get-PSDrive -PSProvider FileSystem | select -ExpandProperty Name
65..90 | Where-Object{
$usableDriveName -notcontains [char]$_
}| ForEach-Object {
[char]$_
} | Get-Random
#>

<#
$usableDriveExist = test-path $usableDriveName:\
$tmpDirExist = test-path $tmpDir
$tmpDirFileExist = test-path $tmpDir\$fileName
#>

# Check network (to NAS IP)
set-executionpolicy remotesigned
$ping = get-wmiobject -Query "select * from win32_pingstatus where Address='$nasIP'"
if ($ping.statuscode -eq 0) {
    "Computer responded in: {0}ms" -f $ping.responsetime
}
else {
    "$nasIP not respond, Check your network or this runing ?"
    exit 2
}

<#
# Check Net Drive exist
if ($usableDriveExist -eq 'true') {
    "网络共享盘已存在！do nothing"
}
else {
    net use $usableDriveName \\$nasIP\app\打印机驱动
}
#>

# 复制文件到本地电脑桌面的temp目录中
net use $usableDriveName \\$nasIP\app\打印机驱动
New-Item -Path $tmpDir -ItemType Directory
copy-Item -Path $usableDriveName\$fileName $tmpDir


# Stating install 

#LJM178-M181_UWWL_4_1_Full_WebPack_44.3.2218.exe /sAll /msi /norestart ALUSERS=1 EULA_ACCEPT=YES

<#
Write-Host "Installing software on $box"
([WMICLASS]"\\$box\ROOT\CIMV2:win32_process").Create(
"cmd.exe /c d:\temp\LJM178-M181_UWWL_4_1_Full_WebPack_44.3.2218.exe /s /v`” /qn")
#>

<#
Get-WmiObject -Class Win32_PingStatus -Filter "Address='192.168.9.2'" -ComputerName .
echo $?
#>

<# 回收清理
# 断开网络驱动器连接
#>
dir | Out-File $tmpDir 
# 送入回收站
$shell = new-object -comobject "Shell.Application"
$item = $shell.Namespace(0).ParseName( (Resolve-Path $tmpDir).Path)
$item.InvokeVerb("delete") 
net use $usableDriveName /del /y

"1). 请双击运行‘桌面-temp目录’中的*.exe安装程序"
"2). 安装完成后，双击运行桌面的‘HP ColorLaserJet MFP M178-M181’快捷方式，根据安装向导，依次选‘下一步’，完成安装
     注意：打印机IP地址填：172.16.8.9"
"3). Enter any key to exit." ;
[Console]::Readkey() | Out-Null ;
Exit ;
