
# 从环境变量读取 SMTP 配置
$SMTPServer = $env:SMTP_SERVER
$SMTPPort = $env:SMTP_PORT
$SMTPUser = $env:SMTP_USER
$SMTPPassword = $env:SMTP_PASSWORD
$ToEmail = $env:SMTP_USER


# 获取当前公网 IPv6 地址（非 fe80::）
function Get-PublicIPv6 {
    $IPv6 = (Get-NetIPAddress -AddressFamily IPv6 | 
        Where-Object { $_.PrefixOrigin -eq 'Dhcp' -and $_.IPAddress -notlike 'fe80::*' }).IPAddress
    return $IPv6
}

# 发送邮件函数
function Send-IPv6Email {
    param (
        [string]$Subject,
        [string]$Body
    )
    $SecurePassword = ConvertTo-SecureString $SMTPPassword -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($SMTPUser, $SecurePassword)
    
    Send-MailMessage -From $SMTPUser -To $ToEmail -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -Credential $Credential -UseSsl
}

# 主逻辑
$CurrentIPv6 = Get-PublicIPv6
$IPv6LogFile = "C:\Logs\IPv6_History.txt"

# 如果日志文件不存在，则创建并发送初始 IPv6
if (-not (Test-Path $IPv6LogFile)) {
    $CurrentIPv6 | Out-File -FilePath $IPv6LogFile -Force
    if ($CurrentIPv6) {
        Send-IPv6Email -Subject "[IPv6] IPv6 address detected on startup" -Body $CurrentIPv6
    }
    exit
}

# 读取上次记录的 IPv6
$LastIPv6 = Get-Content $IPv6LogFile

# 如果 IPv6 发生变化，发送邮件并更新日志
if ($CurrentIPv6 -and ($CurrentIPv6 -ne $LastIPv6)) {
    Send-IPv6Email -Subject "[IPv6] IPv6 address changed" -Body $CurrentIPv6
    $CurrentIPv6 | Out-File -FilePath $IPv6LogFile -Force
}