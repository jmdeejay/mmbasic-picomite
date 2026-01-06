OPTION EXPLICIT
RANDOMIZE TIMER

CONST MAX = 18
CONST STEP_DIST = 0.30
CONST BACKGROUND_COLOR = RGB(BLACK)

CONST SNOW_COUNT = 40
CONST SNOW_COLOR = RGB(WHITE)

DIM redSpiral(2) = (RGB(RED), RGB(MIDGREEN), 1)
DIM greenSpiral(2) = (RGB(GREEN), RGB(MIDGREEN), 0)
DIM cyanSpiral(2) = (RGB(CYAN), RGB(BLUE), 1)
DIM yellowSpiral(2) = (RGB(YELLOW), RGB(MYRTLE), 0)
DIM prev(INT(2 * (MAX / STEP_DIST)) + 1, 1)

DIM INTEGER i
DIM INTEGER pointCount = 0
DIM FLOAT j
DIM FLOAT xScale = 6
DIM FLOAT zScale = 2.5
DIM FLOAT yScale = 14
DIM FLOAT dz = MM.VRes
DIM FLOAT phase = 0

DIM FLOAT snowX(SNOW_COUNT)
DIM FLOAT snowY(SNOW_COUNT)
DIM FLOAT snowSpeed(SNOW_COUNT)
DIM FLOAT snowDrift(SNOW_COUNT)

DIM INTEGER frameCount = 0
DIM INTEGER fps = 0
DIM INTEGER lastTime = TIMER - 1000

SUB createSpiral(index, config())
	LOCAL x, y, z, zoff
	LOCAL sign, col, foreground, background
  
	sign = CHOICE(config(2), -1, 1)
	IF config(2) THEN
		foreground = config(0)
		background = config(1)
	ELSE
		foreground = config(1)
		background = config(0)
	ENDIF
  
	zoff = index * SIN(index + phase)
	z = dz / (dz - sign * zoff * zScale)
    x = sign * index * COS(index + phase) * z * xScale + MM.HRes / 2
    y = index * z * yScale + MM.VRes / 2 - (MAX * yScale) / 2 - 16
    
	IF zoff + sign * PI / 4 < 0 THEN
		col = foreground
	ELSE
		col = background
	ENDIF
  
  ' PIXEL prev(pointCount, 0), prev(pointCount, 1), BACKGROUND_COLOR
  BOX prev(pointCount, 0), prev(pointCount, 1), 2, 2, , BACKGROUND_COLOR, BACKGROUND_COLOR
  
	prev(pointCount, 0) = x
	prev(pointCount, 1) = y
  
	' PIXEL x, y, col
	BOX x, y, 2, 2, , col, col
  
	pointCount = pointCount + 1
END SUB

SUB InitSnow()
  LOCAL i
  FOR i = 0 TO SNOW_COUNT - 1
    snowX(i) = RND * MM.HRes
    snowY(i) = RND * MM.VRes
    snowSpeed(i) = 0.2 + RND * 1.2
    snowDrift(i) = -0.2 + RND * 0.4
  NEXT
END SUB

SUB UpdateSnow()
  LOCAL i
  
  FOR i = 0 TO SNOW_COUNT - 1
    PIXEL snowX(i), snowY(i), BACKGROUND_COLOR
    
    snowY(i) = snowY(i) + snowSpeed(i)
    snowX(i) = snowX(i) + snowDrift(i)
    
    snowSpeed(i) = 0.2 + RND * 1.2
    snowDrift(i) = -0.15 + RND * 0.3
    
    IF snowY(i) >= MM.VRes THEN
      snowY(i) = 0
      snowX(i) = RND * MM.HRes
    ENDIF
    IF snowX(i) < 0 THEN snowX(i) = MM.HRes
    IF snowX(i) >= MM.HRes THEN snowX(i) = 0
    
    PIXEL snowX(i), snowY(i), SNOW_COLOR
  NEXT
END SUB

InitSnow()

CLS BACKGROUND_COLOR

DO WHILE INKEY$ <> CHR$(27)
  pointCount = 0
	FOR j = 0 TO MAX STEP STEP_DIST
		IF (j < 0) OR (j > MAX) THEN CONTINUE FOR
      createSpiral(j, redSpiral())
      createSpiral(j, greenSpiral())
	NEXT
	INC phase, 0.1: IF phase > (2 * PI) THEN phase = 0
  
  UpdateSnow()
  
  ' FPS counter
  frameCount = frameCount + 1
  IF TIMER - lastTime >= 1000 THEN
    fps = frameCount
    frameCount = 0
    lastTime = TIMER
    TEXT 320, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
  END IF
  
  PAUSE 1
LOOP

CLS

END
