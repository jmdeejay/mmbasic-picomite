'========================================
' Mandelbrot (Pre-Computed Fast Version)
'========================================

Option Explicit

CONST SCREEN_W = MM.HRES
CONST SCREEN_H = MM.VRES

Const X_MIN = -2.0
Const X_MAX = 1.0
Const Y_MIN = -1.5
Const Y_MAX = 1.5
Const MAX_ITER = 16
Const ESC2 = 4

Const SCALE_X = (X_MAX - X_MIN) / SCREEN_W
Const SCALE_Y = (Y_MAX - Y_MIN) / SCREEN_H

Const IMG_FILE = "/images/mandelbrot.bmp"

' Check if cached image exists
IF MM.INFO(exists file IMG_FILE) THEN
  LOAD IMAGE IMG_FILE
ELSE

  CLS
  Text SCREEN_W / 2, SCREEN_H - (2 * MM.FONTHEIGHT), "Calculating Mandelbrot...", "C"
  
  '-----------------------------------------------------------
  ' Precompute color table: blue -> orange -> red -> white
  '-----------------------------------------------------------
  Dim colorTable%(MAX_ITER)
  
  Sub BuildColorTable
    Local i As Integer
    Local r As Integer, g As Integer, b As Integer
    Local ratio As Float
    
    For i = 0 To MAX_ITER
      If i = MAX_ITER Then
        colorTable%(i) = RGB(BLACK)
      Else
        ratio = i / MAX_ITER
        If ratio < 0.33 Then
          ' Blue → Orange
          r = (ratio / 0.33) * 255
          g = (ratio / 0.33) * 128
          b = 255 - (ratio / 0.33 * 255)
        ElseIf ratio < 0.66 Then
          ' Orange → Red
          r = 255
          g = 128 - ((ratio - 0.33) / 0.33 * 128)
          b = 0
        Else
          ' Red → White
          r = 255
          g = ((ratio - 0.66) / 0.34) * 255
          b = ((ratio - 0.66) / 0.34) * 255
        End If
        
        colorTable%(i) = RGB(r, g, b)
      End If
    Next i
  End Sub

  BuildColorTable

  '-----------------------------------------------------------
  ' Mandelbrot computation and drawing
  '-----------------------------------------------------------
  Dim zx As Float, zy As Float, zxTemp As Float, zyTemp As Float
  Dim cx As Float, cy As Float
  Dim iter As Integer
  Dim pixelX As Integer, pixelY As Integer
  Dim rowBuffer%(SCREEN_W - 1)  ' buffer only one row
  
  For pixelY = 0 To SCREEN_H - 1
    cy = Y_MIN + pixelY * SCALE_Y
    
    For pixelX = 0 To SCREEN_W - 1
      cx = X_MIN + pixelX * SCALE_X
      zx = 0
      zy = 0
      iter = 0
      
      Do While (zx * zx + zy * zy <= ESC2) And (iter < MAX_ITER)
        zxTemp = zx * zx - zy * zy + cx
        zyTemp = 2 * zx * zy + cy
        zx = zxTemp
        zy = zyTemp
        iter = iter + 1
        
        If zx * zx > ESC2 Or zy * zy > ESC2 Then Exit Do
      Loop
      rowBuffer%(pixelX) = iter
    Next pixelX
    
    For pixelX = 0 To SCREEN_W - 1
      Color colorTable%(rowBuffer%(pixelX))
      Pixel pixelX, pixelY
    Next pixelX
  Next pixelY

  '-----------------------------------------------------------
  ' Final rendering of image
  '-----------------------------------------------------------
  Save Image IMG_FILE, 0, 0, SCREEN_W - 1, SCREEN_H - 1
END IF

DO WHILE INKEY$ <> CHR$(27)
  Pause 100
Loop

CLS

END
