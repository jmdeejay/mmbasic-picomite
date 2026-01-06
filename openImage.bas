OPTION EXPLICIT

CONST SCREEN_W = MM.HRES
CONST SCREEN_H = MM.VRES

DIM filename$, ext$, displayname$

filename$ = MM.CMDLINE$
IF filename$ = "" THEN END
CLS
ext$ = GetExt$(filename$)
displayname$ = Basename$(filename$)

SELECT CASE ext$
  CASE "bmp"
    LOAD IMAGE filename$
  CASE "jpeg", "jpg"
    LOAD JPG filename$
  CASE "png"
    LOAD PNG filename$, , , -1
  CASE ELSE
    TEXT SCREEN_W / 2, SCREEN_H / 2, "Unsupported image", "C"
END SELECT

' Print File name
TEXT SCREEN_W / 2, SCREEN_H - (2 * MM.FONTHEIGHT), ClampText$(displayname$, 26), "C", 2, 1, RGB(128, 128, 128), -1

DO WHILE INKEY$ = ""
  PAUSE 100
LOOP

RUN "/menu.bas"
