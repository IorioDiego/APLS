!/^$/ {
    gsub(/^\s+|\s+$/, "") # trim
    gsub(/\s{2,}/, " ") # remove multiple blanks
    a=gensub(/\s+(;|,|\.)/, "\\1", "g") # remove a blank before ".", "," or ";"
    b=gensub(/(;|,|\.)(\w)/, "\\1 \\2", "g", a) # add a space after ".", "," or ";"
    c=gensub(/\. (com|ar|edu)/, ".\\1", "g", b) # remove space from url
    print c
}