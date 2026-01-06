OPTION EXPLICIT

DIM x%, y%, col%
DIM hue!, sat!, val!
DIM halfHeight%

' ====== Functions ======
' Simple HSV->RGB conversion, 0..360 hue, 0..1 sat, 0..1 val
FUNCTION HSVtoRGB(h!, s!, v!)
  LOCAL r!, g!, b!
  LOCAL i!, f!, p!, q!, t!
  
  IF s! = 0 THEN
    r! = v! : g! = v! : b! = v!
    HSVtoRGB = RGB(r!*255, g!*255, b!*255)
  ELSE
    h! = h! / 60
    i! = INT(h!)
    f! = h! - i!
    p! = v! * (1 - s!)
    q! = v! * (1 - s! * f!)
    t! = v! * (1 - s! * (1 - f!))
    
    SELECT CASE i!
      CASE 0 : r! = v! : g! = t! : b! = p!
      CASE 1 : r! = q! : g! = v! : b! = p!
      CASE 2 : r! = p! : g! = v! : b! = t!
      CASE 3 : r! = p! : g! = q! : b! = v!
      CASE 4 : r! = t! : g! = p! : b! = v!
      CASE 5 : r! = v! : g! = p! : b! = q!
    END SELECT
    
    HSVtoRGB = RGB(r!*255, g!*255, b!*255)
  END IF
END FUNCTION


'FRAMEBUFFER CREATE
'FRAMEBUFFER WRITE F
CLS

' ====== Draw horizontal rainbow gradient ======
halfHeight% = MM.HRES \ 2
FOR y% = 0 TO MM.HRES - 1
  IF y% < halfHeight% THEN
    val! = y% / halfHeight%
    sat! = y% / halfHeight%
  ELSE
    val! = 1
    sat! = 1 - ((y% - halfHeight%) / halfHeight%)
  END IF
  
  FOR x% = 0 TO MM.VRES - 1
    hue! = x% * 360 / (MM.VRES - 1)
    col% = HSVtoRGB(hue!, sat!, val!)
    PIXEL x%, y%, col%
  NEXT x%
  'FRAMEBUFFER COPY F, N
NEXT y%

'Save Image "/images/paletteGradient.bmp", 0, 0, MM.HRES - 1, MM.HRES - 1

DO WHILE INKEY$ <> CHR$(27)
  PAUSE 200
LOOP

'FRAMEBUFFER WRITE N
CLS

END
