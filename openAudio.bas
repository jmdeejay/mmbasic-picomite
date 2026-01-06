OPTION EXPLICIT
RANDOMIZE TIMER

CONST SCREEN_W = MM.HRES
CONST SCREEN_H = MM.VRES
CONST MAX_BAR_HEIGHT = SCREEN_H / 3
CONST BAR_WIDTH = 5
CONST BG_COLOR = RGB(0, 0, 0)

CONST TOTAL_MODES = 2
CONST MODE_BAR = 0
CONST MODE_PIXEL = 1

DIM drawMode = INT(RND * TOTAL_MODES)
DIM BAR_SPACING
DIM PADDING
IF drawMode = MODE_BAR THEN
  PADDING = 25
  BAR_SPACING = 10
ELSE IF drawMode = MODE_PIXEL THEN
  PADDING = 20
  BAR_SPACING = 2
ENDIF
DIM NUMBARS = INT((SCREEN_W - (2 * PADDING)) / (BAR_WIDTH + BAR_SPACING))

DIM i, x, y AS INTEGER
DIM filename$, ext$, displayname$, artist$
DIM barHeight!(NUMBARS)
DIM logWeight, barColor, hue, r, g, b
Dim colorOffset = 0

Dim frameCount = 0
Dim fps = 0
Dim lastTime = TIMER - 1000


'-------------------------------------------
' Audio callback when song is done
'-------------------------------------------
SUB AudioDone
  PLAY STOP
  CLS
  
  RUN "/menu.bas"
END SUB


'-------------------------------------------

filename$ = MM.CMDLINE$
IF filename$ = "" THEN END

CLS
ext$ = GetExt$(filename$)
displayname$ = LEFT$(filename$, LEN(filename$) - LEN(ext$) - 1)
displayname$ = Basename$(displayname$)
SplitArtistTitle(displayname$, artist$, displayname$)

SELECT CASE ext$
  CASE "mp3"
    PLAY MP3 filename$, AudioDone
  CASE "wav"
    PLAY WAV filename$, AudioDone
  CASE "mod"
    PLAY MODFILE filename$, AudioDone
  CASE "flac"
    PLAY FLAC filename$, AudioDone
  CASE ELSE
    TEXT SCREEN_W / 2, SCREEN_H / 2, "Unsupported audio format.", "C"
END SELECT

FOR i = 1 TO NUMBARS
  barHeight!(i) = RND * MAX_BAR_HEIGHT
NEXT

' Print song Title, Artist, File type
x = SCREEN_W / 2
y = 0.15 * SCREEN_H
TEXT x, y + MM.FONTHEIGHT, ClampText$(displayname$, 28), "C", 4, 1, RGB(GREEN)
y = 0.75 * SCREEN_H
TEXT x, y + (3 * MM.FONTHEIGHT), "Artist: " + artist$, "C", , 1, RGB(GREEN)
TEXT x, y + (4 * MM.FONTHEIGHT), "File type: " + ext$, "C", , 1, RGB(GREEN)

DO WHILE INKEY$ = ""
  colorOffset = colorOffset + 4
  
  ' Draw middle bar
  IF drawMode = MODE_BAR THEN
    BOX 0, SCREEN_H / 2 - 2, PADDING, 4, , barColor, barColor
    BOX SCREEN_W - PADDING, SCREEN_H / 2 - 2, PADDING, 4, , barColor, barColor
  ELSE IF drawMode = MODE_PIXEL THEN
    FOR i = 0 TO INT(SCREEN_W / (BAR_WIDTH + BAR_SPACING))
      x = i * (BAR_WIDTH + BAR_SPACING)
      y = SCREEN_H / 2
      BOX x, y, 2, 2, , barColor, barColor
    NEXT i
  ENDIF
  
  FOR i = 1 TO NUMBARS
    x = PADDING + (i - 1) * (BAR_WIDTH + BAR_SPACING)
    y = SCREEN_H / 2 - barHeight!(i) / 2
    IF drawMode = MODE_BAR THEN
      RBOX x, y, BAR_WIDTH, barHeight!(i), 3, BG_COLOR, BG_COLOR
    ELSE IF drawMode = MODE_PIXEL THEN
      BOX x + BAR_WIDTH / 2, y, 2, 2, , BG_COLOR, BG_COLOR
      BOX x + BAR_WIDTH / 2, y + barHeight!(i), 2, 2, , BG_COLOR, BG_COLOR
    ENDIF
    
    logWeight = 1 - (LOG(i) / LOG(NUMBARS))
    logWeight = 0.3 + 0.7 * logWeight
    IF logWeight < 0 THEN logWeight = 0
    barHeight!(i) = barHeight!(i) * (0.25 + 0.5 * logWeight) + _
      + (RND * MAX_BAR_HEIGHT * logWeight) * 0.8
    IF barHeight!(i) > MAX_BAR_HEIGHT THEN barHeight!(i) = MAX_BAR_HEIGHT
    
    ' rainbow color
    hue = (i * 360 / NUMBARS + colorOffset) MOD 360
    r = ABS(255 * COS(hue * PI / 180))
    g = ABS(255 * COS((hue + 120) * PI / 180))
    b = ABS(255 * COS((hue + 240) * PI / 180))
    barColor = RGB(r, g, b)
    
    ' Draw middle bar
    IF drawMode = MODE_BAR THEN
      BOX x, SCREEN_H / 2 - 2, BAR_WIDTH + BAR_SPACING, 4, , barColor, barColor
    ENDIF
    
    y = SCREEN_H / 2 - barHeight!(i) / 2
    IF drawMode = MODE_BAR THEN
      RBOX x, y, BAR_WIDTH, barHeight!(i), 3, barColor, barColor
    ELSE IF drawMode = MODE_PIXEL THEN
      BOX x + BAR_WIDTH / 2, y, 2, 2, , barColor, barColor
      BOX x + BAR_WIDTH / 2, y + barHeight!(i), 2, 2, , barColor, barColor
    ENDIF
  NEXT
    
  ' FPS counter
  frameCount = frameCount + 1
  IF TIMER - lastTime >= 1000 THEN
    fps = frameCount
    frameCount = 0
    lastTime = TIMER
    ' TEXT SCREEN_W, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
  END IF
LOOP

AudioDone()
