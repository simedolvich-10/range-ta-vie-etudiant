param(
  [switch]$StartSite,
  [switch]$ServerOnly
)

$ErrorActionPreference = "Stop"
$siteRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
$rootPrefix = $siteRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
$port = 8765
$siteAddress = "http://127.0.0.1:$port/"
$healthAddress = "${siteAddress}__health"

if ($StartSite) {
  $serverIsReady = $false

  for ($attempt = 0; $attempt -lt 3; $attempt++) {
    try {
      $healthRequest = [System.Net.HttpWebRequest]::Create($healthAddress)
      $healthRequest.Proxy = $null
      $healthRequest.Timeout = 1000
      $healthResponse = $healthRequest.GetResponse()
      try {
        $reader = [System.IO.StreamReader]::new($healthResponse.GetResponseStream())
        try {
          $healthResult = $reader.ReadToEnd()
        } finally {
          $reader.Dispose()
        }
        $serverIsReady = $healthResult -eq "range-ta-vie-etudiant"
      } finally {
        $healthResponse.Dispose()
      }
      break
    } catch [System.Net.WebException] {
      if ($attempt -lt 2) {
        Start-Sleep -Milliseconds 250
      }
    }
  }

  if (-not $serverIsReady) {
    $serverProcessPath = Join-Path $PSHOME "powershell.exe"
    $serverArguments = "-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ServerOnly"
    Start-Process -FilePath $serverProcessPath -ArgumentList $serverArguments -WindowStyle Hidden

    for ($attempt = 0; $attempt -lt 30; $attempt++) {
      Start-Sleep -Milliseconds 300
      try {
        $healthRequest = [System.Net.HttpWebRequest]::Create($healthAddress)
        $healthRequest.Proxy = $null
        $healthRequest.Timeout = 1000
        $healthResponse = $healthRequest.GetResponse()
        try {
          $reader = [System.IO.StreamReader]::new($healthResponse.GetResponseStream())
          try {
            $healthResult = $reader.ReadToEnd()
          } finally {
            $reader.Dispose()
          }
          $serverIsReady = $healthResult -eq "range-ta-vie-etudiant"
        } finally {
          $healthResponse.Dispose()
        }

        if ($serverIsReady) {
          break
        }
      } catch [System.Net.WebException] {
        continue
      }
    }
  }

  if (-not $serverIsReady) {
    [Console]::Error.WriteLine("Le serveur local n'a pas demarre. Verifiez que le port 8765 est libre.")
    exit 1
  }

  Start-Process "${siteAddress}modules.html"
  exit 0
}

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($siteAddress)

try {
  $listener.Start()
} catch {
  [Console]::Error.WriteLine("Impossible de demarrer le serveur local : $($_.Exception.Message)")
  exit 1
}

if (-not $ServerOnly) {
  [Console]::Error.WriteLine("Mode invalide. Utilisez -StartSite ou -ServerOnly.")
  $listener.Close()
  exit 1
}

$contentTypes = @{
  ".css" = "text/css; charset=utf-8"
  ".html" = "text/html; charset=utf-8"
  ".ico" = "image/x-icon"
  ".jpeg" = "image/jpeg"
  ".jpg" = "image/jpeg"
  ".js" = "text/javascript; charset=utf-8"
  ".mp4" = "video/mp4"
  ".png" = "image/png"
  ".svg" = "image/svg+xml"
  ".webp" = "image/webp"
}

