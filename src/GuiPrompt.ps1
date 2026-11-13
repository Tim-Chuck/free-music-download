Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
if (-not ('MusicHelperPrivateFont' -as [type])) {
    Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class MusicHelperPrivateFont {
    [DllImport("gdi32.dll", CharSet=CharSet.Unicode)]
    public static extern int AddFontResourceEx(string path, uint flags, IntPtr reserved);
}
'@
}
$script:GuiFontPath = Join-Path $PSScriptRoot 'MusicHelper.PingFang.ttf'
$script:GuiFontCollection = New-Object System.Drawing.Text.PrivateFontCollection
if (Test-Path -LiteralPath $script:GuiFontPath) {
    $script:GuiFontCollection.AddFontFile($script:GuiFontPath)
    if ([MusicHelperPrivateFont]::AddFontResourceEx($script:GuiFontPath, 0x10, [IntPtr]::Zero) -eq 0 -or $script:GuiFontCollection.Families.Count -eq 0) { throw '无法加载登录界面字体。' }
    $script:GuiFontFamily = $script:GuiFontCollection.Families[0]
} else {
    $script:GuiFontFamily = [System.Drawing.SystemFonts]::MessageBoxFont.FontFamily
}

function Read-Host {
    param([string]$Prompt, [switch]$AsSecureString)
    $title = switch ($Prompt) {
        'Apple ID email' { '输入 Apple 账户' }
        'Apple ID password' { '输入 Apple 账户密码' }
        'Apple verification code' { '输入六位验证码' }
        default { throw '不支持的登录提示。' }
    }
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $title
    $form.StartPosition = 'CenterScreen'
    $form.FormBorderStyle = 'None'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.ClientSize = New-Object System.Drawing.Size(480, 265)
    $form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 255)
    $form.ForeColor = [System.Drawing.Color]::FromArgb(31, 31, 31)
    $form.ShowInTaskbar = $false
    $form.Font = [System.Drawing.Font]::new($script:GuiFontFamily, 10, [System.Drawing.FontStyle]::Regular)
    $heading = New-Object System.Windows.Forms.Label
    $heading.Text = $title
    $heading.Font = [System.Drawing.Font]::new($script:GuiFontFamily, 15, [System.Drawing.FontStyle]::Regular)
    $heading.Location = New-Object System.Drawing.Point(28, 26)
    $heading.Size = New-Object System.Drawing.Size(385, 34)
    $close = New-Object System.Windows.Forms.Button
    $close.Text = '×'; $close.AccessibleName = '关闭登录窗口'
    $close.Location = New-Object System.Drawing.Point(428, 14)
    $close.Size = New-Object System.Drawing.Size(36, 34)
    $close.FlatStyle = 'Flat'; $close.FlatAppearance.BorderSize = 0
    $close.BackColor = $form.BackColor; $close.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(30, 70)
    $label.Size = New-Object System.Drawing.Size(420, 48)
    $label.ForeColor = [System.Drawing.Color]::FromArgb(88, 96, 108)
    $label.Text = if ($AsSecureString) { '凭据将交给第三方 Wrapper Lite 后台进行登录。密码不会由 Free Music Download 保存。' } elseif ($Prompt -eq 'Apple verification code') { '请在你的受信任设备上查看验证码。' } else { '此登录由第三方 Wrapper Lite 后台处理。请输入你的 Apple 账户。' }
    $field = New-Object System.Windows.Forms.TextBox
    $field.Location = New-Object System.Drawing.Point(30, 130)
    $field.Size = New-Object System.Drawing.Size(420, 30)
    $field.BorderStyle = 'FixedSingle'
    $field.UseSystemPasswordChar = $AsSecureString.IsPresent
    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = '继续'; $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $ok.Location = New-Object System.Drawing.Point(350, 195)
    $ok.Size = New-Object System.Drawing.Size(100, 42)
    $ok.FlatStyle = 'Flat'; $ok.FlatAppearance.BorderSize = 0
    $ok.BackColor = [System.Drawing.Color]::FromArgb(26, 90, 186); $ok.ForeColor = [System.Drawing.Color]::White
    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = '取消'; $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $cancel.Location = New-Object System.Drawing.Point(240, 195)
    $cancel.Size = New-Object System.Drawing.Size(100, 42)
    $cancel.FlatStyle = 'Flat'; $cancel.FlatAppearance.BorderSize = 0
    $cancel.BackColor = [System.Drawing.Color]::FromArgb(220, 231, 250); $cancel.ForeColor = [System.Drawing.Color]::FromArgb(35, 73, 135)
    foreach ($button in @($ok, $cancel)) {
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $path.AddArc(0, 0, 38, 38, 180, 90); $path.AddArc(61, 0, 38, 38, 270, 90)
        $path.AddArc(61, 3, 38, 38, 0, 90); $path.AddArc(0, 3, 38, 38, 90, 90); $path.CloseFigure()
        $button.Region = New-Object System.Drawing.Region($path); $path.Dispose()
    }
    $form.Controls.AddRange(@($heading, $close, $label, $field, $ok, $cancel))
    $form.AcceptButton = $ok; $form.CancelButton = $cancel
    try {
        if ($form.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { throw '已取消登录。' }
        if ($AsSecureString) { return (ConvertTo-SecureString -String $field.Text -AsPlainText -Force) }
        return $field.Text
    } finally { $field.Clear(); $form.Dispose() }
}
