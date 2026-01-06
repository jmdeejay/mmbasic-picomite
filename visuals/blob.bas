OPTION EXPLICIT
OPTION BASE 0

' ===== CONFIG =====
CONST SCREEN_W = MM.HRES / 2
CONST SCREEN_H = MM.VRES / 2

CONST NUM_BALLS = 6
CONST STP = 15
CONST THRESHOLD = 300
CONST SPEED = 6

CONST BACKGROUND_COLOR = RGB(0, 0, 0)
CONST BLOB_COLOR = RGB(GREEN) ' RGB(120, 40, 140)

' ===== BALL DATA =====
DIM x, y, i
DIM f0, f1, f2, f3, state
DIM bx(NUM_BALLS - 1), by(NUM_BALLS - 1)
DIM vx(NUM_BALLS - 1), vy(NUM_BALLS - 1)
DIM r2(NUM_BALLS - 1)

DIM frameCount = 0
DIM fps = 0
DIM lastTime = TIMER - 1000

FUNCTION field(px, py)
  LOCAL s, dx, dy, d2, i
  s = 0
  FOR i = 0 TO NUM_BALLS-1
    dx = px - bx(i)
    dy = py - by(i)
    d2 = dx*dx + dy*dy
    IF d2 < r2(i) THEN
      s = s + (r2(i) - d2)
    END IF
  NEXT
  field = s
END FUNCTION

FOR i = 0 TO NUM_BALLS - 1
  bx(i) = RND * SCREEN_W
  by(i) = RND * SCREEN_H
  vx(i) = (RND - 0.5) * SPEED
  vy(i) = (RND - 0.5) * SPEED
  r2(i) = (25 + RND * 15) ^ 2
NEXT

RANDOMIZE TIMER
FRAMEBUFFER create
FRAMEBUFFER write F
CLS BACKGROUND_COLOR

' ===== MAIN LOOP =====
DO WHILE INKEY$ <> CHR$(27)
  BOX 0, 0, SCREEN_W, SCREEN_H, , BLOB_COLOR, BACKGROUND_COLOR

  ' Move balls
  FOR i = 0 TO NUM_BALLS - 1
    bx(i) = bx(i) + vx(i)
    by(i) = by(i) + vy(i)
    IF bx(i) < 0 OR bx(i) > SCREEN_W THEN vx(i) = -vx(i)
    IF by(i) < 0 OR by(i) > SCREEN_H THEN vy(i) = -vy(i)
  NEXT

  ' Marching Squares
  FOR y = 0 TO SCREEN_H - STP STEP STP
    FOR x = 0 TO SCREEN_W - STP STEP STP
      
      f0 = field(x, y) > THRESHOLD
      f1 = field(x + STP, y) > THRESHOLD
      f2 = field(x + STP, y + STP) > THRESHOLD
      f3 = field(x, y + STP) > THRESHOLD
      
      state = f0 + f1 * 2 + f2 * 4 + f3 * 8
      
      SELECT CASE state
        CASE 1, 14
          LINE x, y + STP \ 2, x + STP \ 2, y, , BLOB_COLOR
        CASE 2, 13
          LINE x + STP \ 2, y, x + STP, y + STP \ 2, , BLOB_COLOR
        CASE 3, 12
          LINE x, y + STP \ 2, x + STP, y + STP \ 2, , BLOB_COLOR
        CASE 4, 11
          LINE x + STP, y + STP \ 2, x + STP \ 2, y+STP, , BLOB_COLOR
        CASE 6, 9
          LINE x + STP \ 2, y, x + STP \ 2, y+STP, , BLOB_COLOR
        CASE 7, 8
          LINE x, y + STP \ 2, x + STP \ 2, y+STP, , BLOB_COLOR
        CASE 5
          LINE x, y + STP \ 2, x + STP \ 2, y, , BLOB_COLOR
          LINE x + STP, y + STP \ 2, x + STP \ 2, y + STP, , BLOB_COLOR
        CASE 10
          LINE x + STP \ 2, y, x + STP, y + STP \ 2, , BLOB_COLOR
          LINE x, y + STP\2, x + STP \ 2, y + STP, , BLOB_COLOR
      END SELECT
    
    NEXT
  NEXT
  
  ' FPS counter
  frameCount = frameCount + 1
  IF TIMER - lastTime >= 1000 THEN
    fps = frameCount
    frameCount = 0
    lastTime = TIMER
  END IF
  TEXT 320, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
  PAUSE 1
  
  FRAMEBUFFER COPY F, N
LOOP

FRAMEBUFFER WRITE N
CLS
END
