OPTION EXPLICIT

CONST SCREEN_W = MM.HRES
CONST SCREEN_H = MM.VRES
CONST CHAR_W   = MM.FONTWIDTH
CONST CHAR_H   = MM.FONTHEIGHT
CONST MAX_COLS = SCREEN_W \ CHAR_W
CONST MAX_ROWS = (SCREEN_H \ CHAR_H) - 1

CONST MAX_LINES       = 1000
CONST SCROLL_STEP     = 10
CONST CURSOR_ON_TIME  = 750
CONST CURSOR_OFF_TIME = 250

CONST FONT_COLOR        = RGB(GREEN)
CONST BACKGROUND_COLOR  = RGB(BLACK)
CONST SUCCESS_COLOR     = RGB(MIDGREEN)
CONST ERROR_COLOR       = RGB(RED)

CONST KEY_NULL$       = CHR$(0)
CONST KEY_BACKSPACE$  = CHR$(8)
CONST KEY_RETURN2$    = CHR$(10)
CONST KEY_RETURN$     = CHR$(13)
CONST KEY_ESC$        = CHR$(27)
CONST KEY_UP$         = CHR$(128)
CONST KEY_DOWN$       = CHR$(129)
CONST KEY_LEFT$       = CHR$(130)
CONST KEY_RIGHT$      = CHR$(131)
CONST KEY_SHIFT_UP$   = CHR$(136)
CONST KEY_SHIFT_DOWN$ = CHR$(137)

CONST MODE_READ   = 0
CONST MODE_INSERT = 1

DIM k$
DIM row%, idx%
DIM filename$
DIM wrappedLines$(MAX_LINES)
DIM wrappedCount%
DIM topLine%
DIM cursorLine%, cursorCol%
DIM cursorBlink%
DIM lastBlinkTime
DIM needsRedraw%
DIM mode%
DIM errorMsg$
DIM timerMsg

function ConfirmDialog(msg$) as integer
  local a$
  
  a$ = ""
  DisplayMessageError(msg$, 200)
  
  do
    a$ = ucase$(inkey$)
    if a$ = "Y" then
      ConfirmDialog = 1
      exit DO
    ELSEif a$ = "N" then
      ConfirmDialog = 0
      exit DO
    endif
  loop
  
  drawStatusBar()
end function

' --------------------------------------------------
' Preprocess file into wrappedLines$()
' --------------------------------------------------
SUB LoadAndWrapFile()
  LOCAL ch$, ln$, lastSpace%

  wrappedCount% = 0
  ln$ = ""
  lastSpace% = 0

  OPEN filename$ FOR INPUT AS #1
  DO WHILE NOT EOF(1)
    ch$ = INPUT$(1, 1)
    
    IF ch$ = KEY_RETURN$ OR ch$ = KEY_RETURN2$ THEN
      IF ch$ = KEY_RETURN$ AND NOT EOF(1) THEN
        ch$ = INPUT$(1, 1)
        IF ch$ <> KEY_RETURN2$ THEN SEEK #1, LOC(#1) - 1
      ENDIF
      
      wrappedCount% = wrappedCount% + 1
      wrappedLines$(wrappedCount%) = ln$
      ln$ = ""
      lastSpace% = 0
    ELSEIF ch$ <> KEY_NULL$ THEN
      IF LEN(ln$) >= MAX_COLS THEN
        wrappedCount% = wrappedCount% + 1
        IF lastSpace% > 0 THEN
          wrappedLines$(wrappedCount%) = LEFT$(ln$, lastSpace%)
          ln$ = MID$(ln$, lastSpace% + 1)
        ELSE
          wrappedLines$(wrappedCount%) = LEFT$(ln$, MAX_COLS)
          ln$ = MID$(ln$, MAX_COLS + 1)
        ENDIF
        lastSpace% = 0
      ENDIF
      
      ln$ = ln$ + ch$
      IF ch$ = " " THEN lastSpace% = LEN(ln$)
    ENDIF
    
    IF wrappedCount% >= MAX_LINES THEN EXIT DO
  LOOP

  IF ln$ <> "" AND wrappedCount% < MAX_LINES THEN
    wrappedCount% = wrappedCount% + 1
    wrappedLines$(wrappedCount%) = ln$
  ENDIF

  CLOSE #1
END SUB

SUB ClampCursorAndScroll()
  ' Clamp cursor line
  IF cursorLine% < 1 THEN cursorLine% = 1
  IF cursorLine% > wrappedCount% THEN cursorLine% = wrappedCount%

  ' Clamp column
  IF cursorCol% < 1 THEN cursorCol% = 1
  IF cursorCol% > LEN(wrappedLines$(cursorLine%)) + 1 THEN
    cursorCol% = LEN(wrappedLines$(cursorLine%)) + 1
  ENDIF

  ' Scroll up
  IF cursorLine% < topLine% THEN
    topLine% = cursorLine%
  ENDIF

  ' Scroll down
  IF cursorLine% >= topLine% + MAX_ROWS THEN
    topLine% = cursorLine% - MAX_ROWS + 1
  ENDIF

  ' Clamp topLine
  IF topLine% < 1 THEN topLine% = 1
  IF topLine% + MAX_ROWS - 1 > wrappedCount% THEN
    topLine% = wrappedCount% - MAX_ROWS + 1
    IF topLine% < 1 THEN topLine% = 1
  ENDIF
