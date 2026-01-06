OPTION EXPLICIT
OPTION DEFAULT NONE
OPTION CONSOLE SERIAL

DIM gr$(18, 9), rg$(18, 9)
DIM seed$(9)
DIM AS INTEGER col(18,9)
DIM AS INTEGER sudoku(9,9)
DIM AS INTEGER gridH = MM.HRES/12     ' sized to suit different displays
DIM AS INTEGER gridV = MM.VRES/12
DIM AS INTEGER deltaH = gridH* 1.5
DIM AS INTEGER deltaV = 2
DIM AS INTEGER dH = gridH
DIM AS INTEGER dV =  2-gridV/2
DIM AS INTEGER fs = 1                 ' font size
IF MM.HRES > 480 THEN fs = 3          ' use font 3 for high res
DIM AS INTEGER mLen = 48              ' max num of characters in messages.
DIM AS INTEGER x, y, vv, a, b, c, d, ct, co, mf, lf, fl
DIM AS INTEGER o, m, j, tc, v, w
DIM i$, p$
DIM AS INTEGER stopwatch, lc, hint
DIM AS INTEGER normal = 30, hard = 18, easy = 45 ' level of difficulty
  
DIM AS INTEGER preF = RGB(WHITE)      ' colour of prefilled cells
DIM AS INTEGER blank = RGB(CYAN)      ' colour of empty cells
DIM AS INTEGER user = RGB(GREEN)      ' colour of user entry
DIM AS INTEGER computer = RGB(YELLOW) ' colour of computer solution
DIM AS INTEGER grid  = RGB(GRAY)      ' colour of grid
DIM AS INTEGER grid3 = RGB(WHITE)     ' colour of grid
DIM AS INTEGER boxColour(3)           ' colours for hi-lighting cells
boxColour(1) = RGB(GRAY)
boxColour(2) = RGB(RED)
boxColour(3) = RGB(MAGENTA)
  
startHere:
  CLS
  
  lc = 0
  FOR a = 1 TO 18
    FOR b = 1 TO 9
      gr$(a, b) = " "
      rg$(a, b) = ""
      'col(a, b) = blank
    NEXT b
  NEXT a
  drawGrid
  message "1 = Easy, 2 = normal, 3 = hard",9
  message "4 = manual, 9 = rerun, Q = Quit",10
  
  do
    i$ = inkey$
  loop until i$<>""
  select case i$
    case "1"
      x = prefill(easy)
    case "2"
      x = prefill(normal)
    case "3"
      x = prefill(hard)
    case "4"
      ' leave empty
    case "9"
      reload
    case "Q","q"
      cls
end
    case else
      goto startHere
  end select
  FOR a = 1 TO 18
    FOR b = 1 TO 9
      if col(a, b) <> preF then
        col(a, b) = blank
      endif
    NEXT b
  NEXT a
  message "CURSOR =move, 1-9 =number, ENTER =solve", 9
  message "SPACE =clear cell, S =clear grid, H =hint", 10
  
  x = 5: y = 5: vv = 1                ' start in the middle square
cc:
  i$ = "?"' CHR$(2)
  if gr$(x, y) <> " " THEN i$ = gr$(x, y)
  drawdigit x,y, i$
  currentBox(x,y,2)
  i$ = ""
  if hint then
    message validDigits$(x,y),9
  else
    message "H to toggle hints",9
  endif
  message "CURSOR =move, 1-9 =number, ENTER =solve", 10
  do
    i$ = inkey$
  loop until i$<>""
  'print asc(i$)
  DO : LOOP UNTIL INKEY$ = ""
  select case i$
    case "1","2","3","4","5","6","7","8","9" ' is a digit so enter it
      if checkIt(x,y) = 0 then
        gr$(x, y) = i$
        col(x,y) = user
        drawDigit x,y
      else
        flashCell
        
      END IF
    case " " ' space bar - clear cell
      gr$(x, y) = " "
      col(x, y) = blank
      drawDigit x,y
    case "H","h" ' toggle hint
      hint = 1 - hint
    case CHR$(13)  'enter - computer to solve the grid
      message "'Deep Thought' in action",9
      if quickCheck() = 0 then
        message "Unable to solve from here!", 10
        pause 5000
      else
        DO : LOOP UNTIL INKEY$ = ""
        stopwatch = timer
        GOTO solve
      endif
    case CHR$(130) ' left arrow
      if x > 1 THEN
        drawDigit x,y
        x = x - 1
      endif
    case CHR$(131) ' right arrow
      if x < 9 THEN
        drawDigit x,y
        x = x + 1
      ENDIF
    case CHR$(128) ' down arrow
      if y > 1 THEN
        drawDigit x,y
        y = y - 1
      Endif
    case CHR$(129) ' up arrow
      if y < 9 THEN
        drawDigit x,y
        y = y + 1
      endif
    case "Q","q"
      cls
