
class Acta {
    [string] $dni
    $notas
    
    Acta() {
        $this.notas=@()
    }

    Acta([string]$dni, $materia) {
        $this.dni = $dni
        $this.notas+=$materia
    }
}