' XOR magic trick :)

OPTION EXPLICIT
RANDOMIZE TIMER

SUB PressAnyKey()
  LOCAL dummy$
  INPUT "Press ENTER to return to menu", dummy$
END SUB

FUNCTION IsNumeric(s$)
  LOCAL i, startIndex, c$
  
  IF s$ = "" THEN IsNumeric = 0 : EXIT FUNCTION

  ' Allow negative (leading minus)
  IF LEFT$(s$, 1) = "-" THEN
    IF LEN(s$) = 1 THEN IsNumeric = 0 : EXIT FUNCTION
    startIndex = 2
  ELSE
    startIndex = 1
  END IF

  FOR i = startIndex TO LEN(s$)
    c$ = MID$(s$, i, 1)
    IF c$ < "0" OR c$ > "9" THEN
      IsNumeric = 0
      EXIT FUNCTION
    END IF
  NEXT

  IsNumeric = 1
END FUNCTION

SUB ReadInteger(prompt$, BYREF value)
  LOCAL s$

  DO
    PRINT prompt$;
    INPUT s$
    IF IsNumeric(s$) THEN
      value = VAL(s$)
      EXIT SUB
    END IF
    PRINT "Please enter a valid number."
  LOOP
END SUB

SUB ReadIntegerRange(prompt$, BYREF value, minVal, maxVal)
  LOCAL s$, v

  DO
    PRINT prompt$;
    INPUT s$

    IF IsNumeric(s$) = 0 THEN
      PRINT "Please enter a valid number."
    ELSE
      v = VAL(s$)
      IF v < minVal OR v > maxVal THEN
        PRINT "Value must be between"; minVal; " and"; maxVal
      ELSE
        value = v
        EXIT SUB
      END IF
    END IF
  LOOP
END SUB


' ==========================
' === XOR Swap variables ===
' ==========================
DIM a, b
DIM oriA, oriB

SUB ResetVar()
  a = oriA
  b = oriB
  PRINT "Before swap:"; " a ="; a; ", b ="; b
END SUB

SUB PrintVar()
  PRINT "After swap:"; " a ="; a; ", b ="; b
  PRINT ""
END SUB

SUB ExecuteXORSwap()
  CONST MAX_INT_HALVED = 2147483646
  LOCAL x, y, tmp
  
  PRINT "=========================="
  PRINT "=     Swap variables     ="
  PRINT "=========================="

  ReadIntegerRange("Enter number for a: ", oriA, -MAX_INT_HALVED, MAX_INT_HALVED)
  ReadIntegerRange("Enter number for b: ", oriB, -MAX_INT_HALVED, MAX_INT_HALVED)
  PRINT ""
  
  ' 2 temporary variables swap
  PRINT "2 temporary variables swap"
  ResetVar()
  x = b
  y = a
  a = x
  b = y
  PrintVar()

  ' 1 temp variable swap
  PRINT "1 temporary variable swap"
  ResetVar()
  tmp = a
  a = b
  b = tmp
  PrintVar()

  ' Math swap
  PRINT "Math swap"
  ResetVar()
  a = a + b
  b = a - b
  a = a - b
  PrintVar()

  ' XOR swap
  PRINT "XOR swap"
  ResetVar()
  a = a XOR b
  b = b XOR a
  a = a XOR b 
  PrintVar()
  PRINT ""
  
  PressAnyKey()
END SUB


' =================================
' ===== XOR encrypt / decrypt =====
' =================================
FUNCTION XOREncryptDecrypt(msg$, encryptKey) AS STRING
  LOCAL result$, i
  result$ = ""
  FOR i = 1 TO LEN(msg$)
    result$ = result$ + CHR$(ASC(MID$(msg$, i, 1)) XOR encryptKey)
  NEXT
  XOREncryptDecrypt = result$
END FUNCTION

