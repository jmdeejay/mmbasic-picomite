OPTION EXPLICIT
OPTION DEFAULT INTEGER

CONST FW = 20
CONST FH = 20
CONST SCALE_Y = 8
CONST SCALE_X = SCALE_Y * 2
CONST MAX_COLOR = 64

CONST OFFSET_X = (MM.HRES - FW * SCALE_X) / 2
CONST OFFSET_Y = MM.VRES - FH * SCALE_Y

DIM i, x, y
DIM r, g, b
DIM row, nextrow, src, rndVal, dest, idx, sx, sy, c
DIM fadeFactor as FLOAT, fsrc as FLOAT
DIM fire(FW * FH)
DIM last(FW * FH)
DIM palette(MAX_COLOR)

Dim frameCount = 0
Dim fps = 0
Dim lastTime = TIMER - 1000

' ---- Build fire palette ----
FOR i = 0 TO MAX_COLOR
    r = MIN(255, i * 7)
    g = MIN(255, i * 3)
    b = MIN(255, i)
    palette(i) = RGB(r, g, b)
NEXT i

' ---- Initialize bottom row to maximum intensity ----
FOR x = 0 TO FW - 1
    fire((FH - 1) * FW + x) = MAX_COLOR
NEXT x

FOR i = 0 TO FW * FH - 1
    last(i) = -1
NEXT i

CLS
RANDOMIZE TIMER

DO WHILE INKEY$ <> CHR$(27)
    ' ---- Fire propagation ----
    FOR y = 0 TO FH - 2
        row = y * FW
        nextrow = (y + 1) * FW
        FOR x = 0 TO FW - 1
            src = fire(nextrow + x)

            IF src > 0 THEN
                rndVal = RND() * 3
                dest = row + ((x - rndVal + FW) MOD FW)
                fire(dest) = src - (rndVal AND 1)
            ELSE
                fire(row + x) = 0
            ENDIF
        NEXT x
    NEXT y

    FOR y = 0 TO FH - 1
        sy = OFFSET_Y + y * SCALE_Y
        row = y * FW
        fadeFactor = (y / (FH - 1.0)) ^ 1.2
        FOR x = 0 TO FW - 1
            sx = OFFSET_X + x * SCALE_X
            idx = row + x
            fsrc = fire(idx) * fadeFactor
            IF fsrc < 0 THEN fsrc = 0
            c = palette(INT(fsrc))
            IF last(idx) <> INT(fsrc) THEN
                last(idx) = INT(fsrc)
                IF SCALE_Y <= 1 THEN
                    PIXEL sx, sy, c
                ELSE
                    BOX sx, sy, SCALE_X, SCALE_Y, , c, c
                END IF
            END IF
        NEXT x
    NEXT y

    ' FPS counter
    frameCount = frameCount + 1
    IF TIMER - lastTime >= 1000 THEN
        fps = frameCount
        frameCount = 0
        lastTime = TIMER
        TEXT MM.HRES, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
    END IF
    
    PAUSE 1
LOOP

CLS

END
