# Draws a tree structure of a directory and its subdirectories with files.
#
# Usage:
#
# Draw-Tree
# Draw-Tree -Path "C:\project\docs"
#
# exclude files:
#
# Draw-Tree -IncludeFiles:$true
# Draw-Tree -Path "C:\project\docs" -IncludeFiles:$true
#

function Draw-Tree {
    param (
        [string]$Path = ".",
        [string]$Prefix = "",
        [bool]$IncludeFiles = $false
    )

    $items = Get-ChildItem -LiteralPath $Path | Sort-Object -Property PSIsContainer, Name

    if (-not $IncludeFiles) {
        $items = $items | Where-Object { $_.PSIsContainer }
    }

    for ($i = 0; $i -lt $items.Count; $i++) {
        
        $item = $items[$i]
        $isLast = ($i -eq $items.Count - 1)
        $pointer = if ($isLast) { "└── " } else { "├── " }

        Write-Output "$Prefix$pointer$item"

        if ($item.PSIsContainer) {
            
            if ($isLast) {
                $newPrefix = "$Prefix    "
            } else {
                $newPrefix = "$Prefix│   "
            }

            Draw-Tree -Path $item.FullName -Prefix $newPrefix -IncludeFiles:$IncludeFiles
        }
    }
}
