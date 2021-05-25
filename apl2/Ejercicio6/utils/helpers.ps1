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

function Initialize([Switch] $CreateTrash) {
    if($CreateTrash) {
        if (-Not (Test-Path $COMPRESSED_TRASH_PATH)) {
            $null = New-Item -ItemType Directory -Name Papelera -Path $PAPELERA_ROOT_PATH
        }
        
        if (-Not (Test-Path $INDEX_PATH)) {
            $null = New-Item -ItemType File -Name index.txt -Path $ROOT_PATH
        }
    }
    
    BuildFilesTable
}

function TrashFile([String] $filePath) {

    $fileInfo = Get-ChildItem $filePath
    $newDeletedFile = [PSCustomObject]@{}
    
    if(Test-Path $filePath -PathType Container){
        $newDeletedFile | Add-Member -NotePropertyMembers @{
            Alias="$(createTimestamp)$($CUSTOM_SEPARATOR)$($fileInfo.Directory.Name)";
            Name=$fileInfo.Directory.Name;
            Path=$fileInfo.Directory.Parent.FullName
        }

    } else {
        $newDeletedFile | Add-Member -NotePropertyMembers @{
            Alias="$(createTimestamp)$($CUSTOM_SEPARATOR)$($fileInfo.Name)";
            Name=$fileInfo.Name;
            Path=$fileInfo.Directory.FullName
        }
    }

    addToTrash($newDeletedFile)
    addToFilesTable($newDeletedFile)
    addToIndexFile($newDeletedFile)

    Write-Host "El elemento ha sido eliminado exitosamente."
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

function RestoreFile([String] $fileName){
    if( -Not (TrashIsEmpty) -and $filesTable.ContainsKey($fileName)){
        $fileToRestore = getFileToRestore
        
        restoreFromTrash($fileToRestore)
        deleteFromFilesTable($fileToRestore)
        deleteFromIndexFile($fileToRestore)

        Write-Host "Se ha recuperado el archivo exitosamente."
    } else {
        Write-Host "No hay archivos en la papelera con ese nombre. Utiliza la opción -l para listar los elementos."
    }
}

function ListTrashFiles {

    if(TrashIsEmpty){
        Write-Host "La papelera se encuentra vacía."
        exit
    }

    Write-Host "Elementos de la papelera"

    foreach ($key in $filesTable.Keys) {
        foreach ($file in $filesTable[$key]) {
            Select-Object -InputObject $file -Property Name,Path
        }
    }
}

function CleanTrash {

    if(TrashIsEmpty){
        Write-Host "La papelera ya se encuentra vacía."
        exit
    }

    if(Test-Path $COMPRESSED_TRASH_PATH) {
        Remove-Item $COMPRESSED_TRASH_PATH
    }

    if(Test-Path $INDEX_PATH) {
        Remove-Item $INDEX_PATH
    }
    Write-Host "La papelera se ha vaciado exitosamente."
}

function CompressTrash {
    Compress-Archive -Path $UNCOMPRESSED_TRASH_PATH -DestinationPath $COMPRESSED_TRASH_PATH
    Remove-Item $UNCOMPRESSED_TRASH_PATH -Recurse

    if(TrashIsEmpty) {
        Remove-Item $INDEX_PATH
    }
}

function UncompressTrash {
    if(Test-Path $COMPRESSED_TRASH_PATH) {
        Expand-Archive -Path $COMPRESSED_TRASH_PATH -DestinationPath $ROOT_PATH
        Remove-Item $COMPRESSED_TRASH_PATH
    }
}