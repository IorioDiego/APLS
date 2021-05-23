[CmdletBinding()]
Param(
    [ValidateScript({
        if(-Not ($_ | Test-Path) ){
            throw "La ruta no existe." 
        }
        if(-Not ($_ | Test-Path -PathType Leaf) ){
            throw "La ruta debe corresponder a un archivo."
        }
        return $true
    })]
    [String] $f
)

$ROOT_PATH = "./"
$INDEX_PATH = "./index.txt"
$TRASH_PATH = "./Papelera"
$CUSTOM_SEPARATOR = "_IDX_TEMP_SEP_"

function addToFilesTable([PSCustomObject] $file) {
    if(!$filesTable.ContainsKey($file.originalName)) {
        $filesTable[$file.originalName] = New-Object System.Collections.ArrayList
    }
    $filesTable[$file.originalName].Add($file)
}

function deleteFromFilesTable([PSCustomObject] $file){
    $filesTable[$fileName].Remove($file)
}

function addToIndexFile([PSCustomObject] $file){
    Add-Content -Path $INDEX_PATH -Value "$($file.alias) $($file.originalName) $($file.path)"
}

function deleteFromIndexFile([PSCustomObject] $file){
    Get-Content $INDEX_PATH | Where-Object {$_ -notmatch $file.alias} | Set-Content $INDEX_PATH
}

function BuildFilesTable {
    Get-Content $INDEX_PATH | ForEach-Object {
        $values = $_.split()
        
        addToFilesTable([PSCustomObject]@{
            alias=$values[0]
            originalName=$values[1]
            path=$values[2]
        })
    }
}

function Initialize {
    if (!(Test-Path $TRASH_PATH)) {
        New-Item -ItemType Directory -Name Papelera -Path $ROOT_PATH
        New-Item -ItemType File -Name index.txt -Path $ROOT_PATH
    }
    
    BuildFilesTable
}

function createTimestamp {
    Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
}

function TrashFile([System.IO.FileSystemInfo] $fileInfo) {
    $newDeletedFile = [PSCustomObject]@{
        alias="$(createTimestamp)$($CUSTOM_SEPARATOR)$($fileInfo.Name)"
        originalName=$fileInfo.Name
        path=$fileInfo.Directory.FullName
    }
    
    addToFilesTable($newDeletedFile)
    addToIndexFile($newDeletedFile)
}

function RestoreFile([String] $fileName){
    $filesWithTheSameName = $filesTable[$fileName]
    $message = ""

    for($i=0; $i -lt $filesWithTheSameName.Count; $i++) {
        $file = $filesWithTheSameName[$i]
        $message += "$($i+1) - $($file.originalName)`t $($file.path)`n"
    }

    $message += "`nQué archivo desea recuperar?"

    [int] $selectedIndex = Read-Host $message

    while( $selectedIndex -lt 1 -or $selectedIndex -gt $filesWithTheSameName.Count ){
        Write-Output "`nVALOR INCORRECTO. Por favor, revise las opciones disponibles.`n"
        $selectedIndex = Read-Host $message
    }
    $selectedIndex--
    $fileToRestore = $filesWithTheSameName[$selectedIndex]
    
    deleteFromFilesTable($fileToRestore)
    deleteFromIndexFile($fileToRestore)
}

$filesTable = @{}
Initialize;
# TrashFile(Get-ChildItem $f)
# RestoreFile("test.txt")