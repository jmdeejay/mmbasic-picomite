 DIM col(15)
 col(0) = RGB(BLACK)
 col(1) = RGB(BLUE)
 col(2) = RGB(GREEN)
 col(3) = RGB(CYAN)
 col(4) = RGB(RED)
 col(5) = RGB(MAGENTA)
 col(6) = RGB(150, 75, 0)    ' brown
 col(7) = RGB(192,192,192)   ' dull white
 col(8) = RGB(127,127,127)   ' grey
 col(9) = RGB(173, 216, 230) ' light blue
 col(10) = RGB(173, 216, 230)' light green
 col(11) = RGB(144, 238, 144)' light cyan
 col(12) = RGB(255, 100, 100)' light red
 col(13) = RGB(255, 120, 255)' light magenta
 col(14) = RGB(YELLOW)       ' yellow
 col(15) = RGB(WHITE)        ' bright white

 DIM INTEGER i , n
 DIM FLOAT k,l,j
 
 DO
   CLS
   i = (i + 1) AND &HFFFFF
   k = 6.3 * RND()
   l = 6.3 * RND()
   n = (n + 1) MOD 15
   FOR j = 0 TO 100000
     PIXEL MM.HRES * SIN(.01 * SIN(k) + j), MM.VRES * SIN(.01 * SIN(l) * j), col(n + 1)
   NEXT j
 LOOP UNTIL INKEY$ <>""

 END
