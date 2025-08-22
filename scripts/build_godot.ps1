$missing = Get-Content missing_versions.json | ConvertFrom-Json
if ($missing.Count -eq 0) {
  Write-Host "No missing versions to build."
  exit 0
}
foreach ($version in $missing) {
  $env:GODOT_FILENAME = "Godot_v${version}_win64.exe.zip"
  $env:MONO_FILENAME = "Godot_v${version}_mono_win64.zip"

  New-Item -ItemType Directory -Force -Path "godot_cache" | Out-Null
  New-Item -ItemType Directory -Force -Path "godot_build" | Out-Null
  New-Item -ItemType Directory -Force -Path "godot_build/regular" | Out-Null
  New-Item -ItemType Directory -Force -Path "godot_build/mono" | Out-Null

  $filename = $env:GODOT_FILENAME
  $zipPath  = "godot_cache/$filename"
  if (-Not (Test-Path $zipPath)) {
    Write-Host "Downloading: https://github.com/godotengine/godot/releases/download/$version/$filename"
    Invoke-WebRequest "https://github.com/godotengine/godot/releases/download/$version/$filename" -OutFile $zipPath
  }
  Copy-Item $zipPath -Destination "godot_build/godot.zip" -Force

  $monoFilename = $env:MONO_FILENAME
  $monoZipPath  = "godot_cache/$monoFilename"
  if (-Not (Test-Path $monoZipPath)) {
    Write-Host "Downloading: https://github.com/godotengine/godot/releases/download/$version/$monoFilename"
    Invoke-WebRequest "https://github.com/godotengine/godot/releases/download/$version/$monoFilename" -OutFile $monoZipPath
  }
  Copy-Item $monoZipPath -Destination "godot_build/godot_mono.zip" -Force

  $regularZip = "godot_build/godot.zip"
  $monoZip    = "godot_build/godot_mono.zip"
  if (-Not (Test-Path $regularZip)) { Write-Error "Regular Godot ZIP not found at $regularZip" }
  if (-Not (Test-Path $monoZip))    { Write-Error "Mono Godot ZIP not found at $monoZip" }
  Expand-Archive -Path $regularZip -DestinationPath "godot_build/regular" -Force
  Expand-Archive -Path $monoZip    -DestinationPath "godot_build/mono"    -Force

  # Build installers (requires NSIS)
  & "C:\Program Files (x86)\NSIS\makensis.exe" /DVERSION=$version godot_installer.nsis
  & "C:\Program Files (x86)\NSIS\makensis.exe" /DVERSION=$version godot_mono_installer.nsis

  Write-Host "Built installers for $version"
  # You can add upload or copy logic here for local testing
}
