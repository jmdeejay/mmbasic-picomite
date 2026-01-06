' OPTION EXPLICIT
RANDOMIZE TIMER

Data 4, 0, -20, 10, 10, 0, 0, -10, 10
Data 3, -5, 5, 0, 8, 5, 5
Data 2, 0, 0, 0, -5
Data 15, -1, 0, -0.8, -0.6, -0.4, -0.5, 0, -1
Data 0.5, -0.9, 0.3, -0.4, 0.8, -0.5, 1, 0
Data 0.7, 0.4, 0.7, 0.6, 0.3, 0.8, 0, 0.7
Data -0.3, 0.9, -0.7, 0.8, -0.7, 0.5

CONST SCREEN_W = MM.HRES
CONST SCREEN_H = MM.VRES
CONST CHAR_W   = MM.FONTWIDTH
CONST CHAR_H   = MM.FONTHEIGHT

CONST KEY_RETURN$ = CHR$(13)
CONST KEY_ESC$    = CHR$(27)
CONST KEY_UP$     = CHR$(128)
CONST KEY_DOWN$   = CHR$(129)
CONST KEY_LEFT$   = CHR$(130)
CONST KEY_RIGHT$  = CHR$(131)

FRAMEBUFFER create
FRAMEBUFFER write f

Dim rot(3, 3)

Sub load_vector(l())
  For i = 0 To Bound(l()) - 1
    Read l(i, 0)
    Read l(i, 1)
    l(i, 2) = 1
  Next
End Sub

Read c
Dim ship(c, 3)
load_vector(ship())

Read c
Dim thrust(c, 3)
load_vector(thrust())

Read c
Dim shot(c, 3)
load_vector(shot())

Read c
Dim asteroid(c, 3)
load_vector(asteroid())

posx = SCREEN_W / 2
posy = SCREEN_H / 2
velx = 0
vely = 0
angle = 0
invuln = 30
lives = 3
accel = 0.3
fspeed = 10 'shot speed
rspeed = 1 'rocks speed
score = 0
cooldown = 0

Dim rocks(16, 6) 'x, y, velx, vely, ang, size

Sub new_rock(x, y, ang, size)
  For n = 0 To Bound(rocks()) - 1
    If rocks(n, 5) = 0 Then
      rocks(n, 5) = size
      rocks(n, 4) = ang
      rocks(n, 2) = Sin(rocks(n, 4)) * rspeed
      rocks(n, 3) = -Cos(rocks(n, 4)) * rspeed
      rocks(n, 0) = x + rocks(n, 2)
      rocks(n, 1) = y + rocks(n, 3)
      Exit Sub
    EndIf
  Next
End Sub

For i = 0 To 3
  new_rock(Rnd() * SCREEN_W, Rnd() * SCREEN_H, Rnd * 6, 30)
Next

Dim shots(5, 6) 'xy, vel, ang, active

Sub fire()
  If cooldown > 0 Then Exit Sub
  For n = 0 To Bound(shots())
    If shots(n, 5) = 0 Then
      shots(n, 0) = posx
      shots(n, 1) = posy
      shots(n, 2) = Sin(angle) * fspeed
      shots(n, 3) = -Cos(angle) * fspeed
      shots(n, 4) = angle
      shots(n, 5) = 1
      cooldown = 5
      Exit Sub
    EndIf
  Next
End Sub

Sub player_hit()
  If lives > 0 Then
    posx = SCREEN_W / 2
    posy = SCREEN_H / 2
    velx = 0
    vely = 0
    angle = 0
    invuln = 30
    lives = lives - 1
  Else
    FRAMEBUFFER write n
    Print "Game Over!"
    Print "Final score: ", score
    Pause 2000
    CLS
    End
  EndIf
End Sub

