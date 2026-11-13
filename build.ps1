param(
    [string]$FontPath,
    [switch]$SkipBackend
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$out = Join-Path $root 'build'
$csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path -LiteralPath $csc)) {
    throw '找不到 .NET Framework 4.x 编译器。请在 64 位 Windows 上安装 .NET Framework。'
}
New-Item -ItemType Directory -Force -Path $out | Out-Null
$buildArgs = @(
    '/nologo', '/target:winexe',
    ('/out:' + (Join-Path $out 'Free Music Download.exe')),
    ('/win32icon:' + (Join-Path $root 'src\free-music.ico')),
    '/reference:System.dll', '/reference:System.Core.dll',
    '/reference:System.Drawing.dll', '/reference:System.Windows.Forms.dll',
    '/reference:System.Web.Extensions.dll',
    ('/resource:' + (Join-Path $root 'src\GuiPrompt.ps1') + ',MusicHelper.GuiPrompt.ps1')
)
if ($FontPath) {
    $resolvedFont = (Resolve-Path -LiteralPath $FontPath).Path
    $buildArgs += '/resource:' + $resolvedFont + ',MusicHelper.PingFang.ttf'
}
$buildArgs += Join-Path $root 'src\MusicHelper.cs'
& $csc @buildArgs
if ($LASTEXITCODE -ne 0) { throw '编译失败。' }

if (-not $SkipBackend) {
    $url = 'https://github.com/rwnk-12/apmyx-gui/releases/download/v1.1.1/apmyx-win-v1.1.1-setup.exe'
    $expected = '40B3A298FD3102C172813A5DA20F613615A8059DB7F1917A1D5F25D577BEE9F5'
    $installer = Join-Path $out '音乐后台组件.exe'
    if ((Test-Path -LiteralPath $installer) -and (Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash -ne $expected) {
        throw '现有后台安装包校验不匹配，请检查 build 目录。'
    }
    if (-not (Test-Path -LiteralPath $installer)) {
        $temp = Join-Path $out ('backend-' + [Guid]::NewGuid().ToString('N') + '.tmp')
        try {
            Write-Host '正在从 apmyx 官方发布页下载后台组件……'
            Invoke-WebRequest -Uri $url -OutFile $temp -UseBasicParsing
            if ((Get-FileHash -LiteralPath $temp -Algorithm SHA256).Hash -ne $expected) {
                throw '后台安装包校验失败。'
            }
            Move-Item -LiteralPath $temp -Destination $installer
        } finally {
            if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp }
        }
    }
}
Write-Host ('构建完成：' + (Join-Path $out 'Free Music Download.exe'))