try {
  while ($listener.IsListening) {
    try {
      $context = $listener.GetContext()
    } catch [System.Net.HttpListenerException] {
      break
    }

    $request = $context.Request
    $response = $context.Response
    $response.Headers["X-Content-Type-Options"] = "nosniff"

    try {
      if ($request.HttpMethod -eq "GET" -and $request.Url.AbsolutePath -eq "/__health") {
        $healthBytes = [System.Text.Encoding]::UTF8.GetBytes("range-ta-vie-etudiant")
        $response.ContentType = "text/plain; charset=utf-8"
        $response.ContentLength64 = $healthBytes.Length
        $response.OutputStream.Write($healthBytes, 0, $healthBytes.Length)
        $response.Close()
        continue
      }

      if ($request.HttpMethod -ne "GET" -and $request.HttpMethod -ne "HEAD") {
        $response.StatusCode = 405
        $response.Headers["Allow"] = "GET, HEAD"
        $response.Close()
        continue
      }

      $relativePath = [Uri]::UnescapeDataString($request.Url.AbsolutePath.TrimStart("/"))
      if ([string]::IsNullOrWhiteSpace($relativePath)) {
        $relativePath = "index.html"
      }

      $relativePath = $relativePath.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
      $filePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($siteRoot, $relativePath))
      if (-not $filePath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $response.StatusCode = 404
        $response.Close()
        continue
      }

      if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
        $response.StatusCode = 404
        $response.Close()
        continue
      }

      $file = [System.IO.FileInfo]::new($filePath)
      $length = $file.Length
      $extension = $file.Extension.ToLowerInvariant()
      if ($contentTypes.ContainsKey($extension)) {
        $response.ContentType = $contentTypes[$extension]
      } else {
        $response.ContentType = "application/octet-stream"
      }

      $response.Headers["Accept-Ranges"] = "bytes"
      if ($extension -eq ".html") {
        $response.Headers["Cache-Control"] = "no-cache"
      } else {
        $response.Headers["Cache-Control"] = "public, max-age=3600"
      }

      $start = [long]0
      $end = $length - 1
      $rangeHeader = $request.Headers["Range"]

      if ($rangeHeader) {
        if ($rangeHeader -notmatch "^bytes=(\d*)-(\d*)$" -or $length -eq 0) {
          $response.StatusCode = 416
          $response.Headers["Content-Range"] = "bytes */$length"
          $response.ContentLength64 = 0
          $response.Close()
          continue
        }

        if ($Matches[1] -eq "") {
          $suffixLength = [long]::Parse($Matches[2], [System.Globalization.CultureInfo]::InvariantCulture)
          if ($suffixLength -le 0) {
            $response.StatusCode = 416
            $response.Headers["Content-Range"] = "bytes */$length"
            $response.ContentLength64 = 0
            $response.Close()
            continue
          }
          $start = [Math]::Max([long]0, $length - $suffixLength)
        } else {
          $start = [long]::Parse($Matches[1], [System.Globalization.CultureInfo]::InvariantCulture)
          if ($Matches[2] -ne "") {
            $end = [long]::Parse($Matches[2], [System.Globalization.CultureInfo]::InvariantCulture)
          }
        }

        if ($start -ge $length -or $end -lt $start) {
          $response.StatusCode = 416
          $response.Headers["Content-Range"] = "bytes */$length"
          $response.ContentLength64 = 0
          $response.Close()
          continue
        }

        $end = [Math]::Min($end, $length - 1)
        $response.StatusCode = 206
        $response.Headers["Content-Range"] = "bytes $start-$end/$length"
      }

      $responseLength = $end - $start + 1
      $response.ContentLength64 = $responseLength

      if ($request.HttpMethod -eq "HEAD") {
        $response.Close()
        continue
      }

      $stream = [System.IO.File]::OpenRead($filePath)
      try {
        [void]$stream.Seek($start, [System.IO.SeekOrigin]::Begin)
        $buffer = [byte[]]::new(65536)
        $remaining = $responseLength

        while ($remaining -gt 0) {
          $readSize = [int][Math]::Min($buffer.Length, $remaining)
          $bytesRead = $stream.Read($buffer, 0, $readSize)
          if ($bytesRead -eq 0) {
            break
          }

          $response.OutputStream.Write($buffer, 0, $bytesRead)
          $remaining -= $bytesRead
        }
      } finally {
        $stream.Dispose()
        $response.Close()
      }
    } catch {
      [Console]::Error.WriteLine("HTTP error for $($request.Url.AbsolutePath): $($_.Exception.Message)")
      try {
        $response.Abort()
      } catch {
        [Console]::Error.WriteLine("Could not close the HTTP response: $($_.Exception.Message)")
      }
    }
  }
} finally {
  $listener.Close()
}
