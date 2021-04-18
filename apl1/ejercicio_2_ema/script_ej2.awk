function abs(v) {return v < 0 ? -v : v}

BEGIN	{
    corrections_count=0
    
    opening_parenthesis_count=0
    closing_parenthesis_count=0

    opening_question_mark_count=0
    closing_question_mark_count=0

    opening_exclamation_mark_count=0
    closing_exclamation_mark_count=0
}

{
    opening_parenthesis_count+=gsub("\\(", "(")
    closing_parenthesis_count+=gsub("\\)", ")")

    opening_question_mark_count+=gsub("¿", "¿")
    closing_question_mark_count+=gsub("?", "?")

    opening_exclamation_mark_count+=gsub("¡", "¡")
    closing_exclamation_mark_count+=gsub("!", "!")
}

!/^$/ {
    corrections_count+=gsub(/^\s+|\s+$/, "") # trim
    corrections_count+=gsub(/\s{2,}/, " ") # remove multiple blanks
    a=gensub(/\s+(;|,|\.)/, "\\1", "g") # remove a blank before ".", "," or ";"
    b=gensub(/(;|,|\.)(\w)/, "\\1 \\2", "g", a) # add a space after ".", "," or ";"
    c=gensub(/\. (com|ar|edu)/, ".\\1", "g", b) # remove space from url
    print c
}

END	{
    parenthesis_diff=abs(opening_parenthesis_count-closing_parenthesis_count)
    question_mark_diff=abs(opening_question_mark_count-closing_question_mark_count)
    exclation_mark_diff=abs(opening_exclamation_mark_count-closing_exclamation_mark_count)

    printf "\
    Cantidad de correcciones: %d\n\
    Inconsistencias\n\
        Diferencia de parentesis: %d\n\
        Diferencia de signos de exclamacion: %d\n\
        Diferencia de signos de pregunta: %d\n\
    ", corrections_count, parenthesis_diff, exclation_mark_diff, question_mark_diff > "correcciones.log"
}