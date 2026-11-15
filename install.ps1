# Installs Squeryl on this Windows computer. It needs only Docker Desktop and your license key, and it is short on
# purpose, so you can read it.
#
# What it does: checks Docker Desktop is installed, running and set to Linux containers, asks for your license key,
# checks that key with Squeryl's license service, makes a folder (Squeryl, in your home folder), downloads the Squeryl
# image, copies the real installer out of that image, and runs it. Nothing is installed outside that folder and Docker.
# Your key is kept in that folder and goes nowhere else. Run it in PowerShell, as yourself, not as an administrator:
#
#   irm https://raw.githubusercontent.com/LocalSEOGuide/squeryl-install/main/install.ps1 | iex
#
# $env:SQUERYL_LICENSE_KEY_FILE names a file holding your key, instead of being asked. $env:SQUERYL_DIR chooses another
# folder. $env:SQUERYL_VERSION chooses another version.
#
# It runs inside your own PowerShell window, so it never closes it: when something is wrong it says so and stops. It is
# written for Windows PowerShell 5.1, which every Windows 11 has, in plain ASCII, which that version reads safely.
& {
  $ErrorActionPreference = 'Stop'
  $ProgressPreference = 'SilentlyContinue'
  Set-StrictMode -Version 2.0

  $Release = ''   # the current release, such as 0.1.0: set here each time one is published. Empty means none yet.
  $Version = if ($env:SQUERYL_VERSION) { $env:SQUERYL_VERSION } else { $Release }
  $Dir = if ($env:SQUERYL_DIR) { $env:SQUERYL_DIR } else { Join-Path $HOME 'Squeryl' }
  $Image = "ghcr.io/localseoguide/squeryl-tracker:$Version"     # what the image is called on this computer, wherever it came from
  $Source = if ($env:SQUERYL_IMAGE_SOURCE) { $env:SQUERYL_IMAGE_SOURCE } else { 'ghcr.io/squeryl-ai/squeryl-tracker' }   # where it downloads from
  $Service = if ($env:SQUERYL_LICENSE_SERVICE) { $env:SQUERYL_LICENSE_SERVICE } else { 'https://license.squeryl-ai.cloud/squeryl' }
  $Support = 'support@localseoguide.com'
  $Project = if ($env:SQUERYL_PROJECT) { $env:SQUERYL_PROJECT } else { 'squeryl' }
  $OnWindows = ($PSVersionTable.PSEdition -eq 'Desktop') -or [bool](Get-Variable -Name IsWindows -ValueOnly -ErrorAction SilentlyContinue)
  $Utf8 = New-Object System.Text.UTF8Encoding $false
  $Arrow = [string][char]0x25B6
  $Cross = [string][char]0x274C
  $Dots = [string][char]0x2026
  try { [Console]::OutputEncoding = $Utf8 } catch { }

  function Say([string]$Text) { Write-Host $Text }
  # A stop, not an exit: an exit would close the window this runs in, before anyone could read why.
  function Fail([string]$Text) { throw (New-Object System.OperationCanceledException $Text) }
  function Docker-Quiet {   # docker, its error output dropped; $LASTEXITCODE says how it went
    $ErrorActionPreference = 'Continue'
    & docker @args 2>$null
  }
  function Field($Object, [string]$Name) {
    if ($null -eq $Object -or $Object -is [string]) { return '' }
    $f = $Object.PSObject.Properties[$Name]
    if ($null -eq $f -or $null -eq $f.Value) { return '' }
    return [string]$f.Value
  }
  function Registry-Of([string]$Address) {   # the name a Docker login file uses for the registry in this image address
    $first = $Address.Split('/')[0]
    if ($first -eq 'docker.io' -or $first -eq 'index.docker.io') { return 'https://index.docker.io/v1/' }
    if ($first.Contains('.') -or $first.Contains(':') -or $first -eq 'localhost') { return $first }
    return 'https://index.docker.io/v1/'   # no registry named: Docker Hub
  }

  $pushed = $false
  try {
    # Before anything else, and before asking for a key: until the first release, there is nothing to install.
    if (-not $Version) {
      Say "Squeryl isn't ready to install yet, so nothing was changed on this computer."
      Say "Write to $Support and we'll let you know when it is."
      $global:LASTEXITCODE = 1
      return
    }
    # This is the Windows installer. A Mac or Linux has install.sh; only the rehearsal runs this one elsewhere.
    if (-not $OnWindows -and $env:SQUERYL_PS_ON_UNIX -ne '1') {
      Fail 'This installer is for Windows. On a Mac or Linux, follow https://github.com/LocalSEOGuide/squeryl-install instead.'
    }

    # Windows uses Docker Desktop, which runs Squeryl's Linux image in a small Linux of its own.
    if ($OnWindows) {
      $bin = Join-Path $env:ProgramFiles 'Docker\Docker\resources\bin'   # for a window opened before Docker Desktop was installed
      if (-not (Get-Command docker -ErrorAction SilentlyContinue) -and (Test-Path -LiteralPath $bin)) { $env:PATH = $env:PATH + ';' + $bin }
    }
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
      Fail 'Docker Desktop is not installed. Get it from https://www.docker.com/products/docker-desktop/, open it once, then run this again.'
    }
    Docker-Quiet info | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Say "$Arrow Starting Docker Desktop$Dots"
      if ($OnWindows) {
        $app = Join-Path $env:ProgramFiles 'Docker\Docker\Docker Desktop.exe'
        if (Test-Path -LiteralPath $app) { Start-Process -FilePath $app | Out-Null }
      }
      $tries = 0
      while ($true) {
        Docker-Quiet info | Out-Null
        if ($LASTEXITCODE -eq 0) { break }
        $tries++
        if ($tries -gt 90) { Fail 'Docker Desktop did not start within three minutes. Open it, wait until it says it is running, then run this again.' }
        Start-Sleep -Seconds 2
      }
    }
    Docker-Quiet compose version | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail 'Docker Compose is missing. Update Docker Desktop to the current version, then run this again.' }
    if (((Docker-Quiet version --format '{{.Server.Os}}') -join '') -eq 'windows') {
      Fail 'Docker Desktop is set to run Windows containers, and Squeryl needs Linux containers. Right-click the Docker icon near the clock, choose "Switch to Linux containers", then run this again.'
    }
    # Squeryl's image is published for 64-bit Intel or AMD (amd64) and 64-bit ARM (arm64) computers.
    $arch = (Docker-Quiet version --format '{{.Server.Arch}}') -join ''
    if ($arch -and $arch -ne 'amd64' -and $arch -ne 'arm64') { Fail "Squeryl runs on 64-bit Intel, AMD or ARM computers, and Docker here says this one is $arch." }

    if (Test-Path -LiteralPath (Join-Path $Dir '.env')) { Fail "Squeryl is already installed in $Dir. See how it is doing with: cd `"$Dir`"; ./squeryl status" }
    $label = "label=com.docker.compose.project=$Project"
    if (((Docker-Quiet ps -aq --filter $label) -join '') + ((Docker-Quiet volume ls -q --filter $label) -join '')) {
      Fail 'Squeryl is already installed on this computer, and one computer takes one installation. Run ./squeryl status in its folder to see how it is doing.'
    }

    if ($env:SQUERYL_LICENSE_KEY_FILE) {
      if (-not (Test-Path -LiteralPath $env:SQUERYL_LICENSE_KEY_FILE -PathType Leaf)) { Fail "Cannot read $env:SQUERYL_LICENSE_KEY_FILE." }
      $key = (Get-Content -Raw -LiteralPath $env:SQUERYL_LICENSE_KEY_FILE) -replace '\s', ''
    } elseif (-not [Console]::IsInputRedirected) {
      $key = (Read-Host 'Your license key, from the email it came in') -replace '\s', ''
    } else {
      Fail 'There is no window to ask for your license key in. Save it in a file, and run this again with $env:SQUERYL_LICENSE_KEY_FILE set to that file.'
    }
    if ($key -cnotmatch '^[A-Za-z0-9-]+$') { Fail 'That does not look like a license key. Copy it again from the email it came in.' }

    Say "$Arrow Checking your license key$Dots"
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch { }
    try {
      $body = Invoke-RestMethod -Method Post -Uri "$Service/download" -ContentType 'application/json' -Body ('{"key":"' + $key + '"}') -TimeoutSec 30 -UseBasicParsing
    } catch {
      $response = $null
      if ($_.Exception.PSObject.Properties['Response']) { $response = $_.Exception.Response }
      if ($null -eq $response) { Fail "Could not reach the license service. Check that this computer is online and try again. If it keeps happening, write to $Support." }
      $reason = ''
      if ($_.ErrorDetails -and $_.ErrorDetails.Message) { try { $reason = Field ($_.ErrorDetails.Message | ConvertFrom-Json) 'error' } catch { } }
      if (-not $reason) { $reason = "The license service answered $([int]$response.StatusCode). Please try again shortly, or write to $Support." }
      Fail $reason
    }
    if ($body -is [string] -and $body.Trim()) { $body = $body | ConvertFrom-Json }

    New-Item -ItemType Directory -Force -Path $Dir | Out-Null
    Push-Location -LiteralPath $Dir
    $pushed = $true

    Docker-Quiet image inspect $Image | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Say "$Arrow Downloading Squeryl $Version. The first time, this can take a few minutes$Dots"
      $user = Field $body 'user'
      $token = Field $body 'token'
      # A throwaway Docker login, used for this one download, so the read token stays nowhere on this computer. It
      # starts with no record of which Docker this computer uses, so it is told.
      $login = $null
      $hadHost = Test-Path Env:DOCKER_HOST
      $oldHost = $env:DOCKER_HOST
      if ($token) {
        $dockerHost = (Docker-Quiet context inspect --format '{{.Endpoints.docker.Host}}') -join ''
        $login = Join-Path ([IO.Path]::GetTempPath()) ('squeryl-login-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $login | Out-Null
        $auth = [Convert]::ToBase64String($Utf8.GetBytes($user + ':' + $token))
        [IO.File]::WriteAllText((Join-Path $login 'config.json'), ('{"auths":{"' + (Registry-Of $Source) + '":{"auth":"' + $auth + '"}}}' + "`n"), $Utf8)
        if ($dockerHost) { $env:DOCKER_HOST = $dockerHost }
      }
      $ErrorActionPreference = 'Continue'
      if ($login) { & docker --config $login pull "${Source}:$Version" 2>&1 | ForEach-Object { "$_" } | Out-Host }
      else { & docker pull "${Source}:$Version" 2>&1 | ForEach-Object { "$_" } | Out-Host }
      $pulled = $LASTEXITCODE
      $ErrorActionPreference = 'Stop'
      if ($hadHost) { $env:DOCKER_HOST = $oldHost } else { Remove-Item Env:DOCKER_HOST -ErrorAction SilentlyContinue }
      if ($login) { Remove-Item -LiteralPath $login -Recurse -Force }
      if ($pulled -ne 0) { Fail "Could not download Squeryl $Version. Check that this computer is online. If it keeps happening, write to $Support." }
      # One name on this computer, wherever it came from, so the installer need not know where that was.
      if ("${Source}:$Version" -ne $Image) {
        Docker-Quiet tag "${Source}:$Version" $Image | Out-Null
        Docker-Quiet image rm "${Source}:$Version" | Out-Null
      }
    }

    # The real installer travels inside the image, so it always matches the version it installs. docker cp, so its
    # bytes arrive exactly as they are.
    $container = (Docker-Quiet create $Image) -join ''
    $copied = ($LASTEXITCODE -eq 0) -and [bool]$container
    if ($copied) {
      foreach ($file in @('squeryl-windows.ps1', 'squeryl.cmd', 'compose.yaml', 'README.md')) {
        Docker-Quiet cp "${container}:/app/install/$file" $file | Out-Null
        if ($LASTEXITCODE -ne 0) { $copied = $false }
      }
      Docker-Quiet rm $container | Out-Null
    }
    if (-not $copied) { Fail "Squeryl $Version does not carry its Windows installer, so nothing was installed." }

    Say "$Arrow Squeryl's folder is $Dir"
    $keyFile = Join-Path $Dir '.license-key'
    [IO.File]::WriteAllText($keyFile, "$key`n", $Utf8)
    # The installer runs as a program of its own, in the PowerShell this is, past Windows' policy on running scripts.
    $shell = (Get-Process -Id $PID).Path
    $ErrorActionPreference = 'Continue'
    & $shell -NoLogo -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Dir 'squeryl-windows.ps1') install --version $Version --key-file $keyFile
    $result = $LASTEXITCODE
    Remove-Item -LiteralPath $keyFile -Force -ErrorAction SilentlyContinue
    $global:LASTEXITCODE = $result
  } catch [System.OperationCanceledException] {
    [Console]::Error.WriteLine("$Cross " + $_.Exception.Message)
    $global:LASTEXITCODE = 1
  } finally {
    if ($pushed) { Pop-Location }
  }
}
# Saved to a file and run with -File, as an assistant does, the result is this script's exit code too.
if ($PSCommandPath) { exit $global:LASTEXITCODE }
