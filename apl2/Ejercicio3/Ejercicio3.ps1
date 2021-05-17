# +++++++++++++++ENCABEZADO+++++++++++++++++++++++++++
# Nombre script: Ejercicio3.ps1
# Trabajo Práctico Nro. 2 (GRUPAL)
# Ejercicio: 3
# Integrantes:
  #  Cardozo Emanuel                    35000234
  #  Iorio Diego                        40730349
  #  Perez Lucas Daniel                 39656325
  #  Ramos Marcos                       35896637
# Nro entrega: Primera Entrega
# +++++++++++++++FIN ENCABEZADO+++++++++++++++++++++++

<#
    .Synopsis
        "El script tiene como finalidad el reducir el espacio ocupado del disco rigido."
    .DESCRIPTION
        -Indicando un umbral y un directorio 
         busca en el mismo los archivos duplicados y aquellos que superen el umbral antes mencionado.
        -Al finalizar realiza un informe que muestra estos archivos. 
         Este informe se guardará en la ruta indicada por el usuario.
    .EXAMPLE
		./Ejercicio3.ps1 -Directorio [DIRECTORIO] -DirectorioSalida [DIRECTORIO DESTINO] -Umbral [UMBRAL]"
        el orden de los parametros puede variar
    .EXAMPLE
		./Ejercicio3.ps1 -Directorio ./Downloads/mi_carpeta/ -Umbral 25 -DirectorioSalida ./salida
#>


Param(     [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {
            if ( -Not (Test-Path $_) ) {
                throw "El Path no existe."
            }
            if ( -Not ( Test-Path $_ -PathType Container ) ) {
                throw "El Path no es un directorio"
            }
            $hayArch = Get-ChildItem -Path $_ -Recurse -File
            if ($hayArch.Count -eq 0) {
                throw "El path ingresado no tiene archivos para analizar"
            }
            return $true
        })]
    [string]$Directorio,
    [Parameter(Mandatory = $false)]
    [ValidateScript( {
            if ($_ -lt 0) {
                throw "El umbral debe ser un entero positivo o Cero"
            }
            return $true
        })]
    [float]$Umbral = -1,
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {
            if ( -Not (Test-Path $_) ) {
                throw "El Path no existe."
            }
            if ( -Not ( Test-Path $_ -PathType Container ) ) {
                throw "El Path no es un directorio"
            }
            return $true
        })]$DirectorioSalida
)


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

$archivos = Get-ChildItem -Path $Directorio -Recurse -File | %{$_.FullName}
$count =0
$arr=@{}
Write-Host /*********************ARCHIVOS REPETIDOS**********************/
ForEach ($item in $archivos) {
    $arr[$count]= $item
    $count += 1 
}
$valores=@{}
$count =0
for ($i = 0; $i -lt $arr.Count ; $i++) {
    for ($j = $($i+1); $j -lt $arr.Count ; $j++) {
        IF(!(Compare-Object -ReferenceObject $(Get-Content $arr[$i]) -DifferenceObject $(Get-Content $arr[$j]))){
            $valores[$count]= Split-Path $arr[$i] -leaf
            $count++
            $valores[$count]= Split-Path $arr[$j] -leaf
            $count++
        }
        
    }
}

$archivos = Get-ChildItem -Path $Directorio -Recurse -File 

$Result = ForEach ($item in $archivos) {
    for ($j = 0; $j -lt $valores.Count ; $j++) {
        $size = $([float]$item.Length / 1024 )
        if ($item.Name -eq $valores[$j]) {
            if ($size -gt $Umbral) {
                $item
            }
        }
    
}
}

$date = Get-Date -Format '{yyyyMMddHHmm}'
$Result |Sort-Object -Unique | Format-Table Name, DirectoryName -HideTableHeaders 
$Result |Sort-Object -Unique | Format-Table Name, DirectoryName -HideTableHeaders | Out-File -FilePath $DirectorioSalida/"Resultado_"$date'.out'