END SUB

SUB DrawBlinkingCursor()
  LOCAL x, x2, y, col, delay
  
  IF mode% <> MODE_INSERT THEN EXIT SUB
  
  IF cursorBlink% THEN
    delay = CURSOR_ON_TIME
  ELSE
    delay = CURSOR_OFF_TIME
  ENDIF
  
  IF TIMER - lastBlinkTime >= delay THEN
    cursorBlink% = NOT cursorBlink%
    lastBlinkTime = TIMER
  ENDIF
    
  x = (cursorCol% - 1) * CHAR_W
  x2 = cursorCol% * CHAR_W - 1
  y = (cursorLine% - topLine% + 1) * CHAR_H - 1
  col = BACKGROUND_COLOR
  IF cursorBlink% THEN col = FONT_COLOR
  LINE x, y, x2, y, , col
  FRAMEBUFFER COPY F, N
END Sub

SUB DrawStatusBar()
  LOCAL status$
  LOCAL x, y, paddingY
  
  paddingY = 2
  x = 0
  y = (MAX_ROWS * CHAR_H) + paddingY
  LINE x, y, SCREEN_W, y, , FONT_COLOR

  y = y + paddingY + 1
  BOX x, y, SCREEN_W, CHAR_H, , BACKGROUND_COLOR
  
  IF mode% = MODE_INSERT THEN
    status$ = "EDIT MODE        "
  ELSE
    status$ = "READ MODE        "
  ENDIF
  status$ = status$ + "Ln: " + STR$(cursorLine%) + " Col: " + STR$(cursorCol%)
  TEXT x, y, status$
END SUB

Sub DisplayMessageError(value$, durationMs)
  errorMsg$ = value$
  timerMsg = Timer + durationMs
  DrawErrorMsg()
End Sub

Sub DrawErrorMsg()
  LOCAL x, y, paddingY

  If errorMsg$ = "" Then Exit Sub
  
  paddingY = 2
  x = 0
  y = (MAX_ROWS * CHAR_H) + (2 * paddingY) + 1
  If Timer > timerMsg Then
    drawStatusBar()
    errorMsg$ = ""
  ELSE
    Text x, y, errorMsg$, "L", , 1, BACKGROUND_COLOR, ERROR_COLOR
  EndIf
  FRAMEBUFFER COPY F, N
End Sub


' ============= EDIT OPERATIONS =============

SUB InsertChar(ch$)
  LOCAL ln$
  ln$ = wrappedLines$(cursorLine%)
  IF LEN(ln$) >= MAX_COLS THEN
    DisplayMessageError("LINE TOO LONG", 2000)
    EXIT SUB
  ENDIF
  wrappedLines$(cursorLine%) = LEFT$(ln$, cursorCol% - 1) + ch$ + MID$(ln$, cursorCol%)
  cursorCol% = cursorCol% + 1
END SUB

SUB Backspace()
  LOCAL ln$, prev$

  IF cursorCol% > 1 THEN
    ln$ = wrappedLines$(cursorLine%)
    wrappedLines$(cursorLine%) = _
      LEFT$(ln$, cursorCol% - 2) + MID$(ln$, cursorCol%)
    cursorCol% = cursorCol% - 1
  ELSEIF cursorLine% > 1 THEN
    prev$ = wrappedLines$(cursorLine% - 1)
    ln$ = wrappedLines$(cursorLine%)
    wrappedLines$(cursorLine% - 1) = prev$ + ln$
    DeleteLine(cursorLine%)
    cursorLine% = cursorLine% - 1
    cursorCol% = LEN(prev$) + 1
  ENDIF
END SUB

SUB DeleteLine(ln%)
  LOCAL i%
  
  IF ln% < 1 OR ln% > wrappedCount% THEN EXIT SUB
  
  FOR i% = ln% TO wrappedCount% - 1
    wrappedLines$(i%) = wrappedLines$(i% + 1)
  NEXT i%
  
  wrappedLines$(wrappedCount%) = ""
  wrappedCount% = wrappedCount% - 1
  
  IF wrappedCount% < 1 THEN
    wrappedCount% = 1
    wrappedLines$(1) = ""
  ENDIF
END SUB

