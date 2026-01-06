OPTION EXPLICIT
RANDOMIZE TIMER

DIM k$
DIM rd%, gr%, bl%, loc%

CLS

Box 0, 0, 80, 24,, RGB(white), RGB(white)
Print @(84, 6) "White"
Box 0, 24, 80, 24,, RGB(white), RGB(LIGHTGREY)
Print @(84,30) "Lightgrey"
Box 0, 48, 80, 24,, RGB(white), RGB(grEy)
Print @(84, 54) "Grey"
Box 0, 72, 80, 24,, RGB(white), RGB(black)
Print @(84, 78) "Black"
Box 0, 96, 80, 24,, RGB(white), RGB(beige)
Print @(84, 102) "Beige"
Box 0, 120, 80, 24,, RGB(white), RGB(yellow)
Print @(84, 126) "Yellow"
Box 0, 144, 80, 24,, RGB(white), RGB(gold)
Print @(84, 150) "Gold"
Box 0, 168, 80, 24,, RGB(white), RGB(orange)
Print @(84, 174) "Orange"
Box 0, 192, 80, 24,, RGB(white), RGB(pink)
Print @(84, 198) "Pink"
Box 0, 216, 80, 24,, RGB(white), RGB(brown)
Print @(84,222) "Brown"
Box 0, 240, 80, 24,, RGB(white), RGB(salmon)
Print @(84, 246) "Salmon"
Box 0, 264, 80, 24,, RGB(white), RGB(rust)
Print @(84, 270) "Rust"
Box 0, 288, 80, 24,, RGB(white), RGB(red)
Print @(84, 294)"Red"

Box 160, 0, 80, 24,, RGB(white), RGB(magenta)
Print @(244,6) "Magenta"
Box 160, 24, 80, 24,, RGB(white), RGB(fuchsia)
Print @(244, 30) "Fuchsia"
Box 160, 48, 80, 24,, RGB(white), RGB(lilac)
Print @(244, 54)"Lilac"
Box 160, 72, 80, 24,, RGB(white), RGB(cyan)
Print @(244, 78) "Cyan"
Box 160, 96, 80, 24,, RGB(white), RGB(cerulean)
Print @(244, 102) "Cerulean"
Box 160, 120, 80, 24,, RGB(white), RGB(cobalt)
Print @(244, 126) "Cobalt"
Box 160, 144, 80, 24,, RGB(white), RGB(blue)
Print @(244, 150) "Blue"
Box 160, 168, 80, 24,, RGB(white), RGB(green)
Print @(244, 174) "Green"
Box 160, 192, 80, 24,, RGB(white), RGB(midgreen)
Print @(244, 198) "Midgreen"
Box 160, 216, 80, 24,, RGB(white), RGB(myrtle)
Print @(244, 222) "Myrtle"

rd% = Rnd * 255 : gr% = Rnd * 255 : bl% = Rnd * 255 : loc% = 0
Box 160, 248, 158, 24,, RGB(rd%, gr%, bl%), RGB(rd%, gr%, bl%)

Print @(159, 276) "Rd"
Print @(213, 276) "Gr"
Print @(267, 276) "Bl"
Color RGB(green) : Print @(162, 294) "Arrow keys";
Color RGB(white) : Print " S";
Color RGB(green) : Print " or ESC"

Color RGB(green)
Print @(174, 276); rd%
Print @(228, 276); gr%
Print @(280, 276); bl%

Box 160 + loc% * 20, 288, 46, 3,, RGB(green), RGB(green)

Do
  k$=Inkey$

  If k$ = Chr$(131) And loc% < 2 Then
    Box 160 + loc% * 54, 288, 46, 3,, RGB(black), RGB(black)
    Inc loc%
    Box 160 + loc% * 54, 288, 46, 3,, RGB(green), RGB(green)
  EndIf

  If k$ = Chr$(130) And loc% > 0 Then
    Box 160 + loc% * 54, 288, 46, 3,, RGB(black), RGB(black)
    loc% = loc% - 1
    Box 160 + loc% * 54, 288, 46, 3,, RGB(green), RGB(green)
  EndIf

  If k$ = Chr$(129) Then
    If loc% = 0 And rd% > 0 Then
      rd% = rd% - 2
      If rd% < 0 Then rd% = 0
      Box 160, 248, 158, 24,, RGB(rd%, gr%, bl%), RGB(rd%, gr%, bl%)
      Print @(174, 276); rd%; " "
    EndIf
    If loc% = 1 And gr% > 0 Then
      gr% = gr% - 2
      If gr% < 0 Then gr% = 0
      Box 160, 248, 158, 24,, RGB(rd%, gr%, bl%), RGB(rd%, gr%, bl%)
      Print @(228, 276); gr%; " "
    EndIf
    If loc% = 2 And bl% > 0 Then
      bl% = bl% - 2
      If bl% < 0 Then bl% = 0
      Box 160, 248, 158, 24,, RGB(rd%, gr%, bl%), RGB(rd%, gr%, bl%)
      Print @(280, 276); bl%; " "
    EndIf
  EndIf

  If k$ = Chr$(128) Then
    If loc% = 0 And rd% < 255 Then
      rd% = rd% + 2
      If rd% > 255 Then rd% = 255
      Box 160, 248, 158, 24,, RGB(rd%, gr%, bl%), RGB(rd%, gr%, bl%)
      Print @(174, 276); rd%; " "
    EndIf
    If loc% = 1 And gr% < 255 Then
      gr% = gr% + 2
      If gr% > 255 Then gr% = 255
      Box 160, 248, 158, 24,, RGB(rd%, gr%, bl%), RGB(rd%, gr%, bl%)
      Print @(228, 276); gr%; " "
    EndIf
    If loc% = 2 And bl% < 255 Then
      bl% = bl% + 2
      If bl% > 255 Then bl% = 255
      Box 160, 248, 158, 24,, RGB(rd%, gr%, bl%), RGB(rd%, gr%, bl%)
      Print @(280, 276); bl%; " "
    EndIf
  EndIf

  If k$ = Chr$(115) Then
    Save image "/images/cols.bmp", 0, 0, 319, 319
    Play tone 1000, 2000, 20
    Pause 20
    Play tone 3000, 3000, 20
  EndIf

Loop Until k$ = Chr$(27)

CLS
Run "/menu.bas"
