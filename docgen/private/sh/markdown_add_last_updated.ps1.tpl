# PowerShell script to add last updated information to documentation files

function Update-File {
    param(
        [string]$InputPath,
        [string]$OutputPath
    )

    if (-not (Test-Path $InputPath -PathType Leaf)) {
        return
    }

    # Normalize output path - convert forward slashes to backslashes
    $OutputPath = $OutputPath -replace '/', '\'
    $outputFullPath = Join-Path "{out_dir}" $OutputPath

    if (-not ($InputPath -like "*.md")) {
        $outDir = Split-Path $outputFullPath -Parent
        New-Item -Path $outDir -ItemType Directory -Force | Out-Null
        Copy-Item $InputPath $outputFullPath -Force
        return
    }

    $outDir = Split-Path $outputFullPath -Parent
    New-Item -Path $outDir -ItemType Directory -Force | Out-Null
    Copy-Item $InputPath $outputFullPath -Force

    # Remove read-only attribute if present (Bazel files can be read-only)
    if (Test-Path $outputFullPath) {
        Set-ItemProperty -Path $outputFullPath -Name IsReadOnly -Value $false
    }

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
    $footerLine = "`n---"

    $updateHistoryUrl = "{update_history_url}"
    if ($updateHistoryUrl -and $hasUpdate) {
        $footerLine += "`nLast updated: [$lastUpdate]($updateHistoryUrl/$OutputPath)"
    }
    else {
        $footerLine += "`nLast updated: $lastUpdate"
    }

    # Append to file with proper line endings
    "$footerLine`n" | Add-Content -Path $outputFullPath -NoNewline
}

# Process arguments
foreach ($arg in $args) {
    # Split argument by colon to get long_path:short_path
    # On Windows, need to handle drive letters like C:, so split from the last occurrence
    # that's not followed by a backslash
    if ($arg -match '^(.*):([^:]+)$') {
        $longPath = $matches[1]
        $shortPath = $matches[2]
    }
    else {
        Write-Error "Invalid argument format: $arg"
        continue
    }

    if (Test-Path $longPath -PathType Container) {
        # Resolve to absolute path for proper comparison
        $longPathResolved = Resolve-Path $longPath
        Get-ChildItem -Path $longPath -Recurse -File | ForEach-Object {
            # Calculate relative path from the directory
            $relPath = $_.FullName.Substring($longPathResolved.Path.Length).TrimStart('\', '/')
            # Use just the relative path, ignoring short_path like Unix version
            $outPath = $relPath -replace '\\', '/'
            Update-File -InputPath $_.FullName -OutputPath $outPath
        }
    }
    elseif (Test-Path $longPath -PathType Leaf) {
        Update-File -InputPath $longPath -OutputPath $shortPath
    }
}