end
    case "s","S"  'Start again
      goto startHere
    case ELSE
      
  END select
  if allFilled() then
    message "It looks like you have done it!!",9
    message "Press any key to go again",10
    do
      i$ = inkey$
    loop until i$<>""
    goto startHere
  endif
  
  GOTO cc
  
sub drawDigit(x as integer, y as integer, q$)' draw cell character or supplied character in q$
  'print x,y
  if q$ = "" then
    text x * gridH+dH, y * gridV+dV,gr$(x, y),CM,2,1,col(x,y)
  else
    text x * gridH+dH, y * gridV+dV,q$,CM,2,1,col(x,y)
  endif
  currentBox(x,y,1)
end sub
  
sub currentBox( x as integer, y as integer,state as integer) ' draw a coloured box around the current cell
  local integer tlX, tlY
  tlX = x * gridH+dH-gridH/2
  tlY = y * gridV+dV-gridV/2
  drawGrid ' redraw full grid to erase any old cell highlighting
  line tlX,tlY,tlX+gridH,tlY,1,boxColour(state)
  line tlX,tlY,tlX,tlY+gridV,1,boxColour(state)
  line tlX,tlY+gridV,tlX+gridH,tlY+gridV,1,boxColour(state)
  line tlX+gridH,tlY,tlX+gridH,tlY+gridV,1,boxColour(state)
end sub
  
sub flashCell ' flash cell outline with invalid entry
  local integer n
  for n = 1 to 5
    currentBox(x,y,3)
    pause 100
    currentBox(x,y,2)
    pause 100
  next n
end sub
  
sub drawGrid
  local integer a
  for a = 0 to 9
    if a mod 3 = 0 then
      line a*gridH+deltaH, deltaV, a*gridH+deltaH, 9*gridV+deltaV,1,grid3
      line deltaH, a*gridV+deltaV, 9*gridH+deltaH, a*gridV+deltaV,1,grid3
    else
      line a*gridH+deltaH, deltaV, a*gridH+deltaH, 9*gridV+deltaV,1,grid
      line deltaH, a*gridV+deltaV, 9*gridH+deltaH, a*gridV+deltaV,1,grid
    endif
  next a
end sub
  
function checkIt(x as integer,y as integer) as integer ' check that cell has valid digit
  local integer a,b,c,d
  checkIt = 0
  a = 1
  do WHILE a < 10
    IF gr$(a, y) = i$ OR gr$(x, a) = i$ THEN
      checkIt = 1
      exit do
    END IF
    a = a + 1
  loop
  if checkIt = 0 then
    a = ((x-1)\3)*3+1
    b = ((y-1)\3)*3+1
    FOR c = a TO a + 2
      FOR d = b TO b + 2
        IF gr$(c, d) = i$ THEN checkIt = 1
      NEXT d
    NEXT c
  endif
end function
  
function validDigits$(x as integer,y as integer)' return all valid digits for current cell
  local integer a,b,c,d,j, NA
  if col(x,y) = preF then ' don't check prefilled cells
    validDigits$ =  "You can't change this cell "
  else
    validDigits$ = "Valid choices are : "
    for j = 49 to 57
      a = 1
      NA = 0
      do WHILE a < 10
        IF gr$(a, y) = chr$(j) OR gr$(x, a) = chr$(j) THEN
          NA = 1
          exit do
        END IF
        a = a + 1
      loop
      if NA = 0 then
        a = ((x-1)\3)*3+1
        b = ((y-1)\3)*3+1
        FOR c = a TO a + 2
          FOR d = b TO b + 2
            IF gr$(c, d) = chr$(j) THEN
              NA = 1
              exit for
            endif
          NEXT d
          if NA = 1 then exit for
        NEXT c
      endif
      if NA = 0 then validDigits$ = validDigits$ + chr$(j)+" "
    next j
  endif
end function
  
solve: ' solve it
  p$ = inkey$
  if p$<>"" then goto startHere
  do
    'print "1"
    lf = 0: o = 49: a = 1: b = 1
    FOR j = 49 TO 57
      
      FOR y = 1 TO 9
        FOR x = 1 TO 9
          IF j = 49 THEN rg$(x, y) = ""
          IF gr$(x, y) <> " " THEN continue for
          i$ = CHR$(j)
          gosub hh
          IF fl = 0 THEN rg$(x, y) = rg$(x, y) + i$
          IF j = 57 AND LEN(rg$(x, y)) = 1 THEN
            gr$(x, y) = rg$(x, y)
            col(x, y) = computer
            drawDigit x,y
            lf = 1
            rg$(x, y) = ""
          END IF
        NEXT x
      NEXT y
    NEXT j
  loop until lf <> 1
