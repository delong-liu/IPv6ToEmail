$SMTPServer = $env:SMTP_SERVER
$SMTPPort = $env:SMTP_PORT
$SMTPUser = $env:SMTP_USER
$SMTPPassword = $env:SMTP_PASSWORD
$ToEmail = $env:SMTP_USER

$IPv6LogFile = "C:\Logs\IPv6_History.txt"

# change here according to your situation
function Get-PublicIPv6 {
    $IPv6 = (Get-NetIPAddress -AddressFamily IPv6 | Where-Object { $_.SuffixOrigin -eq "Random" }).IPAddress
    return $IPv6
}

function Send-IPv6Email {
    param (
        [string]$Subject,
        [string]$Body
    )
    $SecurePassword = ConvertTo-SecureString $SMTPPassword -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($SMTPUser, $SecurePassword)
    
    Send-MailMessage -From $SMTPUser -To $ToEmail -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -Credential $Credential -UseSsl
}

$CurrentIPv6 = Get-PublicIPv6


if (Test-Path $IPv6LogFile){
    $LastIPv6 = Get-Content $IPv6LogFile
} else {
    $LastIPv6 = ""
}

if ($CurrentIPv6 -and ($CurrentIPv6 -ne $LastIPv6)) {
    Send-IPv6Email -Subject "[IPv6] IPv6 address changed" -Body $CurrentIPv6
    $CurrentIPv6 | Out-File -FilePath $IPv6LogFile -Force
}