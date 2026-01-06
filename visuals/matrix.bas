OPTION BASE 1
OPTION EXPLICIT

CONST W = 40
CONST H = 25
CONST TRAIL_L = H \ 2
CONST TRAIL_MIN = 4
CONST TRAIL_AREA = H \ 2
CONST CHR_W = MM.INFO(fontwidth)
CONST CHR_H = MM.INFO(fontheight)

CONST HEAD_C = rgb(0, 255, 0)
CONST TAIL_C = rgb(0, 180, 0)

DIM p(W), t(W), col_x(W)
DIM i, x, y, clr_y

Dim frameCount = 0
Dim fps = 0
Dim lastTime = TIMER - 1000

SUB new_trail(index)
  p(index) = int(rnd() * TRAIL_AREA)
  t(index) = int(rnd() * TRAIL_L) + TRAIL_MIN
END SUB

FUNCTION rnd_chr$()
  rnd_chr$ = chr$(int(rnd() * 90 + 33))
END FUNCTION

SUB matrix
  RANDOMIZE TIMER
  CLS
  ' init cols and calculate x pos
  FOR i = 1 to W
    col_x(i) = (i - 1) * CHR_W
    new_trail(i)
  NEXT i

  DO WHILE inkey$ = ""
    FOR i = 1 to W
      ' for all cols
      x = col_x(i)
      y = p(i) * CHR_H

      ' new random char
      IF p(i) < H THEN
        color TAIL_C
        print @(x, y - CHR_H) rnd_chr$()
        IF p(i) + 1 < H THEN
          color HEAD_C
          print @(x, y) rnd_chr$()
        ENDIF
      ENDIF

      ' delete char at tail
      clr_y = (p(i) - t(i)) * CHR_H
      IF clr_y >= 0 and clr_y < H * CHR_H THEN
        print @(x, clr_y) " "
      ENDIF

      ' increase y pos
      p(i) = p(i) + 1

      ' reset trail if done
      IF (p(i) - t(i)) >= H THEN
        new_trail(i)
      ENDIF
    NEXT i

    ' FPS counter
    frameCount = frameCount + 1
    IF TIMER - lastTime >= 1000 THEN
        fps = frameCount
        frameCount = 0
        lastTime = TIMER
    END IF
    TEXT MM.HRES, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
    
    PAUSE 1
  LOOP

  print @(0, 0)
  CLS
END SUB

matrix

END