SUB ExecuteXOREncrypt()
  LOCAL msg$, result$
  LOCAL encryptKey, encryptKey2
  
  result$ = ""
  INPUT "Enter your message: "; msg$
  ReadIntegerRange("Secret key to encrypt (1-255): ", encryptKey, 1, 255)

  PRINT "=========================="
  PRINT "= XOR encrypt / decrypt  ="
  PRINT "=========================="

  result$ = XOREncryptDecrypt(msg$, encryptKey)
  PRINT "Encrypted:"
  PRINT result$
  PRINT ""
  
  ReadIntegerRange("Secret key to decrypt (1-255): ", encryptKey2, 1, 255)
  result$ = XOREncryptDecrypt(result$, encryptKey2)
  PRINT "Decrypted:"
  PRINT result$
  PRINT ""
  PRINT ""
  
  PressAnyKey()
END SUB


' ================================
' ===== XOR Duplicate Finder =====
' ================================
SUB GenerateArrayWithDuplicate(arr(), total)
    LOCAL i, j, dupValue, insertIndex, tmp
    
    FOR i = 0 TO total - 1
      arr(i) = i + 1
    NEXT
    
    dupValue = INT(RND * total) + 1
    insertIndex = INT(RND * (total + 1))
    
    FOR i = total TO insertIndex + 1 STEP - 1
      arr(i) = arr(i - 1)
    NEXT
    
    arr(insertIndex) = dupValue
    
    ' Shuffle array (Fisher-Yates)
    FOR i = total TO 1 STEP - 1
      j = INT(RND * (i + 1))
      tmp = arr(i)
      arr(i) = arr(j)
      arr(j) = tmp
    NEXT
END SUB

SUB ExecuteXORDuplicateFinder()
  LOCAL TOTAL_ENTRIES
  LOCAL x, i
  LOCAL tStart, tEnd, elapsedTime
  
  ReadIntegerRange("Enter number of entries (2-35000): ", TOTAL_ENTRIES, 2, 35000)

  PRINT "=========================="
  PRINT "=  XOR Duplicate Finder  ="
  PRINT "=========================="
  
  LOCAL xs(TOTAL_ENTRIES)
  GenerateArrayWithDuplicate(xs(), TOTAL_ENTRIES)

  tStart = TIMER
  x = 0
  FOR i = 1 TO TOTAL_ENTRIES
    x = x XOR i
  NEXT
  FOR i = 0 TO TOTAL_ENTRIES
    x = x XOR xs(i)
  NEXT
  tEnd = TIMER
  
  IF TOTAL_ENTRIES <= 1000 THEN
    PRINT "Initial array = [";
    FOR i = 0 TO TOTAL_ENTRIES
      IF xs(i) = x THEN
        COLOR RGB(RED)
      ELSE
        COLOR RGB(GREEN)
      END IF
      
      PRINT xs(i);
      IF i < TOTAL_ENTRIES THEN
        PRINT ",";
      ELSE
        PRINT " ";
      ENDIF
    NEXT
    COLOR RGB(GREEN)
    PRINT "]"
  END IF
  
  PRINT "Duplicate value:";
  COLOR RGB(RED)
  PRINT x
  COLOR RGB(GREEN)
  
  elapsedTime = tEnd - tStart
  IF elapsedTime < 1000 THEN
    PRINT "Found in "; FORMAT$(elapsedTime, "%.2f"); " ms"
  ELSE
    elapsedTime = elapsedTime / 1000
    PRINT "Found in "; FORMAT$(elapsedTime, "%.2f"); " s"
  END IF
  
  PRINT ""
  PRINT ""
  
  PressAnyKey()
END SUB


' ========================
' ===== Main program =====
' ========================
DIM choice$

DO
  CLS
  PRINT "===== Menu ====="
  PRINT "1. XOR Swap Variables"
  PRINT "2. XOR Encrypt / Decrypt"
  PRINT "3. XOR Duplicate Finder"
  PRINT "q. Quit"
  PRINT
  INPUT "Enter your choice: "; choice$
  
  SELECT CASE choice$
    CASE "1"
      ExecuteXORSwap()
    CASE "2"
      ExecuteXOREncrypt()
    CASE "3"
      ExecuteXORDuplicateFinder()
    CASE "q", "Q", CHR$(27)
      EXIT DO
    CASE ELSE
      PRINT "Invalid choice. Please select: 1, 2, 3 or q."
      PressAnyKey()
  END SELECT
  PAUSE 1
LOOP

CLS
END
