# Define root paths
$oldConfigRoot = "E:\Server Build\Build\bin\Release_Old"
$newConfigRoot = "E:\Server Build\Build\bin\Release"

# Function to merge configs in a directory
function Merge-Configs {
    param (
        [string]$oldDir,
        [string]$newDir
    )

    # Get all .conf files in the old directory (including subdirectories)
    $oldFiles = Get-ChildItem -Path $oldDir -Filter *.conf -Recurse

    foreach ($oldFile in $oldFiles) {
        try {
            # Calculate relative path from the root config directory
            $relativePath = $oldFile.FullName.Substring($oldDir.Length).TrimStart('\')
            $newFilePath = Join-Path -Path $newDir -ChildPath $relativePath

            # Skip if the relative path is empty (file is in the root directory)
            if ([string]::IsNullOrEmpty($relativePath)) {
                $newFilePath = Join-Path -Path $newDir -ChildPath $oldFile.Name
            }

            if (-not (Test-Path $newFilePath)) {
                Write-Host "New config file $newFilePath does not exist. Skipping."
                continue
            }

            # Read old and new configs
            $oldConfig = Get-Content $oldFile.FullName -Raw
            $newConfig = Get-Content $newFilePath -Raw

            # Create a hashtable for old config (key = setting name, value = setting value)
            $oldSettings = @{}
            $oldConfig -split "`r`n" | ForEach-Object {
                if ($_ -match '^\s*([^=]+?)\s*=\s*(.+?)\s*$') {
                    $key = $matches[1].Trim()
                    $value = $matches[2].Trim()
                    $oldSettings[$key] = $value
                }
            }

            # Update new config with old values (only for existing keys)
            $updatedConfig = @()
            $newConfig -split "`r`n" | ForEach-Object {
                if ($_ -match '^\s*([^=]+?)\s*=\s*(.+?)\s*$') {
                    $key = $matches[1].Trim()
                    $value = $matches[2].Trim()
                    if ($oldSettings.ContainsKey($key)) {
                        $_ = "$key = $($oldSettings[$key])"
                    }
                }
                $updatedConfig += $_
            }

            # Ensure the new directory exists
            $newFileDir = [System.IO.Path]::GetDirectoryName($newFilePath)
            if (-not (Test-Path $newFileDir)) {
                New-Item -ItemType Directory -Path $newFileDir -Force | Out-Null
            }

            # Write the updated config back to the new file
            $updatedConfig | Out-File -FilePath $newFilePath -Force -Encoding UTF8
            Write-Host "Merged $newFilePath successfully."
        }
        catch {
            Write-Host "Error processing $($oldFile.FullName): $_" -ForegroundColor Red
        }
    }
}

# Merge configs for the root and all subdirectories
Merge-Configs -oldDir $oldConfigRoot -newDir $newConfigRoot