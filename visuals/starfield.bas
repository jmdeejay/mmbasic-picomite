OPTION EXPLICIT

CONST MAX_DEPTH = 32
CONST NUM_STARS = 120
CONST SCREEN_W = MM.HRES
CONST SCREEN_H = MM.VRES

DIM i
DIM t
DIM stars(NUM_STARS - 1, 2) ' x, y, z
DIM starSize(MAX_DEPTH)
DIM starBrightness(MAX_DEPTH)
DIM prev_stars(NUM_STARS - 1, 2) ' x, y, size

Dim frameCount = 0
Dim fps = 0
Dim lastTime = TIMER - 1000

SUB InitStars()
    LOCAL i, z
    FOR i = 0 TO NUM_STARS - 1
        stars(i, 0) = INT(RND * 51) - 25
        stars(i, 1) = INT(RND * 51) - 25
        stars(i, 2) = INT(RND * MAX_DEPTH) + 1
        prev_stars(i, 0) = -1
        prev_stars(i, 1) = -1
        prev_stars(i, 2) = 1
    NEXT i

    FOR z = 1 TO MAX_DEPTH
        starSize(z) = INT((1 - z / MAX_DEPTH) * 4)
        IF starSize(z) < 1 THEN starSize(z) = 1
        starBrightness(z) = INT(255 * (1 - z / MAX_DEPTH))
    NEXT z
END SUB

SUB UpdateStar(i)
    ' Move forward
    stars(i, 2) = stars(i, 2) - 0.19

    IF stars(i, 2) <= 0 THEN
        stars(i, 0) = INT(RND * 51) - 25
        stars(i, 1) = INT(RND * 51) - 25
        stars(i, 2) = MAX_DEPTH
    ENDIF
END SUB

SUB DrawStar(i)
    LOCAL k, x, y, size, cint, psx, psy, pssize

    psx = prev_stars(i, 0)
    psy = prev_stars(i, 1)
    pssize = prev_stars(i, 2)
    IF psx >= 0 AND psy >= 0 THEN
        IF pssize <= 1 THEN
            PIXEL psx, psy, RGB(BLACK)
        ELSE
            BOX psx, psy, pssize, pssize, , RGB(BLACK), RGB(BLACK)
        ENDIF
    ENDIF

    k = 64 / stars(i, 2)
    x = INT(stars(i, 0) * k + (SCREEN_W / 2))
    y = INT(stars(i, 1) * k + (SCREEN_H / 2))

    IF x < 0 OR x >= SCREEN_W OR y < 0 OR y >= SCREEN_H THEN
        prev_stars(i, 0) = -1
        prev_stars(i, 1) = -1
        prev_stars(i, 2) = 1
    ELSE
        size = starSize(INT(stars(i, 2)))
        cint = starBrightness(INT(stars(i, 2)))

        IF size <= 1 THEN
            PIXEL x, y, RGB(cint, cint, cint)
        ELSE
            BOX x, y, size, size, , RGB(cint, cint, cint), RGB(cint, cint, cint)
        ENDIF

        prev_stars(i, 0) = x
        prev_stars(i, 1) = y
        prev_stars(i, 2) = size
    ENDIF
END SUB


SUB DrawTitle(t)
    LOCAL title$, txt_y
    title$ = "Starfield"
    txt_y = (SCREEN_H / 2) + SIN(t / 20) * 4
    TEXT SCREEN_W / 2, txt_y, title$, "C", 3, 1, RGB(WHITE)
END SUB

'--------------------------------------------
' MAIN LOOP
'--------------------------------------------

CLS
RANDOMIZE TIMER
InitStars()

t = 0

DO WHILE INKEY$ <> CHR$(27)
    FOR i = 0 TO NUM_STARS - 1
         UpdateStar(i)
         DrawStar(i)
    NEXT i

    ' Floating title
    t = t + 1
    IF t > 1440 THEN t = 0
    ' DrawTitle(t)

    ' FPS counter
    frameCount = frameCount + 1
    IF TIMER - lastTime >= 1000 THEN
        fps = frameCount
        frameCount = 0
        lastTime = TIMER
        TEXT SCREEN_W, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
    END IF

    PAUSE 1
LOOP

CLS

END