pip:
  i$ = CHR$(o)
  'print "2"
  y = 1
  do WHILE y < 10
    
    ct = 0
    FOR x = 1 TO 9
      IF rg$(x, y) = "" THEN continue for
      IF INSTR(1, rg$(x, y), i$) > 0 THEN
        ct = ct + 1
        v = x
      END IF
    NEXT x
    IF ct = 1 THEN
      x = v
      gr$(x, y) = i$
      col(x, y) = computer
      drawDigit x,y
      GOTO solve
    END IF
    y = y + 1
  loop
  x = 1
  do WHILE x < 10
    tc = 0
    FOR y = 1 TO 9
      IF rg$(x, y) = "" THEN continue for
      IF INSTR(1, rg$(x, y), i$) > 0 THEN
        tc = tc + 1
        v = y
      END IF
    NEXT y
    IF tc = 1 THEN
      y = v
      gr$(x, y) = i$
      col(x, y) = computer
      drawDigit x,y
      GOTO solve
    END IF
    x = x + 1
  loop
  do WHILE b < 10
    ct = 0
    FOR c = a TO a + 2
      FOR d = b TO b + 2
        IF rg$(c, d) = "" THEN continue for
        IF INSTR(1, rg$(c, d), i$) > 0 THEN
          ct = ct + 1
          v = c
          w = d
        END IF
      NEXT d
    NEXT c
    IF ct = 1 THEN
      x = v
      y = w
      gr$(x, y) = i$
      col(x,y) = computer
      drawDigit x,y
      GOTO solve
    END IF
    a = a + 3
    IF a > 7 THEN
      a = 1
      b = b + 3
    END IF
  loop
  o = o + 1
  IF o < 58 THEN GOTO pip
  IF vv = 1 THEN
    vv = 2
    j = 0
    m = 9
    GOSUB kl
  END IF
  mf = 0
  co = 0
  FOR y = 1 TO 9
    FOR x = 1 TO 9
      i$ = gr$(x, y)
      IF i$ = " " THEN
        co = 1
        continue for
      END IF
      gr$(x, y) = " "
      if col(x,y) = blank then col(x,y) = computer
      gosub hh 'fl = checkIt(x,y)
      gr$(x, y) = i$
      IF fl = 1 OR (gr$(x, y) = " " AND rg$(x, y) = "") THEN mf = 1
    NEXT x
  NEXT y
  ' print co,mf, lc 'DEBUG
  refreshGrid
  IF co = 0 AND mf = 0 THEN
    print "Done! in "; (timer - stopwatch)/1000;" seconds" 'DEBUG
    message "Completed! in "+str$((timer - stopwatch)/1000,4,1)+" sec",9
    message "Press any key to go again",10
    do
      i$ = inkey$
    loop until i$<>""
    goto startHere
  END IF
  IF mf = 1 THEN
    j = 9
    m = 0
    GOSUB kl
  END IF
  'lc = 0
rb:
  x = INT(RND() * 9) + 1
  y = INT(RND() * 9) + 1
  lc = lc +1
  '  print "3"; 'DEBUG
  
  if lc > 200 then
    '    print "OOPS!" 'DEBUG
    message "Having difficulty!!!",9
    goto solve
  endif
  IF LEN(rg$(x, y)) < 2 THEN GOTO rb
  gr$(x, y) = MID$(rg$(x, y), INT(RND() * LEN(rg$(x, y))) + 1, 1)
  GOTO solve
  
kl:
  FOR y = 1 TO 9
    FOR x = 1 TO 9
      gr$(x + m, y) = gr$(x + j, y)
      if gr$(x,y) = " " then col(x,y) = Blank
      rg$(x + m, y) = rg$(x + j, y)
    NEXT x
  NEXT y
  RETURN
  
hh:
  fl = 0: a = 1
  do WHILE a < 10
    IF gr$(a, y) = i$ OR gr$(x, a) = i$ THEN
      fl = 1
      RETURN
    END IF
    a = a + 1
  loop
  a = ((x-1)\3)*3+1
  b = ((y-1)\3)*3+1
  FOR c = a TO a + 2
    FOR d = b TO b + 2
      IF gr$(c, d) = i$ THEN fl = 1
    NEXT d
  NEXT c
  RETURN
  
