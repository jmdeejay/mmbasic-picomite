OPTION EXPLICIT
RANDOMIZE TIMER
OPTION DEFAULT INTEGER

CONST SCR_W = MM.HRES
CONST SCR_H = MM.VRES
CONST SCALE = 4
CONST FW = SCR_W / SCALE
CONST FH = SCR_H / SCALE

CONST PSIZE = 63

DIM idx%(FW * FH)
DIM last%(FW*FH)
DIM palette(PSIZE)
DIM sinX%(FW)
DIM sinY%(FH)
DIM offset AS INTEGER
DIM t AS INTEGER
DIM t2 AS FLOAT
DIM x, y, i, px, py, v, idxPos
DIM r, g, b

Dim frameCount = 0
Dim fps = 0
Dim lastTime = TIMER - 1000

' ========= Precompute sine tables =========
FOR x = 0 TO FW - 1
    sinX%(x) = INT(SIN(x / 10.0) * 32)
NEXT

FOR y = 0 TO FH - 1
    sinY%(y) = INT(SIN(y / 15.0) * 31) + 32
NEXT

' ===== Build palette =====
FOR i = 0 TO PSIZE
  t2 = 2 * PI * i / PSIZE
  r = INT(192 + 63 * ((SIN(t2 + PI / 2) + 1) / 2))
  g = INT(64 + 191 * ((SIN(t2 + PI / 3) + 1) / 2))
  b = INT(32 + 32 * ((SIN(t2) + 1) / 2))
  palette(i) = RGB(r, g, b)
NEXT i

'FRAMEBUFFER CREATE
'FRAMEBUFFER WRITE F
CLS
RANDOMIZE TIMER

' ===== Main loop =====
DO WHILE INKEY$ <> CHR$(27)

  t = INT(TIMER / 200)
  ' Palette cycle offset
  offset = (offset + 1) AND PSIZE
  
  ' Generate plasma and draw in one pass
  FOR y = 0 TO FH - 1
    py = y * SCALE
    FOR x = 0 TO FW - 1
      px = x * SCALE
      idxPos = y * FW + x
            
      ' Use precomputed sine tables
      v = (sinX%(x) + sinY%(y) + t) AND PSIZE
      idx%(idxPos) = v
      
      ' draw only if changed
      IF last%(idxPos) <> v THEN
        last%(idxPos) = v
        ' BOX px, py, SCALE, SCALE, , palette(v), palette(v)
        PIXEL px, py, palette(v)
        PIXEL px + 1, py + 1, palette(v)
      END IF
    NEXT x
  NEXT y

  frameCount = frameCount + 1
  IF TIMER - lastTime >= 1000 THEN
    fps = frameCount
    frameCount = 0
    lastTime = TIMER
    TEXT SCR_W, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
  ENDIF
  ' TEXT SCR_W, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
  
  'FRAMEBUFFER COPY F, N
  PAUSE 1
LOOP

'FRAMEBUFFER WRITE N
CLS

END
