OPTION EXPLICIT

CONST GRID_X = 30            ' number of columns
CONST GRID_Z = 40            ' number of rows
CONST TERRAIN_HEIGHT = 12    ' max amplitude of terrain
CONST CAMERA_Z = 12          ' camera distance
CONST SCALE_X = 14           ' horizontal scale multiplier
CONST FOV_Y = MM.VRES / 2    ' vertical scale
CONST CCYAN = RGB(0, 220, 255)
CONST CPINK = RGB(240, 0, 255)
CONST CPURPLE = RGB(60, 0, 100)
CONST COLOR_BACKGROUND = CPURPLE
CONST COLOR_GRID = CPINK

CONST SCREEN_CX = MM.HRES / 2
CONST SCREEN_CY = MM.VRES / 3

DIM x, z
DIM xr, zr
DIM scale
DIM cosA, sinA, angle

DIM sx(GRID_X, GRID_Z), sy(GRID_X, GRID_Z)
DIM prev_sx(GRID_X, GRID_Z), prev_sy(GRID_X, GRID_Z)
DIM visible(GRID_X, GRID_Z)
DIM prev_visible(GRID_X, GRID_Z)
DIM height(GRID_X, GRID_Z)

Dim frameCount = 0
Dim fps = 0
Dim lastTime = TIMER - 1000

angle = 35.0
cosA = COS(angle * PI / 180)
sinA = SIN(angle * PI / 180)
  
' Initialize a wavy terrain
FOR x = 0 TO GRID_X - 1
  FOR z = 0 TO GRID_Z - 1
    height(x, z) = INT((SIN(x / 3) + COS(z / 4)) * (TERRAIN_HEIGHT / 2))
  NEXT z
NEXT x
  
CLS COLOR_BACKGROUND
  
DO WHILE INKEY$ <> CHR$(27)
  ' Project grid points
  FOR z = 0 TO GRID_Z - 1
    FOR x = 0 TO GRID_X - 1
      xr = (x - GRID_X / 2) * cosA - (z - GRID_Z / 2) * sinA
      zr = (x - GRID_X / 2) * sinA + (z - GRID_Z / 2) * cosA
        
      IF zr <= -CAMERA_Z THEN
        visible(x, z) = 0
      ELSE
        visible(x, z) = 1
        scale = CAMERA_Z / (zr + CAMERA_Z + 1)
        sx(x, z) = SCREEN_CX + xr * scale * SCALE_X
        sy(x, z) = SCREEN_CY - height(x, z) * scale * (FOV_Y / TERRAIN_HEIGHT)
      END IF
    NEXT x
  NEXT z
  
  ' Draw wireframe: lines along x-axis and z-axis
  FOR z = 0 TO GRID_Z - 2
    FOR x = 0 TO GRID_X - 2
      ' Erase previous frame
      COLOR COLOR_BACKGROUND
      IF prev_visible(x, z) AND prev_visible(x + 1, z) THEN
        LINE prev_sx(x, z), prev_sy(x, z), prev_sx(x + 1, z), prev_sy(x + 1, z)
      END IF
      IF prev_visible(x, z) AND prev_visible(x, z + 1) THEN
        LINE prev_sx(x, z), prev_sy(x, z), prev_sx(x, z + 1), prev_sy(x, z + 1)
      END IF
        
      COLOR COLOR_GRID
      IF visible(x, z) AND visible(x + 1, z) THEN
        LINE sx(x, z), sy(x, z), sx(x + 1, z), sy(x + 1, z)
      END IF
      IF visible(x, z) AND visible(x, z + 1) THEN
        LINE sx(x, z), sy(x, z), sx(x, z + 1), sy(x, z + 1)
      ENDIF
        
      ' Store previous frame
      prev_sx(x, z) = sx(x, z)
      prev_sy(x, z) = sy(x, z)
      prev_visible(x, z) = visible(x, z)
    NEXT x
  NEXT z
    
  ' Animate terrain: scroll toward camera / change heights
  FOR x = 0 TO GRID_X - 1
    FOR z = GRID_Z - 1 TO 1 STEP -1
      height(x, z) = height(x, z - 1)
    NEXT z
    height(x, 0) = INT((SIN(TIMER / 8 + x / 2.0) + RND() * 0.5) * TERRAIN_HEIGHT / 2)
  NEXT x
    
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
