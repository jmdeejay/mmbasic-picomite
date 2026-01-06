OPTION EXPLICIT

'--------------------------------------------------------
' Function to get CPU speed in MHz (string)
'--------------------------------------------------------
FUNCTION GetCpuSpeed$()
    LOCAL cpu_mhz
    cpu_mhz = VAL(MM.INFO(CPUSPEED)) / 1000000
    GetCpuSpeed$ = STR$(cpu_mhz) + " MHz"
END FUNCTION

'--------------------------------------------------------
' Function to get Free memory (string)
'--------------------------------------------------------
FUNCTION GetFreeRam$()
  Local freeMem%
  freeMem% = MM.INFO(HEAP)
  GetFreeRam$ = FormatSize$(freeMem%)
End FUNCTION

'--------------------------------------------------------
' Function to get CPU temperature in °C (string)
'--------------------------------------------------------
SUB PrintCpuTemp()
    LOCAL cpu_temp
    
    cpu_temp = INT(PIN(TEMP) * 100) / 100
    
    PRINT "CPU Temp: ";
    IF cpu_temp < 50 THEN
      COLOUR RGB(GREEN)
    ELSEIF cpu_temp < 70 THEN
      COLOUR RGB(YELLOW)
    ELSEIF cpu_temp < 80 THEN
      COLOUR RGB(RUST)
    ELSE
      COLOUR RGB(RED)
    END IF
    PRINT STR$(cpu_temp); " "; CHR$(96); "C"
    COLOR RGB(WHITE)
END SUB

'--------------------------------------------------------
' Display the ASCII start screen
'--------------------------------------------------------
SUB ShowStartScreen
    CLS
    COLOR RGB(RED)
    PRINT "========================================"
    COLOR RGB(GREEN)
    TEXT 320, 0, CHR$(158) + STR$(MM.INFO(battery)) + "%", "R", 1
    PRINT "       _  __  __       _____    _____  "
    PRINT "      | ||  \/  |     |  __ \  / ____| "
    PRINT "      | || \  / | ___ | |  | || |  __  "
    PRINT "  _   | || |\/| ||___|| |  | || | |_ | "
    PRINT " | |__| || |  | |     | |__| || |__| | "
    PRINT "  \____/ |_|  |_|     |_____/  \_____| "
    COLOR RGB(RED)
    PRINT "========================================"
    COLOR RGB(GREEN)
    PRINT
    COLOR RGB(WHITE)
    PRINT "Welcome to "; MM.DEVICE$; " v"; Trim$(STR$(MM.INFO$(VERSION))); "!"
    PRINT "CPU Speed: "; GetCpuSpeed$()
    PrintCpuTemp()
    PRINT "Free RAM: "; GetFreeRam$()
    COLOR RGB(GREEN)
    PRINT
END SUB

ShowStartScreen

END
