@echo off
rem ============================================================
rem  Nyang Todo - shortcut installer (Windows)
rem  This file only creates shortcuts on the Desktop and in the
rem  Start menu that open index.html as an Edge/Chrome app window.
rem  It does not download anything, change system settings, or
rem  send any data. You can read everything it does below.
rem ============================================================
chcp 65001 >nul
set "NYANG_DIR=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText('%~f0',[Text.Encoding]::UTF8); iex (($s -split '#==PS==#',3)[2])"
echo.
pause
exit /b

#==PS==#
$dir  = $env:NYANG_DIR.TrimEnd('\')
$html = Join-Path $dir 'index.html'
$icon = Join-Path $dir 'cat.ico'

Write-Host ''
Write-Host '  냥이 투두 바로가기 만들기'
Write-Host '  -----------------------------'

if (-not (Test-Path $html)) {
  Write-Host '  [오류] 이 파일과 같은 폴더에 index.html이 없습니다.'
  Write-Host '         ZIP 압축을 푼 폴더 안에서 실행해 주세요.'
  return
}
if ($env:TEMP -and $dir -like "$env:TEMP*") {
  Write-Host '  [오류] 압축 파일 안에서 바로 실행한 것 같습니다.'
  Write-Host '         ZIP 파일의 압축을 먼저 푼 뒤, 풀린 폴더에서 다시 실행해 주세요.'
  return
}

# Edge 또는 Chrome 찾기
$browser = $null
foreach ($exe in 'msedge.exe', 'chrome.exe') {
  foreach ($root in 'HKCU:', 'HKLM:') {
    $p = (Get-ItemProperty "$root\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$exe" -ErrorAction SilentlyContinue).'(default)'
    if ($p -and (Test-Path $p)) { $browser = $p; break }
  }
  if ($browser) { break }
}
if (-not $browser) {
  Write-Host '  [오류] Microsoft Edge 또는 Google Chrome을 찾지 못했습니다.'
  Write-Host '         둘 중 하나를 설치한 뒤 다시 실행하거나, index.html을 더블클릭해서 사용하세요.'
  return
}

$url = ([System.Uri]$html).AbsoluteUri
$ws  = New-Object -ComObject WScript.Shell
function New-NyangShortcut([string]$folder) {
  $lnk = $ws.CreateShortcut((Join-Path $folder '냥이 투두.lnk'))
  $lnk.TargetPath       = $browser
  $lnk.Arguments        = "--app=`"$url`" --window-size=1120,840"
  $lnk.WorkingDirectory = $dir
  if (Test-Path $icon) { $lnk.IconLocation = "$icon,0" }
  $lnk.Description      = '냥이 투두'
  $lnk.Save()
  Write-Host "  [완료] 만들었습니다: $folder"
}

Write-Host "  브라우저: $browser"
New-NyangShortcut ([Environment]::GetFolderPath('Desktop'))
New-NyangShortcut ([Environment]::GetFolderPath('Programs'))

Write-Host ''
$startup = [Environment]::GetFolderPath('Startup')
$ans = Read-Host '  컴퓨터를 켤 때 냥이 투두를 자동으로 열까요? (y/n)'
if ($ans -match '^[yY]') { New-NyangShortcut $startup }
elseif (Test-Path (Join-Path $startup '냥이 투두.lnk')) {
  Remove-Item (Join-Path $startup '냥이 투두.lnk'); Write-Host '  [완료] 자동 실행을 껐습니다.'
}

Write-Host ''
Write-Host '  완료! 바탕화면의 [냥이 투두] 아이콘을 더블클릭하세요.'
Write-Host '  작업표시줄에 두려면 아이콘을 작업표시줄로 끌어다 놓으면 됩니다.'
