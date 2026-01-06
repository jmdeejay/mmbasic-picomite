OPTION EXPLICIT

CONST SCREEN_W = MM.HRES
CONST SCREEN_H = MM.VRES
CONST START_CODE = 32
CONST END_CODE   = 255
CONST TOTAL      = END_CODE - START_CODE + 1

CONST DISABLED_FONT_COLOR = RGB(200, 200, 200)
CONST FONT_COLOR          = RGB(WHITE)
CONST HIGHLIGHT_COLOR     = RGB(WHITE)
CONST SELECTOR_COLOR      = RGB(GREEN)
CONST BACKGROUND_COLOR    = RGB(BLACK)

CONST KEY_ESC$   = CHR$(27)
CONST KEY_UP$    = CHR$(128)
CONST KEY_DOWN$  = CHR$(129)
CONST KEY_LEFT$  = CHR$(130)
CONST KEY_RIGHT$ = CHR$(131)

DIM k$
DIM row%, col%
DIM fontid%, fontsize%
DIM sel%
DIM needsRedraw%

' INPUT "Font number (1 - 16): ", fontid%
' INPUT "Font size (1 - 8): ", fontsize%
fontid% = 1
fontsize% = 2
FONT fontid%, fontsize%

CONST CHAR_W   = MM.FONTWIDTH
CONST CHAR_H   = MM.FONTHEIGHT
CONST MAX_COLS = SCREEN_W \ CHAR_W
CONST MAX_ROWS = (SCREEN_H \ CHAR_H) - 1

FUNCTION SelUp%()
  LOCAL r%, c%
  
  r% = sel% \ MAX_COLS
  c% = sel% MOD MAX_COLS
  r% = r% - 1
  IF r% < 0 THEN r% = (TOTAL - 1) \ MAX_COLS
  
  SelUp% = r% * MAX_COLS + c%
  IF SelUp% >= TOTAL THEN SelUp% = SelUp% - MAX_COLS
END FUNCTION

FUNCTION SelDown%()
  LOCAL r%, c%
  
  r% = sel% \ MAX_COLS
  c% = sel% MOD MAX_COLS
  r% = r% + 1
  
  SelDown% = r% * MAX_COLS + c%
  IF SelDown% >= TOTAL THEN SelDown% = c%
END FUNCTION

SUB DrawCharGrid()
  LOCAL i%, code%
  LOCAL r%, c%
  
  FOR i% = 0 TO TOTAL - 1
    code% = START_CODE + i%
    r% = i% MOD MAX_COLS
    c% = i% \ MAX_COLS
    IF c% >= MAX_ROWS THEN EXIT FOR
    TEXT r% * CHAR_W, c% * CHAR_H, CHR$(code%), "L", , , DISABLED_FONT_COLOR, BACKGROUND_COLOR
  NEXT i%
END SUB

SUB UpdateSelection(value)
  IF value = sel% THEN EXIT SUB
  IF value < 0 THEN value = TOTAL - 1
  IF value > TOTAL - 1 THEN value = 0

  ' Remove selection highlight
  TEXT col% * CHAR_W, row% * CHAR_H, CHR$(START_CODE + sel%), "L", , , DISABLED_FONT_COLOR, BACKGROUND_COLOR
  BOX col% * CHAR_W, row% * CHAR_H, CHAR_W, CHAR_H, , BACKGROUND_COLOR
  
  sel% = value
  col% = sel% MOD MAX_COLS
  row% = sel% \ MAX_COLS
  If col% = 0 And row% = 0 Then Play tone 1000, 1000, 20
  
  needsRedraw% = 1
END SUB

SUB DrawSelection()
  ' Highlight selection
  TEXT col% * CHAR_W, row% * CHAR_H, CHR$(START_CODE + sel%), "L", , , HIGHLIGHT_COLOR, BACKGROUND_COLOR
  BOX col% * CHAR_W, row% * CHAR_H, CHAR_W, CHAR_H, , SELECTOR_COLOR
END SUB

SUB DrawStatusBar()
  LOCAL y, padding
  
  padding = 4
  y = MAX_ROWS * CHAR_H + padding
  LINE 0, y, SCREEN_W, y, , FONT_COLOR
  
  y = y + (CHAR_H / 2) + 1
  BOX 0, y - (CHAR_H / 4), SCREEN_W, CHAR_H / 2, , BACKGROUND_COLOR, BACKGROUND_COLOR
  TEXT SCREEN_W / 2, y, "Code: " + STR$(START_CODE + sel%) + _
    "  Char: '" + CHR$(START_CODE + sel%) + "'" + _
    "  Hex: " + "(0x" + HEX$(START_CODE + sel%) + ")", "CM", , 1
END SUB

'FRAMEBUFFER CREATE
'FRAMEBUFFER WRITE F

COLOR FONT_COLOR, BACKGROUND_COLOR
CLS

sel% = 0
needsRedraw% = 1
DrawCharGrid()

DO
  IF needsRedraw% THEN
    DrawSelection()
    DrawStatusBar()
    
    'FRAMEBUFFER COPY F, N
    needsRedraw% = 0
  ENDIF
  
  DO
    k$ = INKEY$
  LOOP UNTIL k$ <> ""
  
  SELECT CASE k$
    CASE KEY_LEFT$
      UpdateSelection(sel% - 1)
    CASE KEY_RIGHT$
      UpdateSelection(sel% + 1)
    CASE KEY_UP$
      UpdateSelection(SelUp%())
    CASE KEY_DOWN$
      UpdateSelection(SelDown%())
    CASE KEY_ESC$
      EXIT DO
  END SELECT
LOOP

'FRAMEBUFFER WRITE N
CLS

END
