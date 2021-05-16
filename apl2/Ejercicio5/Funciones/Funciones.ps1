
# Cantidad maxima de campos en los archivos
$CANTIDAD_MAX=15

function Validar-Extension {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $archivo,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $extension
    )
    
    if( [System.IO.Path]::GetExtension($archivo).Equals($extension) -or 
        [System.IO.Path]::GetExtension($archivo).Equals($extension.ToUpper()) ) {
        return $true
    }
    return $false
}

function Validar-NombreCsv {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $archivo
    )
    $archivo
    if( ( $archivo -match '^\d{4,4}_\d{8,8}\.(csv|CSV)$' ) ) {
        return $true
    }
    return $false
}

function Gen-Header {
    $HEADER=@()
    $HEADER += "dni"
    for( $i = 1; $i -lt $CANTIDAD_MAX; $i ++ ) {
        $HEADER += [string]$i
    }
   
    return $HEADER
    
}


function Calcular-Campos {
    Param(
        [Parameter(Mandatory=$true)]
        $campo
    )
    $cantidad = 0
    for($i = 1; $i -le $CANTIDAD_MAX; $i ++) {
        if( $campo."$i" -eq 'B' -or $campo."$i" -eq 'R' -or $campo."$i" -eq 'M') {
            $cantidad ++
        }
    }
    
    return $cantidad
}


function Calcular-Notas {
    Param(
        [Parameter(Mandatory=$true)]
        $fila,
        [Parameter(Mandatory=$true)]
        [int]$cantidad
    )
    $notaFinal = 0

    for( $i=1; $i -lt $CANTIDAD_MAX; $i ++) {
        if($fila."$i" -eq 'B') {
            $notaFinal+=(10 / ( $cantidad)) 
        }elseif($fila."$i"-eq 'R') {
            $notaFinal+=(10 /  ( $cantidad)) / 2 
        }
    }
    $notaFinal = ([Math]::Round($notaFinal * 10)) / 10
    return $notaFinal
}

function Generar-Salida {
    Param(
        [Parameter(Mandatory=$true)]
        $actas,
        [Parameter(Mandatory=$true)]
        [string]$salida
    )

    '{ "actas": ' > $salida
    $actas.GetEnumerator() | ForEach-Object {
        $actas[$_.key]
    }|ConvertTo-Json >> $salida
    '}' >> $salida


    Get-Content $salida                         | 
    ForEach-Object { $_ -replace '\"{', '{'  }  |
    ForEach-Object { $_ -replace '}\"', '}'  }  |
    ForEach-Object { $_ -replace '\"{', '{'  }  | 
    ForEach-Object { $_ -replace '\\', ''    }  |
    ForEach-Object { $_ -replace '\\n', ''   }  |
    ForEach-Object { $_ -replace '{n', '{'   }  |
    ForEach-Object { $_ -replace 'n}', '  }'  }  |
    ForEach-Object { $_ -replace ',n', ','   }   > "./temp.json"


    Get-Content "./temp.json" > $salida

    Remove-Item "./temp.json"
}