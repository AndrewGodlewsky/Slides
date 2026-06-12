# Embeds the per-repo security audit reports (risk assessment/*.md) into
# Token-Reduction-Skills-Research.html as inert <script type="text/markdown"> blocks,
# and tags each Section E table row with a data-report attribute.
# Rerunnable: refreshes existing report blocks and skips rows already tagged.

$ErrorActionPreference = 'Stop'
$html = Join-Path $PSScriptRoot 'Token-Reduction-Skills-Research.html'
$mdDir = Join-Path $PSScriptRoot 'risk assessment'

# first-cell text in the audit table -> markdown file basename
$map = [ordered]@{
  'microsoft/LLMLingua'                   = 'LLMLingua'
  '567-labs/instructor'                   = 'instructor'
  'dottxt-ai/outlines'                    = 'outlines'
  'guidance-ai/guidance'                  = 'guidance'
  'BoundaryML/baml'                       = 'baml'
  'yamadashy/repomix'                     = 'repomix'
  'coderamp-labs/gitingest'               = 'gitingest'
  'mufeedvh/code2prompt'                  = 'code2prompt'
  'simonw/files-to-prompt'                = 'files-to-prompt'
  'olivomarco/copilot-token-optimization' = 'github-copilot-token-optimization'
  'microsoft/markitdown'                  = 'markitdown'
  'juliusbrussee/caveman'                 = 'caveman'
  'mem0ai/mem0'                           = 'mem0'
  'GibsonAI/memori'                       = 'memori'
  'DeusData/codebase-memory-mcp'          = 'codebase-memory-mcp'
}

$c = [IO.File]::ReadAllText($html)

# 1. tag table rows
$tagged = 0
foreach ($repo in $map.Keys) {
  $plain = "<tr><td>$repo</td>"
  $taggedRow = "<tr data-report=`"$($map[$repo])`"><td>$repo</td>"
  if ($c.Contains($plain)) { $c = $c.Replace($plain, $taggedRow); $tagged++ }
  elseif (-not $c.Contains($taggedRow)) { Write-Warning "row not found: $repo" }
}

# 2. build report blocks
$blocks = New-Object Text.StringBuilder
foreach ($name in $map.Values) {
  $md = [IO.File]::ReadAllText((Join-Path $mdDir "$name.md")).TrimEnd()
  if ($md -match '</script') { throw "$name.md contains '</script' - cannot embed safely" }
  [void]$blocks.AppendLine("<script type=`"text/markdown`" id=`"report-$name`">")
  [void]$blocks.AppendLine($md)
  [void]$blocks.AppendLine('</script>')
}

# 3. insert at marker (replace any previously injected blocks)
$marker = '<!-- audit-reports -->'
$endMarker = '<!-- /audit-reports -->'
$payload = "$marker`n$($blocks.ToString())$endMarker"
$start = $c.IndexOf($marker)
if ($start -lt 0) { throw "marker $marker not found in HTML" }
$end = $c.IndexOf($endMarker)
if ($end -ge 0) { $c = $c.Remove($start, $end + $endMarker.Length - $start).Insert($start, $payload) }
else { $c = $c.Replace($marker, $payload) }

[IO.File]::WriteAllText($html, $c, (New-Object Text.UTF8Encoding($false)))
"rows newly tagged: $tagged / $($map.Count); embedded $($map.Count) reports; html now $([math]::Round((Get-Item $html).Length/1KB)) KB"
