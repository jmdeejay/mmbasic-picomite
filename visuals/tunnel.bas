OPTION EXPLICIT

CONST SCREEN_CX = MM.HRES / 2
CONST SCREEN_CY = MM.VRES / 2

' Tunnel parameters
CONST NUM_RINGS = 8
CONST NUM_SPOKES = 16
CONST RADIUS = 20
CONST SPEED = 2         ' forward speed per frame
CONST TURN_X = 0.5      ' left/right turn
CONST TURN_Y = 0.2      ' up/down tilt

DIM FLOAT ringX(NUM_RINGS, NUM_SPOKES)
DIM FLOAT ringY(NUM_RINGS, NUM_SPOKES)
DIM FLOAT ringZ(NUM_RINGS)
DIM INTEGER prevX(NUM_RINGS, NUM_SPOKES)
DIM INTEGER prevY(NUM_RINGS, NUM_SPOKES)

DIM FLOAT camX = 0
DIM FLOAT camY = 0

DIM frameCount = 0
DIM fps = 0
DIM lastTime = TIMER - 1000

' Precompute tunnel rings
SUB PrecomputeTunnel
    LOCAL i, j, theta
    FOR i = 1 TO NUM_RINGS
        ringZ(i) = i * 10
        FOR j = 1 TO NUM_SPOKES
            theta = (j - 1) * 2 * PI / NUM_SPOKES
            ringX(i, j) = COS(theta) * RADIUS
            ringY(i, j) = SIN(theta) * RADIUS
        NEXT j
    NEXT i
END SUB

SUB DrawTunnel
    LOCAL i, j, nextJ
    LOCAL x3d, y3d, z3d
    LOCAL xProj, yProj

    ' --- erase previous frame ---
    FOR i = 1 TO NUM_RINGS
        FOR j = 1 TO NUM_SPOKES
            nextJ = j + 1
            IF nextJ > NUM_SPOKES THEN nextJ = 1
            ' erase ring lines
            LINE prevX(i, j), prevY(i, j), prevX(i, nextJ), prevY(i, nextJ), , RGB(BLACK)
            ' erase spoke lines
            IF i < NUM_RINGS THEN
                LINE prevX(i, j), prevY(i, j), prevX(i + 1, j), prevY(i + 1, j), , RGB(BLACK)
            END IF
        NEXT j
    NEXT i

    ' --- compute new positions ---
    FOR i = 1 TO NUM_RINGS
        FOR j = 1 TO NUM_SPOKES
            z3d = ringZ(i) - SPEED * frameCount
            x3d = ringX(i, j) + camX
            y3d = ringY(i, j) + camY

            ' loop tunnel
            IF z3d < 1 THEN z3d = z3d + NUM_RINGS * 10

            ' project to screen
            xProj = INT(x3d * 200 / z3d + SCREEN_CX)
            yProj = INT(y3d * 200 / z3d + SCREEN_CY)

            prevX(i, j) = xProj
            prevY(i, j) = yProj
        NEXT j
    NEXT i

    ' --- draw new wireframe ---
    FOR i = 1 TO NUM_RINGS
        FOR j = 1 TO NUM_SPOKES
            nextJ = j + 1
            IF nextJ > NUM_SPOKES THEN nextJ = 1
            LINE prevX(i, j), prevY(i, j), prevX(i, nextJ), prevY(i, nextJ), , RGB(WHITE)
            IF i < NUM_RINGS THEN
                LINE prevX(i, j), prevY(i, j), prevX(i + 1, j), prevY(i + 1, j), , RGB(WHITE)
            END IF
        NEXT j
    NEXT i
END SUB

CLS
PrecomputeTunnel()

DO WHILE INKEY$ <> CHR$(27)
    ' update camera offsets for turning
    camX = camX + TURN_X * SIN(frameCount / 10)
    camY = camY + TURN_Y * COS(frameCount / 15)

    DrawTunnel()

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