' Starfield like win95 on PicoCalc

CONST STARS_COLOR = RGB(WHITE)
CONST BACKGROUND_COLOR = RGB(BLACK)

w = MM.HRES
h = MM.VRES
cx = w / 2
cy = h / 2
n = 100 + asc("*")
speed = .2

DIM x(n), y(n), z(n)
DIM prev(n, 2)

DIM frameCount = 0
DIM fps = 0
DIM lastTime = TIMER - 1000

sub one
 x(i) = (rnd * 2 - 1) * w
 y(i) = (rnd * 2 - 1) * h
 z(i) = rnd * 9 + 1
end sub

FOR i = 0 TO n
 one
NEXT i

RANDOMIZE TIMER
CLS

DO WHILE INKEY$ <> CHR$(27)
	k$ = inkey$
	IF k$ = chr$(128) THEN speed = speed + .1
	IF k$ = chr$(129) THEN speed = speed - .1

	FOR i = 0 TO n
		z(i) = z(i) - speed
		IF z(i) <= .1 THEN one
		sx = int(cx + x(i) / z(i))
		sy = int(cy + y(i) / z(i))
		s = .5 + int((10 - z(i)) * .12)

		circle prev(i, 0), prev(i, 1), prev(i, 2), , , BACKGROUND_COLOR, BACKGROUND_COLOR

		IF sx < 0 or sx >= w or sy < 0 THEN CONTINUE FOR
		IF sy >= h THEN CONTINUE FOR

        prev(i, 0) = sx
        prev(i, 1) = sy
        prev(i, 2) = s

		circle sx, sy, s, , , STARS_COLOR, STARS_COLOR
	NEXT i

	' FPS counter
	frameCount = frameCount + 1
	IF TIMER - lastTime >= 1000 THEN
		fps = frameCount
		frameCount = 0
		lastTime = TIMER
		TEXT w, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
	END IF

	PAUSE 1
LOOP

CLS

END