Sub draw(lines(), x, y, ang, scale, op)
  cnt = Bound(lines())
  sina = Sin(ang) * scale
  cosa = Cos(ang) * scale
  rot(0, 0) = cosa
  rot(1, 0) = -sina
  rot(0, 1) = sina
  rot(1, 1) = cosa
  rot(2, 0) = x
  rot(2, 1) = y
  rot(2, 2) = 1
  Dim rout(cnt, 3)
  Math m_mult rot(), lines(), rout()

  For i = 0 To cnt - 2
    Line rout(i, 0), rout(i, 1), rout(i + 1, 0), rout(i + 1, 1)
  Next
  If op = 0 Then Line rout(cnt - 1, 0), rout(cnt - 1, 1), rout(0, 0), rout(0, 1)

  Erase rout
End Sub

Function dist(x1, y1, x2, y2)
  dist = Sqr((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
End Function

Do
  CLS

  Do
    k$ = Inkey$
    If k$ = KEY_UP$ Then
      draw(thrust(), posx, posy, angle, 0.5, 1)
      velx = velx + Sin(angle) * accel
      vely = vely - Cos(angle) * accel
    ElseIf k$ = KEY_DOWN$ Then
      velx = velx - Sgn(velx) * accel
      vely = vely - Sgn(vely) * accel
    ElseIf k$ = KEY_LEFT$ Then
      angle = angle - 0.3
    ElseIf k$ = KEY_RIGHT$ Then
      angle = angle + 0.3
    ElseIf k$ = KEY_RETURN$ Then
      fire()
    ElseIf k$ = KEY_ESC$ Then
      End
    EndIf
  Loop Until k$ = ""

  posx = (posx + velx + SCREEN_W) Mod SCREEN_W
  posy = (posy + vely + SCREEN_H) Mod SCREEN_H

  If cooldown > 0 Then cooldown = cooldown - 1
  If invuln > 0 Then invuln = invuln - 1
  If invuln Mod 2 = 0 Then draw(ship(), posx, posy, angle, 0.5)

  For n = 0 To Bound(shots()) - 1
    'if shot is active, process
    If shots(n, 5) = 1 Then
      shots(n, 0) = shots(n, 0) + shots(n, 2)
      shots(n, 1) = shots(n, 1) + shots(n, 3)
      If shots(n,0) < 0 Or shots(n,0) > SCREEN_W Or shots(n,1) < 0 Or shots(n,1) > SCREEN_H Then
        shots(n,5) = 0
      Else
        draw(shot(), shots(n,0), shots(n,1), shots(n,4), 1, 1)
      EndIf
    EndIf
  Next

  remain = 0
  For n = 0 To Bound(rocks())-1
    If rocks(n, 5) > 0 Then
      remain = remain + 1
      rocks(n, 0) = (rocks(n, 0) + rocks(n, 2) + SCREEN_W) Mod SCREEN_W
      rocks(n, 1) = (rocks(n, 1) + rocks(n, 3) + SCREEN_H) Mod SCREEN_H

      rx = rocks(n, 0)
      ry = rocks(n, 1)

      If invuln = 0 And dist(posx, posy, rx, ry) < rocks(n, 5) + 5 Then
        player_hit()
      EndIf

      For m = 0 To Bound(shots()) - 1
        If shots(m, 5) = 1 Then
          If dist(shots(m, 0), shots(m, 1), rx, ry) < rocks(n, 5) Then
            'shot a rock
            shots(m, 5) = 0
            sz = rocks(n, 5) - 10
            score = score + rocks(n, 5)
            rocks(n, 5 )= 0
            ang = Rnd() * 6
            rspeed = rspeed + 0.1
            new_rock(rx, ry, ang, sz)
            new_rock(rx, ry, ang + 1.5, sz)
          EndIf
        EndIf
      Next

      draw(asteroid(), rocks(n, 0), rocks(n, 1), rocks(n, 4), rocks(n, 5))
    EndIf
  Next

  If remain = 0 Then
    'cleared all rocks, next level
    score = score + 500
    invuln = 30
    rspeed = rspeed - 1

    For i = 0 To 3
      new_rock(Rnd() * SCREEN_W, Rnd() * SCREEN_H, Rnd * 6, 30)
    Next
  EndIf

  For n = 1 To lives
    lx = SCREEN_W - n * 15
    draw(ship(), lx, 15, 0, 0.5)
  Next

  Print score

  FRAMEBUFFER copy f, n
Loop

CLS
