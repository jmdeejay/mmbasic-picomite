'===========================================================
' PicoCalc Bouncing Rainbow Line with Smooth Fading Trail
'===========================================================

OPTION EXPLICIT

CONST SCREEN_W = MM.HRES
CONST SCREEN_H = MM.VRES
Const TRAIL_LEN = 60       ' number of lines in trail
CONST TRAIL_W = 1
Const THETA_STEP = 0.12    ' how fast rainbow cycles
Const PAUSE_MS = 1         ' animation speed

'-----------------------------------------------------------
' Variables
'-----------------------------------------------------------
Dim x1 As Integer, y1 As Integer
Dim x2 As Integer, y2 As Integer
Dim dx1 As Integer, dy1 As Integer
Dim dx2 As Integer, dy2 As Integer
Dim theta As Float

' Buffers for trail
Dim trailX1%(TRAIL_LEN-1)
Dim trailY1%(TRAIL_LEN-1)
Dim trailX2%(TRAIL_LEN-1)
Dim trailY2%(TRAIL_LEN-1)
Dim trailTheta(TRAIL_LEN-1) As Float

Dim i As Integer
Dim fade As Float
Dim cR, cG, cB As Integer

Dim frameCount = 0
Dim fps = 0
Dim lastTime = TIMER - 1000

RANDOMIZE TIMER

' Initial positions
x1 = INT(RND * SCREEN_W)
y1 = INT(RND * SCREEN_H)
x2 = INT(RND * SCREEN_W)
y2 = INT(RND * SCREEN_H)

dx1 = 2 : dy1 = 3
dx2 = -3 : dy2 = 2

CLS
theta = 0

'-----------------------------------------------------------
' Main loop
'-----------------------------------------------------------
DO WHILE INKEY$ <> CHR$(27)
    ' Shift trail arrays to make room for new line
    FOR i = 0 TO TRAIL_LEN-2
        trailX1%(i) = trailX1%(i+1)
        trailY1%(i) = trailY1%(i+1)
        trailX2%(i) = trailX2%(i+1)
        trailY2%(i) = trailY2%(i+1)
        trailTheta(i) = trailTheta(i+1)
    NEXT i

    ' Store current line at end of trail
    trailX1%(TRAIL_LEN-1) = x1
    trailY1%(TRAIL_LEN-1) = y1
    trailX2%(TRAIL_LEN-1) = x2
    trailY2%(TRAIL_LEN-1) = y2
    trailTheta(TRAIL_LEN-1) = theta

    ' Draw entire trail with fading effect
    FOR i = 0 TO TRAIL_LEN - 1
        fade = (i + 1) / TRAIL_LEN  ' oldest line dimmest
        ' Compute rainbow color based on stored theta
        cR = INT((SIN(trailTheta(i)) + 1) * 127 * fade)
        cG = INT((SIN(trailTheta(i) + 2) + 1) * 127 * fade)
        cB = INT((SIN(trailTheta(i) + 4) + 1) * 127 * fade)
        COLOR RGB(cR, cG, cB)
        LINE trailX1%(i), trailY1%(i), trailX2%(i), trailY2%(i), TRAIL_W
    NEXT i

    ' Update endpoints
    x1 = x1 + dx1
    y1 = y1 + dy1
    x2 = x2 + dx2
    y2 = y2 + dy2

    ' Bounce off walls
    IF x1 < 0 OR x1 >= SCREEN_W THEN dx1 = -dx1
    IF y1 < 0 OR y1 >= SCREEN_H THEN dy1 = -dy1
    IF x2 < 0 OR x2 >= SCREEN_W THEN dx2 = -dx2
    IF y2 < 0 OR y2 >= SCREEN_H THEN dy2 = -dy2

    ' Increment theta for rainbow cycling
    theta = theta + THETA_STEP
    IF theta > 2 * PI THEN theta = theta - 2 * PI

    ' FPS counter
    frameCount = frameCount + 1
    IF TIMER - lastTime >= 1000 THEN
        fps = frameCount
        frameCount = 0
        lastTime = TIMER
        TEXT SCREEN_W, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
    END IF

    PAUSE PAUSE_MS
LOOP

CLS

END
