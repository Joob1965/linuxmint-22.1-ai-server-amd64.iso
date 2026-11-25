[CmdletBinding()]
param(
    [string]$Output = "linuxmint-22.1-ai-server-amd64.iso"
)

$parts = Get-ChildItem -Filter "linuxmint-22.1-ai-server-amd64.iso.part*" |
    Sort-Object Name

if ($parts.Count -eq 0) {
    throw "No ISO parts found."
}

$fs = [System.IO.File]::Create((Resolve-Path .).Path + "\" + $Output)
try {
    foreach ($part in $parts) {
        $input = [System.IO.File]::OpenRead($part.FullName)
        try { $input.CopyTo($fs) } finally { $input.Dispose() }
    }
} finally {
    $fs.Dispose()
}

Get-FileHash $Output -Algorithm MD5
