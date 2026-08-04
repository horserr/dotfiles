# link: https://gist.github.com/backerman/2c91d31d7a805460f93fe10bdfa0ffb0?permalink_comment_id=5848611#gistcomment-5848611

# i found this and it was a great starting point, thanks a lot to the people above :3
# i then sunk a little too much time into enhancing it... so here's my version, complete with scp remote-path completion:

using namespace System.Management.Automation

function Get-SSH-Hosts {
  param (
    [string]$filename = "${env:USERPROFILE}\.ssh\config"
  )

  if ([System.IO.File]::Exists($filename)) {
    Get-Content $filename `
    | Select-String -Pattern '^(Include | Host) ' `
    | ForEach-Object {
      if ($_ -match '^Include ') {
        $included = (Join-Path $filename .. ($_ -replace '^Include ', '') -Resolve)
        Get-SSH-Hosts $included
      }
      elseif (!($_ -match '\*')) {
        ($_ -replace '^Host ', '' -split ' ')[0]
      }
    } `
    | Select-Object -Unique
  }
}

function Get-SSH-KnownHosts {
  Get-Content ${env:USERPROFILE}\.ssh\known_hosts `
  | ForEach-Object { ([string]$_).Split(' ')[0] } `
  | ForEach-Object { $_.Split(', ') }
}

Function Complete-SSH-Host {
  param($wordToComplete, $hosts, $generateCompletionText)

  $textToComplete = $wordToComplete
  # preserve username if specified; only complete hostname
  if ($wordToComplete -match '^(?<user>[-\w/\\]+)@(?<host>[-.\w]+)$') {
    $textToComplete = $Matches['host']
    $generateCompletionText = {
      param($hostname)
      "$($Matches['user'])@${hostname}:"
    }
  }

  $allMatches = @()

  $prefixMatch = @($hosts | Where-Object { $_ -like "${textToComplete}*" })
  $allMatches += $prefixMatch

  $substringMatch = @($hosts | Where-Object { $_ -notin $allMatches -and $_ -like "*${textToComplete}*" })
  $allMatches += $substringMatch

  $fuzzyMatchString = ($textToComplete.toCharArray() | Join-String -OutputPrefix '*' -Separator '*' -OutputSuffix '*')
  # not quite smart-casing, but matches with same case shall be offered first
  $fuzzyMatchCased = @($hosts | Where-Object { $_ -notin $allMatches -and $_ -clike $fuzzyMatchString })
  $allMatches += $fuzzyMatchCased
  $fuzzyMatchUncased = @($hosts | Where-Object { $_ -notin $allMatches -and $_ -like $fuzzyMatchString })
  $allMatches += $fuzzyMatchUncased

  $allMatches | ForEach-Object { [CompletionResult]::new((&$generateCompletionText($_)), $_, [CompletionResultType]::ParameterValue, $_) }
}

Register-ArgumentCompleter -CommandName ssh, sftp -Native -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  $hosts = (Get-SSH-Hosts) + (Get-SSH-KnownHosts) | Sort-Object -Unique

  # for now just assume it's a hostname; no command completion
  $generateCompletionText = {
    param($x)
    $x
  }
  Complete-SSH-Host $wordToComplete $hosts $generateCompletionText
}

Register-ArgumentCompleter -CommandName scp -Native -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  $hosts = (Get-SSH-Hosts) + (Get-SSH-KnownHosts) | Sort-Object -Unique

  if ($wordToComplete -match '^(?<remote>([-\w/\\]+@)?([-.\w]+)):(?<path>.*)$') {
    $remote = $Matches['remote']
    $pathPrefix = $Matches['path'] -replace "^'", "" -replace "([^\\])'$", '$1'
    $generateCompletionText = {
      param($path)

      $quotedPath = $path
      if ($quotedPath -match '\s' -and $quotedPath -notmatch "'") {
        $quotedPath = "`'$quotedPath`'"
      }
      "${remote}:${quotedPath}"
    }

    # 'Write-Host' here is a hack to make password/TOTP prompts appear on a new line
    $files = (Write-Host) + (ssh -oRemoteCommand=none $remote shopt -s dotglob`; ls -1dp "'${pathPrefix}'*")

    return $files `
    | ForEach-Object {
      [CompletionResult]::new((&$generateCompletionText($_)), $_, [CompletionResultType]::ParameterValue, $_)
    }
  }

  $generateCompletionText = {
    param($x)
    "${x}:"
  }
  Complete-SSH-Host $wordToComplete $hosts $generateCompletionText
}
