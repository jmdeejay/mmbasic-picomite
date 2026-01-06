'===========================================================
' PicoMite Rotating 3D Cube
'===========================================================

OPTION EXPLICIT

CONST SCREEN_W = MM.HRES
CONST SCREEN_H = MM.VRES
Const CUBE_SIZE_BASE = 250
Const Z_OFFSET = -4
CONST LINE_W = 1

Dim i As Integer
Dim theta As Float
Dim cR As Integer, cG As Integer, cB As Integer

' Cube vertices
' X coordinates
Dim x3D(7) As Float
x3D(0) = -1 : x3D(1) = 1 : x3D(2) = 1 : x3D(3) = -1
x3D(4) = -1 : x3D(5) = 1 : x3D(6) = 1 : x3D(7) = -1

' Y coordinates
Dim y3D(7) As Float
y3D(0) = -1 : y3D(1) = -1 : y3D(2) = 1 : y3D(3) = 1
y3D(4) = -1 : y3D(5) = -1 : y3D(6) = 1 : y3D(7) = 1

' Z coordinates
Dim z3D(7) As Float
z3D(0) = 1 : z3D(1) = 1 : z3D(2) = 1 : z3D(3) = 1
z3D(4) = -1 : z3D(5) = -1 : z3D(6) = -1 : z3D(7) = -1

' Screen projected points
Dim px(7), py(7)

' Rotation
Dim angle As Float
Dim cubeT As Float
Dim cosA As Float, sinA As Float
Dim cubeSize As Float
Dim xRot As Float, zRot As Float

' Previous frame points
Dim prevPx(7), prevPy(7)

Dim frameCount = 0
Dim fps = 0
Dim lastTime = TIMER - 1000

RANDOMIZE TIMER
CLS

angle = 0
cubeT = 0
theta = 0

DO WHILE INKEY$ <> CHR$(27)
    cubeT = cubeT + 1
    cubeSize = CUBE_SIZE_BASE + SIN(cubeT * 0.03) * 20
    angle = (angle + 1) MOD 360
    cosA = COS(angle * PI / 180)
    sinA = SIN(angle * PI / 180)
    
    ' Project vertices
    FOR i = 0 TO 7
        ' Rotate around Y axis
        xRot = x3D(i) * cosA - z3D(i) * sinA
        zRot = x3D(i) * sinA + z3D(i) * cosA + Z_OFFSET
        
        ' Perspective projection
        px(i) = INT(SCREEN_W/2 + xRot / zRot * cubeSize)
        py(i) = INT(SCREEN_H/2 + y3D(i) / zRot * cubeSize)
    NEXT i

    ' Erase previous cube by drawing lines in background color
    COLOR RGB(BLACK)
    IF cubeT > 0 THEN
        ' Front face
        LINE prevPx(0), prevPy(0), prevPx(1), prevPy(1), LINE_W
        LINE prevPx(1), prevPy(1), prevPx(2), prevPy(2), LINE_W
        LINE prevPx(2), prevPy(2), prevPx(3), prevPy(3), LINE_W
        LINE prevPx(3), prevPy(3), prevPx(0), prevPy(0), LINE_W
        
        ' Back face
        LINE prevPx(4), prevPy(4), prevPx(5), prevPy(5), LINE_W
        LINE prevPx(5), prevPy(5), prevPx(6), prevPy(6), LINE_W
        LINE prevPx(6), prevPy(6), prevPx(7), prevPy(7), LINE_W
        LINE prevPx(7), prevPy(7), prevPx(4), prevPy(4), LINE_W
        
        ' Connect front and back
        LINE prevPx(0), prevPy(0), prevPx(4), prevPy(4), LINE_W
        LINE prevPx(1), prevPy(1), prevPx(5), prevPy(5), LINE_W
        LINE prevPx(2), prevPy(2), prevPx(6), prevPy(6), LINE_W
        LINE prevPx(3), prevPy(3), prevPx(7), prevPy(7), LINE_W
    END IF
    
    ' Store new points in previous frame arrays
    FOR i = 0 TO 7
        prevPx(i) = px(i)
        prevPy(i) = py(i)
    NEXT i

    ' Compute RGB from sine waves
    cR = INT((SIN(theta) + 1) * 127)
    cG = INT((SIN(theta + 2) + 1) * 127)
    cB = INT((SIN(theta + 4) + 1) * 127)
    COLOR RGB(cR, cG, cB)
    theta = theta + 0.1

    ' Draw cube edges
    ' Front face
    LINE px(0), py(0), px(1), py(1), LINE_W
    LINE px(1), py(1), px(2), py(2), LINE_W
    LINE px(2), py(2), px(3), py(3), LINE_W
    LINE px(3), py(3), px(0), py(0), LINE_W
    
    ' Back face
    LINE px(4), py(4), px(5), py(5), LINE_W
    LINE px(5), py(5), px(6), py(6), LINE_W
    LINE px(6), py(6), px(7), py(7), LINE_W
    LINE px(7), py(7), px(4), py(4), LINE_W
    
    ' Connect front and back
    LINE px(0), py(0), px(4), py(4), LINE_W
    LINE px(1), py(1), px(5), py(5), LINE_W
    LINE px(2), py(2), px(6), py(6), LINE_W
    LINE px(3), py(3), px(7), py(7), LINE_W

    ' FPS counter
    frameCount = frameCount + 1
    IF TIMER - lastTime >= 1000 THEN
        fps = frameCount
        frameCount = 0
        lastTime = TIMER
        TEXT SCREEN_W, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
    END IF

    PAUSE 20
LOOP

CLS

END
