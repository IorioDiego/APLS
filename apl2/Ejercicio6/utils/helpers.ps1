$filesTable = @{}

function addToFilesTable([PSCustomObject] $file) {
    if(!$filesTable.ContainsKey($file.Name)) {
        $filesTable[$file.Name] = New-Object System.Collections.ArrayList
    }
    $null = $filesTable[$file.Name].Add($file)
}

function deleteFromFilesTable([PSCustomObject] $file){
    $filesTable[$fileName].Remove($file)
}

function addToIndexFile([PSCustomObject] $file){
    Add-Content -Path $INDEX_PATH -Value "$($file.Alias) $($file.Name) $($file.Path)"
}

function deleteFromIndexFile([PSCustomObject] $file){
    Get-Content $INDEX_PATH | Where-Object {$_ -notmatch $file.Alias} | Set-Content $INDEX_PATH
}

function addToTrash([PSCustomObject] $file) {
    Move-Item -Path "$($file.Path)/$($file.Name)" -Destination "$($UNCOMPRESSED_TRASH_PATH)/$($file.Alias)"
}

function restoreFromTrash([PSCustomObject] $file) {
    $destination = "$($file.Path)/$($file.Name)"

    if(Test-Path -Path $destination){
        Write-Host "No se puede restaurar, ya existe un archivo con ese nombre en la ruta de destino."
        exit
    }

    Move-Item -Path "$($UNCOMPRESSED_TRASH_PATH)/$($file.Alias)" -Destination $destination
}

function BuildFilesTable {
    if(-Not (Test-Path $INDEX_PATH)){
        return $null
    }

    Get-Content $INDEX_PATH | ForEach-Object {
        $values = $_.split()
        
        addToFilesTable([PSCustomObject]@{
            Alias=$values[0]
            Name=$values[1]
            Path=$values[2]
        })
    }
}

function createTimestamp {
    Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
}

function getFileToRestore {
    $filesWithTheSameName = $filesTable[$fileName]
    
    if($filesWithTheSameName.Count -eq 1){
        return ($filesWithTheSameName[0])
    }

    $message = ""

    for($i=0; $i -lt $filesWithTheSameName.Count; $i++) {
        $file = $filesWithTheSameName[$i]
        $message += "$($i+1) - $($file.Name)`t $($file.Path)`n"
    }

    $message += "`nQué archivo desea recuperar?"

    [int] $selectedIndex = Read-Host $message

    while( $selectedIndex -lt 1 -or $selectedIndex -gt $filesWithTheSameName.Count ){
        Write-Output "`nVALOR INCORRECTO. Por favor, revise las opciones disponibles.`n"
        $selectedIndex = Read-Host $message
    }
    $selectedIndex--
    
    return $filesWithTheSameName[$selectedIndex]
}

function TrashIsEmpty {
    if(Test-Path $UNCOMPRESSED_TRASH_PATH) {
        $uncompresedTrash = Get-ChildItem $UNCOMPRESSED_TRASH_PATH
        return $uncompresedTrash.Count -eq 0
    }

    return (-Not (Test-Path $COMPRESSED_TRASH_PATH))
}