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