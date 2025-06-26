# Find invisible or non-ASCII Unicode characters in project files, which can cause unexpected behavior or build issues
# Example: like Zero-Width Space \u200B, Left-To-Right Mark \u200E, etc.
#
# Usage: 
# Find-NonAsciiCharacters -filePath "C:\path\to\project_file.cpp"
#
function Find-NonAsciiCharacters {
    param (
        [Parameter(Mandatory = $true)]
        [string]$filePath
    )

    if (-Not (Test-Path $filePath)) {
        Write-Host "File not found: $filePath" -ForegroundColor Red
        return
    }

    $lineNumber = 1
    Get-Content -Path $filePath -Encoding UTF8 | ForEach-Object {
        $line = $_
        for ($j = 0; $j -lt $line.Length; $j++) {
            $ch = $line[$j]
            $codePoint = [int][char]$ch
            if ($codePoint -gt 127) {
                $hex = '{0:X4}' -f $codePoint
                Write-Host "Line ${lineNumber}: Non-ASCII character '$ch' (U+$hex) at position $j"
            }
        }
        $lineNumber++
    }
}
