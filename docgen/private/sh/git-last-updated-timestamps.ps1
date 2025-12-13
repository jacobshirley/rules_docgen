# This script generates a JSON mapping of files with their last updated timestamps from git history.

param(
    [Parameter(Mandatory=$true)]
    [string]${filter-extensions},

    [Parameter(Mandatory=$false)]
    [string]${output},

    [Parameter(Mandatory=$false)]
    [string]${git-dir}
)

# Set GIT_DIR environment variable if provided
if (${git-dir}) {
    $env:GIT_DIR = ${git-dir}

    # Resolve git directory by following symlinks inside $git-dir if necessary
    if (Test-Path ${git-dir} -PathType Container) {
        $headPath = Join-Path ${git-dir} "HEAD"

        # Check if HEAD is a symlink (junction/reparse point)
        if (Test-Path $headPath) {
            $item = Get-Item $headPath -Force
            if ($item.LinkType -eq "SymbolicLink" -or $item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                $target = $item.Target
                if ($target) {
                    $realGitDir = Split-Path $target -Parent
                    if (Test-Path (Join-Path $realGitDir "HEAD")) {
                        $env:GIT_DIR = $realGitDir
                    }
                }
            }
        }
    }
}

# Split extensions and build pattern
$extArray = ${filter-extensions} -split ','
$patterns = $extArray | ForEach-Object { "\.$_$" }
$pattern = $patterns -join '|'

# Get git log with dates
$gitLog = git log --name-status --pretty=format:"DATE:%cI" --all

# Parse the log to extract file timestamps
$files = @{}
$currentDate = ""

foreach ($line in $gitLog -split "`n") {
    if ($line -match '^DATE:(.+)$') {
        $currentDate = $matches[1]
        # Normalize timezone format: replace +00:00 with Z for consistency
        $currentDate = $currentDate -replace '\+00:00$', 'Z'
    }
    elseif ($line -match '^[AMD]\t(.+)$') {
        $file = $matches[1]

        # Check if file matches any extension pattern (case-insensitive)
        if ($file -match "(?i)($pattern)" -and $currentDate -and -not $files.ContainsKey($file)) {
            $files[$file] = $currentDate
        }
    }
}

# Build JSON output
$jsonLines = @()
$jsonLines += "{"
$fileCount = $files.Count
$i = 0

foreach ($file in $files.Keys | Sort-Object) {
    $i++
    $comma = if ($i -lt $fileCount) { "," } else { "" }
    $jsonLines += "  `"$file`": `"$($files[$file])`"$comma"
}
$jsonLines += "}"

$result = $jsonLines -join "`n"

# Output result to file or stdout
if (${output}) {
    $result | Out-File -FilePath ${output} -Encoding UTF8 -NoNewline
    Write-Host "Timestamps written to ${output}"
}
else {
    Write-Output $result
}
