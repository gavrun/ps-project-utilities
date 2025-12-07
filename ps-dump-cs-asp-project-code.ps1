# Dump code from all project files of specified types to a single file
#
# Usage: 
#
# Get-ProjectDump
# Get-ProjectDump -OutFile ".\project_dump.txt"
# Get-ProjectDump -OutFile ".\doc_dump.txt"
# Get-ProjectDump -OutFile ".\test_dump.txt"
# 
function Get-ProjectDump {
    param ( 
        [string]$Path = ".",
        [string]$OutFile = "project_dump.txt"
    )
    
    # File extensions to include: "*.cs","*.cshtml"
    $fileExtensions = @("*.md","*.cs","*.cshtml","*.json","*.xml","*.html","*.js" ,"*.css")
    # Directories to exclude: "bin","obj","node_modules","wwwroot\\lib\\"
    $excludeDirs = @("bin","obj","wwwroot\\lib\\bootstrap\\dist","wwwroot\\lib\\bootswatch\\dist","wwwroot\\lib\\jquery\\dist","wwwroot\\lib\\jquery-validation\\dist","wwwroot\\lib\\jquery-validation-unobtrusive")
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
