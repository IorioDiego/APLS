$filesTable = @{}

function addToFilesTable([PSCustomObject] $file) {
    if(!$filesTable.ContainsKey($file.Name)) {
        $filesTable[$file.Name] = New-Object System.Collections.ArrayList
    }
    $filesTable[$file.Name].Add($file)
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
    Move-Item -Path "$($file.Path)/$($file.Name)" -Destination "$($TRASH_PATH)/$($file.Alias)"
}

function restoreFromTrash([PSCustomObject] $file) {
    $destination = "$($file.Path)/$($file.Name)"

    if(Test-Path -Path $destination){
        Write-Host "No se puede restaurar, ya existe un archivo con ese nombre en la ruta de destino."
        exit
    }

    Move-Item -Path "$($TRASH_PATH)/$($file.Alias)" -Destination $destination
}

function BuildFilesTable {
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

function Initialize {
    if (!(Test-Path $TRASH_PATH)) {
        New-Item -ItemType Directory -Name Papelera -Path $ROOT_PATH
        New-Item -ItemType File -Name index.txt -Path $ROOT_PATH
    }
    
    BuildFilesTable
}

function TrashFile([System.IO.FileSystemInfo] $fileInfo) {
    $newDeletedFile = [PSCustomObject]@{
        alias="$(createTimestamp)$($CUSTOM_SEPARATOR)$($fileInfo.Name)"
        Name=$fileInfo.Name
        path=$fileInfo.Directory.FullName
    }
    
    addToTrash($newDeletedFile)
    addToFilesTable($newDeletedFile)
    addToIndexFile($newDeletedFile)
}

function getFileToRestore {
    $filesWithTheSameName = $filesTable[$fileName]
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

function RestoreFile([String] $fileName){
    if($filesTable.ContainsKey($fileName)){
        $fileToRestore = getFileToRestore
        
        restoreFromTrash($fileToRestore)
        deleteFromFilesTable($fileToRestore)
        deleteFromIndexFile($fileToRestore)
    } else {
        Write-Host "No hay archivos en la papelera con ese nombre. Utiliza la opción -l para listar los elementos."
        exit
    }
}

function ListTrashFiles {
    Write-Host "Elementos de la papelera"
    foreach ($key in $filesTable.Keys) {
        foreach ($file in $filesTable[$key]) {
            Select-Object -InputObject $file -Property Name,Path
        }
    }
}

function CleanTrash {
    Remove-Item "$($TRASH_PATH)/*" -Recurse
    Set-Content $INDEX_PATH -Value $null
    Write-Host "La papelera se ha vaciado exitosamente."
}