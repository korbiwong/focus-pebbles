# Serves the app folder at http://localhost:8765 for testing on this computer.
param([int]$Port = 8765)
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$types = @{ ".html"="text/html; charset=utf-8"; ".js"="text/javascript"; ".json"="application/json";
  ".webmanifest"="application/manifest+json"; ".svg"="image/svg+xml"; ".png"="image/png"; ".css"="text/css" }
$http = New-Object System.Net.HttpListener
$http.Prefixes.Add("http://localhost:$Port/")
$http.Start()
Write-Host "Focus Pebbles running at http://localhost:$Port/"
while ($http.IsListening) {
  $ctx = $http.GetContext()
  $path = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart("/")
  if ($path -eq "") { $path = "index.html" }
  $file = Join-Path $root $path
  $full = [IO.Path]::GetFullPath($file)
  if ($full.StartsWith($root) -and (Test-Path $full -PathType Leaf)) {
    $bytes = [IO.File]::ReadAllBytes($full)
    $ext = [IO.Path]::GetExtension($full).ToLower()
    $ctx.Response.ContentType = $(if ($types[$ext]) { $types[$ext] } else { "application/octet-stream" })
    $ctx.Response.Headers.Add("Cache-Control", "no-cache")
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else { $ctx.Response.StatusCode = 404 }
  $ctx.Response.Close()
}
