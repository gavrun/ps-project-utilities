# Dump code from all project files of specified types to a single file
#
# Usage: 
#
# Get-ProjectDump
# Get-ProjectDump -OutFile ".\project_dump.txt"
# 
function Get-ProjectDump {
    param ( 
        [string]$Path = ".",
        [string]$OutFile = "project_dump.txt"
    )
    
    # File extensions to include: ,"*.js" ,"*.css"
    $fileExtensions = @("*.cpp","*.c","*.h","*.hpp","*.inl","*.cmake","*.md","*.txt","*.json","*.yml","*.yaml","*.xml","*.proto",".clang-format",".gitignore","LICENSE","CMakeLists.txt")
    # Directories to exclude: "bin","obj","node_modules"
    $excludeDirs = @("build","bin","obj","out",".vs",".git","CMakeFiles")
    $outputFile = $OutFile
    $projectRoot = Get-Location

    if (Test-Path $outputFile) {
        Remove-Item $outputFile
    }

    Write-Host "Dumping code $($fileExtensions -join ', ') from $($projectRoot.Path)"
    Write-Host "Excluding: $(($excludeDirs | ForEach-Object { '\'+$_ }) -join ', ')"

    $excludePattern = ($excludeDirs | ForEach-Object { "\\$_\\" }) -join '|'

    Get-ChildItem -Path $projectRoot -Recurse -Include $fileExtensions -File | Where-Object {
        $_.FullName -notmatch $excludePattern
    } | ForEach-Object {
        $relativePath = $_.FullName.Replace($projectRoot.Path + "\", "")
        $fileHeader = "\$relativePath"
        # DEBUG
        # Write-Host "Added $relativePath"
        Add-Content -Path $outputFile -Value $fileHeader -Encoding UTF8
        Get-Content -Path $_.FullName -Raw | Add-Content -Path $outputFile -Encoding UTF8
    }

    if (Test-Path $outputFile) {
        Write-Host "Dumped to '$outputFile'."
    } else {
        Write-Host "No files found."
    }
}
