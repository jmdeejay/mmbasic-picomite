OPTION BASE 1
OPTION EXPLICIT

RANDOMIZE TIMER

CONST DROPS = 100
CONST TRAIL_LEN = 40
CONST HEAD_COL = rgb(0, 125, 255)
CONST TAIL_COL = rgb(0, 70, 140)

DIM i
DIM x(DROPS), y(DROPS), length(DROPS)

Dim frameCount = 0
Dim fps = 0
Dim lastTime = TIMER - 1000

SUB init_drop(index)
  x(index) = int(rnd() * 320)
  y(index) = int(rnd() * 320)
  length(index) = int(rnd() * TRAIL_LEN) + 10
END SUB

FOR i = 1 TO DROPS
  init_drop(i)
NEXT i

SUB rain
  DO WHILE inkey$ = ""
    FOR i = 1 TO DROPS

      IF length(i) > 0 and x(i) < 320 and y(i) < 320 THEN
        pixel x(i), y(i), TAIL_COL

        x(i) = x(i) + 1
        y(i) = y(i) + 1
        length(i) = length(i) - 1

        IF x(i) < 320 and y(i) < 320 THEN
          pixel x(i), y(i), HEAD_COL
        ENDIF
      ELSE
        init_drop(i)
      ENDIF

    NEXT i

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
END SUB

rain

END
