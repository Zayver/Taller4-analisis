TYPE Item
    value AS INTEGER
    weight AS INTEGER
END TYPE

REM MAX ITEM SIZE = 255
TYPE ItemArray
    items(255) AS Item
    size AS INTEGER
END TYPE

TYPE BackResult
    res as Integer
    backtrack as ItemArray
END TYPE

CONST INFINITY = 1000


SUB readFile(filename as String, itemsA as ItemArray)
    OPEN filename FOR INPUT AS #1
    Dim textLine as String
    i = 0

    DO UNTIL EOF(1)
        LINE INPUT #1, textLine
        k = INSTR(textLine, " ")
        v = VAL(MID$(textLine, 1, k))
        w = VAL(MID$(textLine, k+1))

        Dim it as Item
        it.value = v
        it.weight = w

        itemsA.items(itemsA.size) = it
        itemsA.size = itemsA.size+1

    LOOP


    CLOSE #1

END SUB

REM POR ALGUNA HERMOSA RAZON EN ESTE LENGUAJE EL RETORNO ES ASIGNAR EL NOMBRE DE LA FUNCION
FUNCTION g(i AS INTEGER, w AS INTEGER, items as ItemArray) AS INTEGER
    IF i = 0 THEN
        g = 0
    ELSEIF items.items(i).weight > w THEN
        g = g(i-1, w, items)
    ELSE
        a = g(i-1, w, items)
        b = g(i-1, w-items.items(i).weight, items)+items.items(i).value

        IF a > b THEN

            g = a
        ELSE

            g = b
        END IF
    END IF
END FUNCTION

FUNCTION g_memoized(i AS INTEGER, w AS INTEGER, items as ItemArray, M() as INTEGER) AS INTEGER
    IF M(i, w) = 0 THEN
        IF i = 0 THEN
            M(i,w) = 0
        ELSEIF items.items(i).weight > w THEN
            M(i,w) = g_memoized(i-1, w, items, M())
        ELSE
            a = g_memoized(i-1, w, items, M())
            b = g_memoized(i-1, w-items.items(i).weight, items, M())+items.items(i).value

            IF a > b THEN

                M(i,w) = a
            ELSE

                M(i,w) = b
            END IF
        END IF
    END IF
    g_memoized = M(i,w)
END FUNCTION

FUNCTION g_bottomup(w AS INTEGER, items AS ItemArray) AS INTEGER
    Dim M(items.size, w) AS INTEGER
    
    FOR i=0 TO items.size-1
        FOR j=0 TO w-1
            IF i = 0 OR j = 0 THEN
                M(i,j) = 0
            ELSEIF items.items(i-1).weight > j THEN
                M(i,j) = M(i-1, j)

            ELSE
                a = M(i-1, j)
                b = M(i-1, w-items.items(i).weight)+items.items(i).value
                IF a > b THEN
                    M(i,j) = a
                ELSE
                    M(i,j) = b
                END IF
            END IF
        NEXT j
    NEXT i
    g_bottomup = M(items.size-1, w-1)


END FUNCTION

FUNCTION g_backtrack(w AS INTEGER, items as ItemArray) as BackResult
    Dim M(items.size, w) as INTEGER
    Dim B(items.size, w) as INTEGER

    FOR i = 0 TO items.size-1
        FOR j = 0 TO w-1
            B(i,j) = -1
        NEXT j
    NEXT i
    
    
    FOR i=0 TO items.size-1
        FOR j=0 TO w-1
            IF i = 0 OR j = 0 THEN
                M(i,j) = 0
            ELSEIF items.items(i-1).weight > j THEN
                M(i,j) = M(i-1, j)

            ELSE
                a = M(i-1, j)
                _b = M(i-1, w-items.items(i).weight)+items.items(i).value
                IF a > _b THEN
                    M(i,j) = a
                ELSE
                    M(i,j) = _b
                    B(i,j) = i

                END IF
            END IF
        NEXT j
    NEXT i

    Dim res as BackResult
    res.res = M(items.size-1, w-1)
    res.backtrack.size = 0
    _i = items.size -1
    _j = w-1
    
    WHILE B(_i,_j) <> -1
        res.backtrack.items(res.backtrack.size) = items.items(B(_i,_j))
        res.backtrack.size = res.backtrack.size+1
        _i = _i-1
    WEND


    g_backtrack = res

END FUNCTION


SUB main()
    IF LEN(COMMAND$(2)) = 0 THEN
        PRINT "Error, Uso: "& COMMAND$(0) & " [filename] [max]"  
        SYSTEM
    END IF

    Dim filename as String
    filename = COMMAND$(1)
    Dim size as integer
    size = VAL(COMMAND$(2))

    Dim items as ItemArray
    readFile(filename, items)


    Dim M(size, items.size) as INTEGER
    PRINT g(items.size-1, size-1, items)
    PRINT g_memoized(items.size-1, size-1, items, M())
    PRINT g_bottomup(size, items)

    Dim res as BackResult
    res = g_backtrack(size, items)
    PRINT res.res;
    FOR i=0 TO res.backtrack.size-1
        PRINT "(" & res.backtrack.items(i).value & "," & res.backtrack.items(i).weight & ") ";
    NEXT i
    PRINT

END SUB

main()
