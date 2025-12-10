# PowerShell script to add last updated information to documentation files

function Update-File {
    param(
        [string]$InputPath,
        [string]$OutputPath
    )

    if (-not (Test-Path $InputPath -PathType Leaf)) {
        return
    }

    if (-not ($InputPath -like "*.md")) {
        $outDir = Split-Path "{out_dir}\$OutputPath" -Parent
        New-Item -Path $outDir -ItemType Directory -Force | Out-Null
        Copy-Item $InputPath "{out_dir}\$OutputPath" -Force
        return
    }

    $outDir = Split-Path "{out_dir}\$OutputPath" -Parent
    New-Item -Path $outDir -ItemType Directory -Force | Out-Null
    Copy-Item $InputPath "{out_dir}\$OutputPath" -Force

    # For JSON lookup, strip everything up to and including the unique folder name
    $jsonLookupPath = $OutputPath -replace '^.*{unique_folder_name}[/\\]', ''

    # Read JSON and get timestamp
    $jsonContent = Get-Content "{json_file}" -Raw | ConvertFrom-Json
    $lastUpdateRaw = $jsonContent.$jsonLookupPath

    if (-not $lastUpdateRaw) {
        $lastUpdateRaw = "Unknown"
    }

    $hasUpdate = $false
    if ($lastUpdateRaw -ne "Unknown") {
        $hasUpdate = $true
        try {
            # Convert ISO 8601 to readable format
            $dateObj = [DateTime]::Parse($lastUpdateRaw)
            $lastUpdate = $dateObj.ToString("{date_format}")
        }
        catch {
            $lastUpdate = $lastUpdateRaw
        }
    }
    else {
        $lastUpdate = Get-Date -Format "{date_format}"
    }

    # Add last updated information to the footer
    $footerLine = "---"

    $updateHistoryUrl = "{update_history_url}"
    if ($updateHistoryUrl -and $hasUpdate) {
        $footerLine += "`nLast updated: [$lastUpdate]($updateHistoryUrl/$OutputPath)"
    }
    else {
        $footerLine += "`nLast updated: $lastUpdate"
    }

    # Append to file with proper line endings
    "`n`n$footerLine`n" | Add-Content -Path "{out_dir}\$OutputPath" -NoNewline
}

# Process arguments
foreach ($arg in $args) {
    # Split argument by colon to get long_path:short_path
    $parts = $arg -split ':', 2
    $longPath = $parts[0]
    $shortPath = $parts[1]

    if (Test-Path $longPath -PathType Container) {
        Get-ChildItem -Path $longPath -Recurse -File | ForEach-Object {
            # Calculate relative path from the directory
            $relPath = $_.FullName.Substring($longPath.Length).TrimStart('\', '/')
            # Combine short_path with the relative path
            $outPath = "$shortPath/$relPath" -replace '\\', '/'
            Update-File -InputPath $_.FullName -OutputPath $outPath
        }
    }
    elseif (Test-Path $longPath -PathType Leaf) {
        Update-File -InputPath $longPath -OutputPath $shortPath
    }
}
