OPTION EXPLICIT
OPTION DEFAULT NONE

DIM INTEGER wd, ht, wbox, sh, x, w, n, nn, m
DIM FLOAT a
DIM k$, imgtitle$, fname$
dim integer unlocked ' enable all locked modes
DIM INTEGER c(8)
c(0) = RGB(BLACK)
c(1) = RGB(YELLOW)
c(2) = RGB(CYAN)
c(3) = RGB(GREEN)
c(4) = RGB(MAGENTA)
c(5) = RGB(RED)
c(6) = RGB(BLUE)
c(7) = RGB(WHITE)
c(8) = RGB(64,64,64)

cls

DO
  SELECT CASE m
    CASE 0
      ' do nothing
    CASE 1
      nn = 10
      a = 1 ' aspect ratio used in the CIRCLE command.
      imgtitle$ =" MODE 1,8 Ratio "+str$(a,1,2)+" "
    CASE 2
      if unlocked = 1 then
        nn = 10
        a = 1 ' aspect ratio used in the CIRCLE command.
        imgtitle$ =" MODE 1,12 Ratio "+str$(a,1,2)+" "
      endif
    CASE 3
      if unlocked = 1 then
        nn = 10
        a = 1 ' aspect ratio used in the CIRCLE command.
        imgtitle$ =" MODE 1,16 Ratio "+str$(a,1,2)+" "
      endif
    CASE 4
      nn = 8
      a = 1.08 ' aspect ratio used in the CIRCLE command.
      imgtitle$ =" MODE 2,8 Ratio "+str$(a,1,2)+" "
    CASE 5
      if unlocked = 1 then
        nn = 8
        a = 1.08 ' aspect ratio used in the CIRCLE command.
        imgtitle$ =" MODE 2,12 Ratio "+str$(a,1,2)+" "
      endif
    CASE 6
      nn = 8
      a = 1.08 ' aspect ratio used in the CIRCLE command.
      imgtitle$ =" MODE 2,16 Ratio "+str$(a,1,2)+" "
    CASE 7
      nn = 4
      a = 1.08 ' aspect ratio used in the CIRCLE command.
      imgtitle$ =" MODE 3,8 Ratio "+str$(a,1,2)+" "
    CASE 8
      nn = 4
      a = 1.08 ' aspect ratio used in the CIRCLE command.
      imgtitle$ =" MODE 3,12 Ratio "+str$(a,1,2)+" "
    CASE 9
      nn = 4
      a = 1.08 ' aspect ratio used in the CIRCLE command.
      imgtitle$ =" MODE 3,16 Ratio "+str$(a,1,2)+" "
    CASE 10
      nn = 4
      a = 0.833 ' aspect ratio used in the CIRCLE command.
      imgtitle$ =" MODE 4,8 Ratio "+str$(a,1,3)+" "
    CASE 11
      if unlocked = 1 then
        nn = 4
        a = 0.833 ' aspect ratio used in the CIRCLE command.
        imgtitle$ =" MODE 4,12 Ratio "+str$(a,1,3)+" "
      endif
    CASE 12
      nn = 4
      a = 0.833 ' aspect ratio used in the CIRCLE command.
      imgtitle$ =" MODE 4,16 Ratio "+str$(a,1,3)+" "
    CASE 13
      nn = 4
      a = 0.833 ' aspect ratio used in the CIRCLE command.
      imgtitle$ =" MODE 5,8 Ratio "+str$(a,1,3)+" "
    CASE 14
      nn = 4
      a = 0.833 ' aspect ratio used in the CIRCLE command.
      imgtitle$ =" MODE 5,12 Ratio "+str$(a,1,3)+" "
    CASE 15
      nn = 4
      a = 0.833 ' aspect ratio used in the CIRCLE command.
      imgtitle$ =" MODE 5,16 Ratio "+str$(a,1,3)+" "
  END SELECT
  
  'PRINT imgtitle$ ' for debug
  
  if m = 0 then
    cls
    TEXT 160,100, "Video mode test",cm,1,1
    TEXT 160,180, "Ratio refers to the aspect ratio",cm,1,1
    TEXT 160,195, "used in the circle command",cm,1,1
    TEXT 160,220, "Q to quit, P to save page as a BMP",cm,1,1
    text 160,260, "UP arrow to go back,",cm,1,1
    text 160,275, "any other key to advance",cm,1,1
    text 160,285, "Do you want to test",cm,1,1
    text 160,300, "the UNLOCKED modes? (Y/N)",cm,1,1
  else
    wd = MM.HRES : ht = MM.VRES
    wbox = wd / 8
    FOR x = 0 TO 7
      BOX x*wbox,ht/4,wbox,ht/2,0,c(x), c(x)
    NEXT x
    FOR x = 0 TO wd-1
      sh = 255*x/wd
      
      LINE x,0,x,ht/12,1,RGB(sh,0,0)
      LINE x,ht/12,x,ht/6,1,RGB(0,sh,0)
      LINE x,ht/6,x,ht/4,1,RGB(0,0,sh)
      
      LINE x,ht*9/12,x,ht*10/12,1,RGB(0,sh,sh)
      LINE x,ht*10/12,x,ht*11/12,1,RGB(sh,0,sh)
      LINE x,ht*11/12,x,ht,1,RGB(sh,sh,0)
      
      LINE x,ht/2,x,ht*3/4,1,RGB(sh,sh,sh)
    NEXT x
    CIRCLE wd/2,ht/2, ht*15/32,3,a
    sh = 0
    x = wd/2 - 55*nn/2
    FOR w = 10 TO 1 STEP -1
      FOR n = 1 TO nn
        sh = 255 - sh
        LINE x,ht*3/8,x,ht*5/8,w,RGB(sh,sh,sh)
        x = x + w
      NEXT n
    NEXT w
      
    BOX 0,0,wd,ht,3,c(7)
    BOX 1,1,wd-2,ht-2,1,c(5)
    TEXT wd/2,ht/2, imgtitle$,cm,1,1
  endif
    
  DO
    k$ = INKEY$
  LOOP UNTIL k$<>""
    
  if m = 0 and (k$ = "Y" OR k$ = "y") THEN
    unlocked = 1
  endif
    
  IF k$ = "P" OR k$ = "p" THEN
    fname$ = MID$(imgtitle$,2)+".bmp"
    SAVE IMAGE fname$ 
    TEXT wd/2,ht/2, "Saved as "+fname$,cm,1,1
    DO
      k$ = INKEY$
    LOOP UNTIL k$<>""
  ENDIF
  
  IF k$ = "Q" OR k$ = "q" THEN EXIT DO
  'PRINT ASC(k$)
  IF ASC(k$) = 128 THEN
    m = m - 1
    if unlocked = 0 then ' skip locked modes
      if m = 2 then m = 1
      if m = 3 then m = 1
      if m = 5 then m = 4
      if m = 11 then m = 10
    endif
    IF m < 1 THEN m = 15
  ELSE
    m = m + 1
    if unlocked = 0 then ' skip locked modes
      if m = 2 then m = 4
      if m = 3 then m = 4
      if m = 5 then m = 6
      if m = 11 then m = 12
    endif
    IF m > 15 THEN m = 1
  ENDIF
LOOP

CLS
