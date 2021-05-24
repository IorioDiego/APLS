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
    [String] $f,
    [String] $r,
    [Switch] $l
)
    
Import-Module -Force "./utils/constants.ps1"
Import-Module -Force "./utils/helpers.ps1"

Initialize;

if($l) {
    ListTrashFiles
}

if($r){
    RestoreFile($r)
}

# TrashFile(Get-ChildItem $f)