sub refreshGrid ' redraw the display to clear out old computer guesses
  local integer x,y
  for x = 1 to 9
    for y = 1 to 9
      drawDigit x,y
    next y
  next x
  drawgrid
end sub
  
function prefill(count as integer) as integer' setup a sudoku with chosen number of cells filled
  local integer x,y,chosen
  for x = 1 to 9
    for y = 1 to 9
      col(x,y) = blank
    next y
  next x
  x = fillgrid()
  do
    x = int(rnd()*9+1)
    y = int(rnd()*9+1)
    if gr$(x,y) = " " then
      gr$(x, y) = str$(sudoku(x,y))
      col(x,y) = preF
      drawDigit x,y
      chosen = chosen + 1
    endif
  loop until chosen >= count
end function
  
sub reload ' start again with the same starting digits as previous run
  local integer x,y
  for x = 1 to 9
    for y = 1 to 9
      if col(x,y) = preF then
        gr$(x, y) = str$(sudoku(x,y))
      else
        gr$(x, y) = " "
        col(x,y) = blank
      endif
      drawDigit x,y
    next y
  next x
end sub
  
function fillgrid() as integer ' fills the grid based on the included digits.
  'Rows and cols can be swapped within their group of 3 while remaining solvable.
  local integer x, y, n, m, k, t, r
  seed$(1) = "329657841"
  seed$(2) = "745831296"
  seed$(3) = "618249375"
  seed$(4) = "193468527"
  seed$(5) = "276195483"
  seed$(6) = "854372619"
  seed$(7) = "432716958"
  seed$(8) = "587923164"
  seed$(9) = "961584732"
  for x = 1 to 9
    for y = 1 to 9
      sudoku(x,y) = val(mid$(seed$(x),y,1))
    next y
  next x
  '  '  print "Seed grid:" 'DEBUG
  '  '  r = printGrid() ' prints the seed grid for testing 'DEBUG
  '  '  print 'DEBUG
  for r = 1 to 2
    for k = 1 to 9 step 3 ' swap rows and columns within the group of 3
      n = int(rnd()*3)
      m = int(rnd()*3)
      if m <> n then
        for y = 1 to 9
          t = sudoku(k+n,y)
          sudoku(k+n,y) = sudoku(k+m,y)
          sudoku(k+m,y) = t
        next y
      endif
      n = int(rnd()*3)
      m = int(rnd()*3)
      if m <> n then
        for x = 1 to 9
          t = sudoku(x,k+n)
          sudoku(x,k+n) = sudoku(x,k+m)
          sudoku(x,k+m) = t
        next x
      endif
    next k
    n = int(rnd()*3) ' swap complete groups of 3 rows and columns
    m = int(rnd()*3)
    if m <> n then
      for y = 1 to 9
        for k = 1 to 3
          t = sudoku(n*3+k,y)
          sudoku(n*3+k,y) = sudoku(m*3+k,y)
          sudoku(m*3+k,y) = t
        next k
      next y
    endif
    n = int(rnd()*3)
    m = int(rnd()*3)
    if m <> n then
      for x = 1 to 9
        for k = 1 to 3
          t = sudoku(x,n*3+k)
          sudoku(x,n*3+k) = sudoku(x,m*3+k)
          sudoku(x,m*3+k) = t
        next k
      next x
    endif
  next r
end function
  
function printGrid() as integer ' prints the grid to console for debug
  local integer x,y
  for x = 1 to 9
    for y = 1 to 9
      print sudoku(x,y);"  ";
    next y
    print
  next x
end function
  
sub message(t$,l as integer)  ' prints a message to line 1 to 10
  local integer m
  if len(t$) < mLen then ' pad the message to make sure we overwrite old message
    m = (mLen - len(t$))/2
    t$ = space$(m)+t$+space$(m)
  endif
  text gridH*6,gridV/2+gridV*l, t$,C,fs,1
end sub
  
function quickCheck() as integer' check for any cells that have no options
  local integer x, y
  quickCheck = 1
  for x = 1 to 9
    for y = 1 to 9
      if gr$(x, y) = " " and validDigits$(x,y) = "Valid choices are : " then
        quickCheck = 0
        exit for
      endif
    next y
    if quickCheck = 0 then exit for
  next x
end function
  
function allFilled() as integer' check for any cells that are empty
  local integer x, y
  allFilled = 1
  for x = 1 to 9
    for y = 1 to 9
      if gr$(x, y) = " " then
        allFilled = 0
        exit for
      endif
    next y
    if allFilled = 0 then exit for
  next x
end function
