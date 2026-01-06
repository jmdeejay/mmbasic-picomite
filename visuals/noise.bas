OPTION EXPLICIT
OPTION DEFAULT INTEGER

CONST SCALE = 8
CONST FW = MM.HRES / SCALE
CONST FH = MM.VRES / SCALE
CONST TOTAL_COLORS = 8

DIM i, col, x, y, newVal
DIM px(FW, FH)
DIM c(TOTAL_COLORS - 1)

DIM frameCount = 0
DIM fps = 0
DIM lastTime = TIMER - 1000

FOR i = 0 TO TOTAL_COLORS - 1
  col = INT(i * 255 / (TOTAL_COLORS - 1))
  c(i) = RGB(col, col, col)
NEXT i

RANDOMIZE TIMER
CLS
'FRAMEBUFFER CREATE
'FRAMEBUFFER WRITE F

DO WHILE INKEY$ <> CHR$(27)
  FOR y = 0 TO FH - 1
    FOR x = 0 TO FW - 1
      newVal = INT(RND() * TOTAL_COLORS)
      IF newVal <> px(x, y) THEN
        px(x, y) = newVal
        BOX x * SCALE, y * SCALE, SCALE, SCALE, , c(newVal), c(newVal)
        'PIXEL x * SCALE, y * SCALE, c(newVal)
      END IF
    NEXT x
  NEXT y
  
    ' FPS counter
  frameCount = frameCount + 1
  IF TIMER - lastTime >= 1000 THEN
    fps = frameCount
    frameCount = 0
    lastTime = TIMER
  END IF
  TEXT MM.HRES, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
  
  'FRAMEBUFFER COPY F, N
  PAUSE 1
LOOP

'FRAMEBUFFER WRITE N
CLS

END
