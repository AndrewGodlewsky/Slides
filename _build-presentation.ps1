Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$imgDir = Join-Path $root "images"

function Get-JpegDataUri([string]$path, [int]$maxW, [long]$quality) {
    $img = [System.Drawing.Image]::FromFile($path)
    if ($img.Width -gt $maxW) {
        $nw = $maxW
        $nh = [int][math]::Round($img.Height * $maxW / $img.Width)
    } else {
        $nw = $img.Width
        $nh = $img.Height
    }
    $bmp = New-Object System.Drawing.Bitmap($nw, $nh)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($img, 0, 0, $nw, $nh)
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $quality)
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, $codec, $ep)
    $uri = "data:image/jpeg;base64," + [Convert]::ToBase64String($ms.ToArray())
    $ms.Dispose(); $g.Dispose(); $bmp.Dispose(); $img.Dispose()
    return $uri
}

function Get-PngDataUri([string]$path) {
    return "data:image/png;base64," + [Convert]::ToBase64String([IO.File]::ReadAllBytes($path))
}

Write-Host "Encoding images..."
$cover    = Get-JpegDataUri (Join-Path $imgDir "Gemini_Generated_Image_7s1rxu7s1rxu7s1r.png") 1600 78
$gambling = Get-JpegDataUri (Join-Path $imgDir "AI gambling.png") 1600 82
$compound = Get-JpegDataUri (Join-Path $imgDir "Compound error problem.png") 1400 85
$context  = Get-JpegDataUri (Join-Path $imgDir "Context window V2.png") 2400 85
$harness  = Get-PngDataUri  (Join-Path $imgDir "Harness and Contacts window.png")
$math     = Get-PngDataUri  (Join-Path $imgDir "Co-pilot model usage math.png")

$html = [IO.File]::ReadAllText((Join-Path $root "_slides-template.html"))
$html = $html.Replace("{{IMG_COVER}}", $cover)
$html = $html.Replace("{{IMG_GAMBLING}}", $gambling)
$html = $html.Replace("{{IMG_COMPOUND}}", $compound)
$html = $html.Replace("{{IMG_CONTEXT}}", $context)
$html = $html.Replace("{{IMG_HARNESS}}", $harness)
$html = $html.Replace("{{IMG_MATH}}", $math)

$out = Join-Path $root "Token-Saving-GitHub-Copilot.html"
[IO.File]::WriteAllText($out, $html, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("Wrote {0} ({1:N0} KB)" -f $out, ((Get-Item $out).Length / 1KB))