SUB InsertNewLine()
  LOCAL ln$, lft$, rght$, i%

  ln$ = wrappedLines$(cursorLine%)
  lft$  = LEFT$(ln$, cursorCol% - 1)
  rght$ = MID$(ln$, cursorCol%)

  wrappedLines$(cursorLine%) = lft$
  FOR i% = wrappedCount% TO cursorLine% + 1 STEP -1
    wrappedLines$(i% + 1) = wrappedLines$(i%)
  NEXT i%

  wrappedLines$(cursorLine% + 1) = rght$
  wrappedCount% = wrappedCount% + 1

  cursorLine% = cursorLine% + 1
  cursorCol% = 1
END SUB

SUB SaveFile()
  LOCAL i%

  IF ConfirmDialog("Save file? (Y/N)") THEN
    OPEN filename$ FOR OUTPUT AS #1
    
    FOR i% = 1 TO wrappedCount%
      PRINT #1, wrappedLines$(i%)
    NEXT
    
    CLOSE #1
    DisplayMessageError("FILE SAVED", 2000)
  ENDIF
END SUB


' ================= Main =================
filename$ = MM.CMDLINE$
IF filename$ = "" THEN END

COLOR FONT_COLOR, BACKGROUND_COLOR
FRAMEBUFFER CREATE
FRAMEBUFFER WRITE F

topLine% = 1
cursorLine% = 1
cursorCol% = 1
mode% = MODE_READ
cursorBlink% = 1
lastBlinkTime = TIMER
needsRedraw% = 1

LoadAndWrapFile()

DO
  IF needsRedraw% THEN
    CLS
    FOR row% = 0 TO MAX_ROWS - 1
      idx% = topLine% + row%
      IF idx% > wrappedCount% THEN EXIT FOR
      TEXT 0, row% * CHAR_H, wrappedLines$(idx%)
    NEXT row%
    
    DrawStatusBar()
    
    FRAMEBUFFER COPY F, N
    needsRedraw% = 0
  ENDIF
  
  DO
    k$ = INKEY$
    DrawErrorMsg()
    DrawBlinkingCursor()
    PAUSE 10
  LOOP UNTIL k$ <> ""
  
  IF mode% = MODE_INSERT THEN
    IF k$ = KEY_ESC$ THEN
      mode% = MODE_READ
      needsRedraw% = 1
    ELSEIF k$ = KEY_BACKSPACE$ THEN
      Backspace()
      ClampCursorAndScroll()
      needsRedraw% = 1
    ELSEIF k$ = KEY_RETURN$ THEN
      InsertNewLine()
      ClampCursorAndScroll()
      needsRedraw% = 1
    ELSEIF ASC(k$) >= 32 AND ASC(k$) < 127 THEN
      InsertChar(k$)
      needsRedraw% = 1
    ELSEIF k$ = KEY_LEFT$ THEN
      IF cursorCol% > 1 THEN
        cursorCol% = cursorCol% - 1
      ELSEIF cursorLine% > 1 THEN
        cursorLine% = cursorLine% - 1
        cursorCol% = LEN(wrappedLines$(cursorLine%)) + 1
      ENDIF
      ClampCursorAndScroll()
      needsRedraw% = 1
    ELSEIF k$ = KEY_RIGHT$ THEN
      IF cursorCol% < LEN(wrappedLines$(cursorLine%)) + 1 THEN
        cursorCol% = cursorCol% + 1
      ELSEIF cursorLine% < wrappedCount% THEN
        cursorLine% = cursorLine% + 1
        cursorCol% = 1
      ENDIF
      ClampCursorAndScroll()
      needsRedraw% = 1
    ENDIF
  ELSE
    IF k$ = KEY_ESC$ THEN
      EXIT DO
    ELSEIF LCASE$(k$) = "i" THEN
      mode% = MODE_INSERT
      needsRedraw% = 1
    ELSEIF LCASE$(k$) = "s" THEN
      SaveFile()
    ELSEIF k$ = KEY_UP$ OR k$ = KEY_SHIFT_UP$ THEN
      cursorLine% = topLine%
    ELSEIF k$ = KEY_DOWN$ OR k$ = KEY_SHIFT_DOWN$ THEN
      cursorLine% = topLine% + MAX_ROWS - 1
      IF cursorLine% > wrappedCount% THEN cursorLine% = wrappedCount%
    ENDIF
  ENDIF
  
  IF k$ = KEY_UP$ THEN
    cursorLine% = cursorLine% - 1
    ClampCursorAndScroll()
    needsRedraw% = 1
  ELSEIF k$ = KEY_DOWN$ THEN
    cursorLine% = cursorLine% + 1
    ClampCursorAndScroll()
    needsRedraw% = 1
  ELSEIF k$ = KEY_SHIFT_UP$ THEN
    cursorLine% = cursorLine% - SCROLL_STEP
    ClampCursorAndScroll()
    needsRedraw% = 1
  ELSEIF k$ = KEY_SHIFT_DOWN$ THEN
    cursorLine% = cursorLine% + SCROLL_STEP
    ClampCursorAndScroll()
    needsRedraw% = 1
  ENDIF
LOOP

FRAMEBUFFER WRITE N
CLS
RUN "/menu.bas"
END
