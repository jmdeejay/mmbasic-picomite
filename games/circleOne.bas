Option Base 0
Option Default Float
Option Explicit On

Const VERSION = 101302 ' 1.1.2

Dim sys.break_flag%

' Formats an integer version as a string.
'
' @param  v%   version number: AABBCDD
'              - AA is the 2-digit major version.
'              - BB is the 2-digit minor version.
'              - C  = 0 for alpha
'                   = 1 for beta
'                   = 2 for release candidate
'                   = 3..9 for release.
'              - DD is the micro version if c <= 3.
'                If c > 3 Then CDD - 300 is the micro version.
Function sys.format_version$(v%)
  Const v_% = Choice(v%, v%, sys.VERSION)
  Local s$ = Str$(v_%\10^5) + "." + Str$((v_% Mod 10^5) \ 10^3)
  Select Case v_% Mod 1000
    Case < 100 : Cat s$, " alpha " + Str$(v_% Mod 1000)
    Case < 200 : Cat s$, " beta " + Str$((v_% Mod 1000) - 100)
    Case < 300 : Cat s$, " RC " + Str$((v_% Mod 1000) - 200)
    Case Else  : Cat s$, "." + Str$((v_% Mod 1000) - 300)
  End Select
  sys.format_version$ = s$
End Function

' Overrides Ctrl-C behaviour such that:
'   - Ctrl-C will call sys.break_handler()
'   - Ctrl-D will perform an actual MMBasic break
Sub sys.override_break(callback$)
  sys.break_flag% = 0
  Option Break 4
  If Len(callback$) Then
    Execute "On Key 3, " + callback$ + "()"
  Else
    On Key 3, sys.break_handler()
  EndIf
End Sub

' Called as an ON KEY interrupt when Ctrl-C is overridden by sys.override_break().
' Increments the sys.break_flag%, if the flag is then > 1 then END the program.
Sub sys.break_handler()
  Inc sys.break_flag%
  If sys.break_flag% > 1 Then
    sys.restore_break()
    End
  EndIf
End Sub

' Restores default Ctrl-C behaviour.
Sub sys.restore_break()
  sys.break_flag% = 0
  On Key 3, 0
  Option Break 3
End Sub

Const ctrl.UI_DELAY = 200 ' 200 micro-seconds.

' Button values as returned by controller driver subroutines.
Const ctrl.R      = &h01
Const ctrl.START  = &h02
Const ctrl.HOME   = &h04
Const ctrl.SELECT = &h08
Const ctrl.L      = &h10
Const ctrl.DOWN   = &h20
Const ctrl.RIGHT  = &h40
Const ctrl.UP     = &h80
Const ctrl.LEFT   = &h100
Const ctrl.ZR     = &h200
Const ctrl.X      = &h400
Const ctrl.A      = &h800
Const ctrl.Y      = &h1000
Const ctrl.B      = &h2000
Const ctrl.ZL     = &h4000

' When a key is down the corresponding byte of this 256-byte map is set,
' when the key is up then it is unset.
'
' Note that when using INKEY$ (as opposed to the CMM2 'KEYDOWN' function or
' the PicoMiteVGA 'ON PS2' command) to read the keyboard we cannot detect
' keyup events and instead automatically clear a byte after it is read.
Dim ctrl.key_map%(31 + Mm.Info(Option Base))

' Gets a default controller driver based on the current platform.
Function ctrl.default_driver$()
  ctrl.default_driver$ = "keys_cursor_ext"
End Function

' Initialises keyboard reading.
'
' @param  use_inkey%  Use INKEY$ even on platforms with KEYDOWN or ON PS2.
' @param  period%     CMM2 only, interval to read KEYDOWN state, default 40 ms.
' @param  nbr%        CMM2 only, timer nbr to read KEYDOWN state, default 4.
Sub ctrl.init_keys(use_inkey%, period%, nbr%)
  ctrl.term_keys()
  On Key ctrl.on_key()
End Sub

' TODO: use the 'lower-case' character for all keys, not just letters.
Sub ctrl.on_key()
  Poke Var ctrl.key_map%(), Asc(LCase$(Inkey$)), 1
End Sub

' Terminates keyboard reading.
Sub ctrl.term_keys()
  On Key 0
  Memory Set Peek(VarAddr ctrl.key_map%()), 0, 256
  Do While Inkey$ <> "" : Loop
End Sub

Function ctrl.keydown%(i%)
  ctrl.keydown% = Peek(Var ctrl.key_map%(), i%)
  Poke Var ctrl.key_map%(), i%, 0
End Function

Sub keys_cursor_ext(x%)
  If x% < 0 Then Exit Sub
  x% = (ctrl.keydown%(32) Or ctrl.keydown%(120)) * ctrl.A ' Space or X
  Inc x%, ctrl.keydown%(122) * ctrl.B ' Z
  Inc x%, (ctrl.keydown%(&hA) Or ctrl.keydown%(97))  * ctrl.SELECT ' Enter or A
  Inc x%, ctrl.keydown%(115) * ctrl.START ' S
  Inc x%, ctrl.keydown%(128) * ctrl.UP
  Inc x%, ctrl.keydown%(129) * ctrl.DOWN
  Inc x%, ctrl.keydown%(130) * ctrl.LEFT
  Inc x%, ctrl.keydown%(131) * ctrl.RIGHT
  Inc x%, ctrl.keydown%(27)  * ctrl.HOME ' Escape
End Sub

' Common code for cleaning up and returning to any shell program after a game
' ends. Note that it is possible that much of this is (now) unnecessary due to
' improvements in how MMBasic handles the cleanup itself on calling END or RUN.
'
' @param  break%  If 0 then this is a "normal" end, if 1 then it is the result
'                 of Ctrl-C. In the current version of this subroutine this
'                 does not have an effect on behaviour.
Sub game.end(break%)
  FrameBuffer Write N
  FrameBuffer Close
  Colour Rgb(White), Rgb(Black)
  If Mm.HRes = 320 Then Font 7 Else Font 1
  Cls

  sys.restore_break()

  ' Use ON ERROR SKIP because we might not be using these libraries.
  On Error Skip : sound.term()
  On Error Skip : ctrl.term()

  SetTick 0,0,1 : SetTick 0,0,2 : SetTick 0,0,3 : SetTick 0,0,4
  Play Stop

  ' For the moment always return to shell/menu if available.
  break% = 0

  Local msg$
  If break% Then
    msg$ = "Exited due to Ctrl-C"
  ElseIf InStr(Mm.CmdLine$, "--shell") Then
    msg$ = "Loading menu ..."
  EndIf

  If msg$ <> "" Then
    Text Mm.HRes / 2, Mm.VRes / 2, msg$, CM
  EndIf

  ' TODO: twm.term() should subsume twm.free() and also do this.
  On Error Skip : twm.enable_cursor(1)

  If Not break% And InStr(Mm.CmdLine$, "--shell") Then sys.run_shell()
  End
End Sub

Sub game.on_break()
  game.end(1)
End Sub

Const msgbox.NO_PAGES = &h01
Dim msgbox.buffer% = 64

Function msgbox.show%(x%, y%, w%, h%, msg$, buttons$(), default%, ctrl$, fg%, bg%, frame%, flags%)
  Const base% = Mm.Info(Option Base), num% = Bound(buttons$(), 1) - base% + 1
  Local i%, btn_x%(num%), p% = 1
  btn_x%(base%) = x% + 2
  For i% = base% + 1 To base% + num% - 1
    btn_x%(i%) = btn_x%(i% - 1) + Len(buttons$(i% - 1)) + 5
  Next

  ' Backup display.
  Const fh% = Mm.Info(FontHeight), fw% = Mm.Info(FontWidth)
  Blit Read msgbox.buffer%, x% * fw%, y% * fh%, w% * fw%, h% * fh%

  msgbox.box(x%, y%, w%, h%, 1, Choice(frame% = -1, fg%, frame%), bg%)
  i% = y% + 2
  Do While p% <= Len(msg$)
    msgbox.print_at(x% + 2, i%, str.wwrap$(msg$, p%, w% - 4), fg%, bg%)
    Inc i%
  Loop

  Local key%, released%, valid% = 1
  msgbox.show% = default%
  Do
    If sys.break_flag% Then msgbox.show% = default% : Exit Function
    If valid% Then
      For i% = base% To base% + num% - 1
        msgbox.button(btn_x%(i%), y% + h% - 4, buttons$(i%), i% = msgbox.show%, fg%, bg%)
      Next
      If Not flags% And msgbox.NO_PAGES Then
        FrameBuffer Copy F, N
      EndIf
      valid% = 0
    EndIf
    Call ctrl$, key%
    If Not key% Then keys_cursor_ext(key%)
    If Not key% Then released% = 1 : Continue Do
    If Not released% Then key% = 0 : Continue Do
    valid% = 0
    Select Case key%
      Case ctrl.A, ctrl.SELECT
        key% = ctrl.SELECT
        valid% = 1
      Case ctrl.LEFT
        If msgbox.show% > 0 Then Inc msgbox.show%, -1 : valid% =1
      Case ctrl.RIGHT
        If msgbox.show% < num% - 1 Then Inc msgbox.show% : valid% =1
    End Select
    msgbox.beep(valid%)
    Pause ctrl.UI_DELAY - 100
  Loop Until key% = ctrl.SELECT

  ' Restore display.
  Blit Write msgbox.buffer%, x% * fw%, y% * fh%
  Blit Close msgbox.buffer%
  If Not flags% And msgbox.NO_PAGES Then
    FrameBuffer Copy F, N
  EndIf
End Function

Sub msgbox.button(x%, y%, txt$, selected%, fg%, bg%)
  msgbox.box(x%, y%, Len(txt$) + 4, 3, 0, fg%, -1)
  Const fg_% = Choice(selected%, bg%, fg%)
  Const bg_% = Choice(selected%, fg%, bg%)
  msgbox.print_at(x% + 2, y% + 1, txt$, fg_%, bg_%)
End Sub

Sub msgbox.box(x%, y%, w%, h%, dbl%, fg%, bg%)
  Const fh% = Mm.Info(FontHeight), fw% = Mm.Info(FontWidth)
  Local d% = fw% \ 2
  If bg% >= 0 Then Box x% * fw%, y% * fh%, w% * fw%, h% * fh%, , bg%, bg%
  Box x% * fw% + d%, y% * fh% + d%, w% * fw% - 2 * d%, h% * fh% - 2 * d%, 1, fg%
  Inc d%, d%
  If dbl% Then Box x% * fw% + d%, y% * fh% + d%, w% * fw% - 2 * d%, h% * fh% - 2 * d%, 1, fg%
End Sub

Sub msgbox.print_at(x%, y%, s$, fg%, bg%)
  Text x% * Mm.Info(FontWidth), y% * Mm.Info(FontHeight), s$, , , , fg%, bg%
End Sub

Sub msgbox.beep(valid%)
  ' These are the same frequencies as for the sound.BLART and sound.SELECT effects.
  If valid% Then
    ' Local notes!(3) = (493.88, 783.99, 987.77, 0.0) ' B4,G5,B5,-
    Local notes!(3) = (987.77, 1567.98, 1975.53, 30.87) ' B5,G6,B6,-
  Else
    ' Local notes!(3) = (523.25, 493.88, 369.99, 349.23) ' C5,B4,F#4,F4
    Local notes!(4) = (1046.50, 987.77, 739.99, 698.46, 30.87) ' C6,B5,F#5,F5,-
  EndIf
  Play Stop
  Pause 10 ' The PAUSE helps to suppress an (MMB4L specific?) audio glitch.
  Local i%
  For i% = Bound(notes!(), 0) To Bound(notes!(), 1)
    If notes!(i%) > 16.0 Then Play Sound 4, B, S, notes!(i%), 25
    Pause 40
  Next
  Play Stop
End Sub

' Implements word wrapping by splitting a string on spaces.
'
' @param[in]       s$    the string.
' @param[in, out]  p%    position in the string to start from.
' @param[in]       len%  the 'line length'.
' @return                segment of string up to len% characters with no broken
'                        words, unless a word is longer than len%.
Function str.wwrap$(s$, p%, len%)
  Const slen% = Len(s$)
  Local ch%, q%, word$
  For q% = p% To slen% + 1
    ch% = Choice(q% > slen%, 0, Peek(Var s$, q%))
    Select Case ch%
      Case 0, &h0A, &h0D, &h20 ' null, \n, \r, space
        If Len(str.wwrap$) + Len(word$) > len% Then
          If Len(word$) > len% Then
            word$ = Left$(word$, len% - Len(str.wwrap$))
            Cat str.wwrap$, word$
            Inc p%, Len(word$)
          EndIf
          Exit For
        EndIf
        Cat str.wwrap$, word$
        p% = q% + 1
        Select Case ch%
          Case &h0D
            If Choice(p% > slen%, 0, Peek(Var s$, p%)) = &h0A Then Inc p%
            Exit For
          Case &h20
            If Len(str.wwrap$) = len% Then Exit For
            Cat str.wwrap$, " "
            word$ = ""
          Case Else
            Exit For
        End Select
      Case Else
        Cat word$, Chr$(ch%)
    End Select
  Next
  p% = Min(p%, slen% + 1)
End Function

sys.override_break("on_break")

Const CURRENT_PATH$ = Choice(Mm.Info(Path) <> "NONE", Mm.Info(Path), Cwd$)
Const CB = Rgb(Blue), CC= Rgb(Cyan),   CG = Rgb(Green)
Const CR = Rgb(Red),  CW = Rgb(White), CY = Rgb(Yellow)
Const VERSION_STRING$ = "Game*Mite Version " + sys.format_version$(VERSION)
Const STATE_SHOW_TITLE = 0, STATE_PLAY_GAME = 1

' Index 0 is food, 1 is player 1, 2 is player 2
Dim c(2) ' Colour
Dim dx(2), dy(2) ' Direction of movement in x & y directions
Dim pause_flag%  ' = 1 then pause the game
Dim p(2) As Integer ' Player input; bitset of ctrl.DOWN|LEFT|RIGHT|UP
Dim r(2) ' Radius
Dim s(2) ' Speed
Dim score(2)
Dim t%
Dim v(2) ' > 0 if player moving
Dim x(2), y(2) ' Coordinates
Dim state%

' Initialise input
ctrl.init_keys()
Dim ctrl$ = ctrl.default_driver$()

' Game music
Play ModFile CURRENT_PATH$ + "audio/circle.mod"

' The game uses the FrameBuffer to prevent screen drawing artifacts
FrameBuffer Create
FrameBuffer Write F
Font 8

Do
  state% = STATE_SHOW_TITLE
  show_intro()
  state% = STATE_PLAY_GAME
  score(1) = 0 : score(2) = 0
  start_round()
  Do While state% <> STATE_SHOW_TITLE
    t% = Timer + 100
    If Not c(0) Then create_food()
    If c(0) Then draw_food(c(0))
    ctrl_player()
    ctrl_ai()
    erase_players()
    move_players()
    handle_collisions()
    draw_players()
    handle_winning()
    draw_score()
    If pause_flag% Then handle_pause()
    FrameBuffer Copy F, N
    Do While Timer < t% : Loop
  Loop
Loop
Error "Unexpected program end"

Sub on_quit()
  msgbox.beep(1)
  Const fg% = Rgb(White), bg% = Rgb(Black), frame% = Rgb(Rust), flags% = &h0
  If state% = STATE_SHOW_TITLE Then
    Local buttons$(1) Length 3 = ("Yes", "No")
    Const msg$ = "Quit game?"
    Const x% = 9, y% = 10, w% = 22, h% = 9, btn% = 1
  Else
    Local buttons$(2) Length 7 = ("Restart", "Quit", "Cancel")
    Const msg$ = "Restart or Quit?"
    Const x% = 2, y% = 10, w% = 36, h% = 9, btn% = 2
  EndIf
  Const answer% = msgbox.show%(x%,y%,w%,h%,msg$,buttons$(),btn%,ctrl$,fg%,bg%,frame%,flags%)
  Select Case buttons$(answer%)
    Case "Quit", "Yes" : end_program()
    Case "Restart" : state% = STATE_SHOW_TITLE
  End Select
  Play ModFile CURRENT_PATH$ + "audio/circle.mod"
End Sub

'!dynamic_call on_break
Sub on_break()
  end_program(1)
End Sub

Sub end_program(break%)
  If Not break% Then
    Cls
    Text Mm.HRes / 2, Mm.VRes / 2 - 10, "Bye!", "CM", 8, 2, CY
    FrameBuffer Copy F, N
    Pause 2000
  EndIf
  game.end(break%)
End Sub

Sub show_intro()
  Cls
  Const key% = display_text%("intro_data", Mm.VRes / 2 - 80, 1000)
End Sub

intro_data:
Data "CIRCLE ONE", 2, CY, 17
Data "2025 JM-DG", 1, CC, 13
Data "<version>", 1, CG, 17
Data "", 1, CW, 17
Data "Eat apples to grow and win", 1, CW, 17
Data "Use arrow keys to steer", 1, CW, 17
Data "A to sprint, START to pause", 1, CW, 17
Data "Avoid collisions !!", 1, CW, 17
Data "", 1, CW, 17
Data "Press START to play", 1, CY, 17
Data "or SELECT to quit", 1, CY, 17
Data "", 0, 0, 0

' Reads and displays text from DATA statements
'
' @param   label$     Label for the DATA to read
' @param   top%       Initial y-coordinate
' @param   msec%      Pause duration between showing each line of text
' @return  the controller code for the key/button pressed
Function display_text%(label$, top%, msec%)
  Local col%, dy%, h%, s$, sz%, t%, w%, y% = top%
  Local k% = Not msec%
  Local k_old% = get_input%()
  Restore label$
  Do
    Read s$, sz%, col%, dy%
    If Not sz% Then Exit Do
    If s$ = "<version>" Then s$ = VERSION_STRING$
    w% = Len(s$) * 8 * sz% + 4
    h% = 8 * sz% + 4
    If Len(s$) Then Box (Mm.HRes - w%) / 2, y% - h% / 2, w%, h%, 1, 0, 0
    Text Mm.HRes / 2, y%, s$, "CM", 8, sz%, col% : Inc y%, dy%
    If k% Then Continue Do ' Pressing a key interrupts the PAUSE-ing.
    FrameBuffer Wait
    FrameBuffer Copy F, N
    t% = Timer + msec%
    Do While (Timer < t%) And (Not k%)
      k% = get_input%()
      ' Require the user to have released key or be pressing different key.
      If k% = k_old% Then k% = 0 Else k_old% = k%
    Loop
  Loop
  FrameBuffer Wait
  FrameBuffer Copy F, N
  Do While get_input%(1) : Loop
  Do While Not(get_input%() And (ctrl.START Or ctrl.A)) : Loop
  Do While get_input%(1) : Loop
End Function

Function get_input%(ignore%)
  Call ctrl$, get_input%
  If Not get_input% Then keys_cursor_ext(get_input%)
  If ignore% Then Exit Function
  Select Case get_input%
    Case ctrl.HOME, ctrl.SELECT
      on_quit()
      get_input% = 0
  End Select
End Function

Sub start_round()
  Cls
  Const SIZE = Mm.HRes / 40
  x(0) = Mm.HRes / 2 : y(0) = Mm.VRes / 3 : r(0) = SIZE : c(0) = CG
  x(1) = Mm.HRes / 3 : y(1) = 2 * Mm.VRes / 3 : r(1) = SIZE : c(1) = CB : s(1) = 5  'player speed, tweak
  x(2) = 2 * Mm.HRes / 3 : y(2) = 2 * Mm.VRes / 3 : r(2) = SIZE : c(2) = CR : s(2) = 3  'AI speed, tweak
End Sub

' Creates new food in a random location. If the result is too
' close to a player then do not create food on this call.
Sub create_food()
  x(0) = Mm.HRes * Rnd()
  y(0) = Mm.VRes * Rnd()
  Const d10 = Sqr((x(1) - x(0)) ^ 2 + (y(1) - y(0)) ^ 2)
  Const d20 = Sqr((x(2) - x(0)) ^ 2 + (y(2) - y(0)) ^ 2)
  If d10 < (r(1) + r(0) + 20) Then Exit Sub
  If d20 < (r(0) + r(2) + 20) Then Exit Sub
  c(0) = CG
End Sub

Sub draw_food(c%)
  Circle x(0) - 4, y(0) - 2, r(0), , , c%, c%
  Circle x(0) + 4, y(0), r(0), , , c%, c%
  Line x(0) - 3, y(0), x(0) + 5, y(0) - 2 * r(0), 1, c%
End Sub

Sub ctrl_player()
  Const p_old% = p(1)
  Const key% = get_input%()
  p(1) = key% And (ctrl.DOWN Or ctrl.LEFT Or ctrl.RIGHT Or ctrl.UP)
  If key% And ctrl.A Then s(1) = 12 ' Turbo run, tweak for fun
  If key% And ctrl.START Then pause_flag% = 1
  If Not p(1) Then p(1) = p_old%
  If s(1) > 5 Then Inc s(1), -1 ' Slow player if turbo-running
End Sub

Sub ctrl_ai()
  Local AIx% = Int((x(0) - x(2)) / 2), AIy% = Int((y(0) - y(2)) / 2)
  p(2) = 0
  If Abs(AIx%) > 1 Then p(2) = p(2) Or Choice(AIx% < 0, ctrl.LEFT, ctrl.RIGHT)
  If Abs(AIy%) > 1 Then p(2) = p(2) Or Choice(AIy% < 0, ctrl.UP, ctrl.DOWN)
End Sub

Sub erase_players()
  Local i%
  For i% = 1 To 2
    Circle x(i%), y(i%), r(i%) + 10, , , 0, 0
  Next
End Sub

Sub move_players()
  Local i%
  For i% = 1 To 2
    v(i%) = 0 : dx(i%) = 0 : dy(i%) = 0

    If p(i%) And ctrl.LEFT  Then Inc v(i%) : Inc x(i%), -s(i%) : dx(i%) = -1
    If p(i%) And ctrl.RIGHT Then Inc v(i%) : Inc x(i%),  s(i%) : dx(i%) =  1
    If p(i%) And ctrl.UP    Then Inc v(i%) : Inc y(i%), -s(i%) : dy(i%) = -1
    If p(i%) And ctrl.DOWN  Then Inc v(i%) : Inc y(i%),  s(i%) : dy(i%) =  1

    ' Allow wrap around
    Inc x(i%), Choice(x(i%) < 0, Mm.HRes, Choice(x(i%) > Mm.HRes, -Mm.HRes, 0))
    Inc y(i%), Choice(y(i%) < 0, Mm.VRes, Choice(y(i%) > Mm.VRes, -Mm.VRes, 0))
  Next
End Sub

Sub handle_collisions()
  ' Calculate distances
  Const d12 = Sqr((x(1) - x(2)) ^ 2 + (y(1) - y(2)) ^ 2)
  Const d10 = Sqr((x(1) - x(0)) ^ 2 + (y(1) - y(0)) ^ 2)
  Const d20 = Sqr((x(2) - x(0)) ^ 2 + (y(2) - y(0)) ^ 2)

  ' Game rules:
  '  - collision between players is punished
  '  - player who moves is culprit
  If d12 < (r(1) + r(2)) Then
    If v(1) > 0 Then r(1) = r(1) / 1.5
    If v(2) > 0 Then r(2) = r(2) / 1.5
    r(1) = Max(r(1), 3)
    r(2) = Max(r(2), 3)
  EndIf

  ' You eat, you grow
  If c(0) Then
    If d10 < (r(1) + r(0)) Then eat_food(1)
    If d20 < (r(0) + r(2)) Then eat_food(2)
  EndIf
End Sub

Sub eat_food(p%)
  r(p%) = r(p%) * 2
  draw_food(0)
  c(0) = 0
End Sub

Sub draw_players()
  Static counter% = 0
  Local i%, dyy, dxx, vv
  Inc counter%, 1
  For i% = 1 To 2
    ' Draw body
    Circle x(i%), y(i%), r(i%), , , c(i%), c(i%)
    If v(i%) > 0 Then
      ' Draw eyes when moving
      vv = 0.7 + (v(i%) = 1) * 0.3 'sqrt 2 if 45 degrees
      dyy = 6 * dy(i%) : dxx = 6 * dx(i%)
      draw_circle(x(i%) + vv * ((dx(i%) * r(i%)) - dyy), y(i%) + vv * ((dy(i%) * r(i%)) + dxx), 5, CW)
      draw_circle(x(i%) + vv * ((dx(i%) * r(i%)) + dyy), y(i%) + vv * ((dy(i%) * r(i%)) - dxx), 5, CW)
      draw_circle(x(i%) + vv * ((dx(i%) * (r(i%) + 2) - dyy)), y(i%) + vv * ((dy(i%) * (r(i%) + 2)) + dxx), 2)
      draw_circle(x(i%) + vv * ((dx(i%) * (r(i%) + 2) + dyy)), y(i%) + vv * ((dy(i%) * (r(i%) + 2)) - dxx), 2)
    Else
      ' Draw eyes when sleepy
      Circle x(i%) + 6, y(i%) + 2, 5, , , CW, CW
      Circle x(i%) - 6, y(i%) + 2, 5, , , CW, CW
      Circle x(i%) + 6, y(i%) - 1, 5, , , c(i%), c(i%)
      If (counter% + Choice(i% = 1, 0, 14)) And Choice(i% = 1, 28, 30) Then
        Circle x(i%) - 6, y(i%) + 4, 2, , , 0, 0
      Else
        Circle x(i%) - 6, y(i%) - 1, 5, , , c(i%), c(i%)
      EndIf
    EndIf
  Next
End Sub

' Draws circle whilst working around strange clipping behaviour when circle
' goes off screen.
Sub draw_circle(x%, y%, r%, col%)
  Select Case x%
    Case < 0 - r%, >= Mm.HRes + r%: Exit Sub
  End Select
  Select Case y%
    Case < 0 - r%, >= Mm.VRes + r%: Exit Sub
  End Select
  Circle x%, y%, r%, , , col%, col%
End Sub

Sub handle_winning()
  Local win%
  If r(1) > Mm.VRes / 2 Then win% = 1
  If (Not win%) And (r(2) > Mm.VRes / 2) Then win% = 2
  If Not win% Then Exit Sub

  Inc score(win%)
  draw_score()
  Const label$ = "win_" + Str$(win%) + "_data"
  Const k% = display_text%(label$, Mm.VRes / 2 - 30)
  start_round()
End Sub

win_1_data:
Data "Blue Wins", 2, CY, 17
Data "", 1, 0, 17
Data "Press START to continue", 1, CY, 17
Data "or SELECT to quit", 1, CY, 17
Data "", 0, 0, 0

win_2_data:
Data "Red Wins", 2, CY, 17
Data "", 1, 0, 17
Data "Press START to continue", 1, CY, 17
Data "or SELECT to quit", 1, CY, 17
Data "", 0, 0, 0

Sub draw_score()
  Text 0, 0, Str$(score(1)), "LT", 8, 2, CB
  Text Mm.HRes, 0, Str$(score(2)), "RT", 8, 2, CR
End Sub

Sub handle_pause()
  pause_flag% = 0
  Const key% = display_text%("pause_data", Mm.VRes / 2 - 30)
  Cls
End Sub

pause_data:
Data "PAUSED", 2, CY, 17
Data "", 1, 0, 17
Data "Press START to continue", 1, CY, 17
Data "or SELECT to quit", 1, CY, 17
Data "", 0, 0, 0

' Konami Style Font (Martin H.)
' Font type    : Full (95 ChArACtErs)
' Font size    : 8x8 pixels
' Memory usage : 764 Bytes
DefineFont #8
  5F200808
  00000000 00000000 18181818 00180018 006C6C6C 00000000 367F3636 0036367F
  3E683F0C 00187E0B 180C6660 00066630 386C6C38 003B666D 0030180C 00000000
  3030180C 000C1830 0C0C1830 0030180C 3C7E1800 0000187E 7E181800 00001818
  00000000 30181800 7E000000 00000000 00000000 00181800 180C0600 00006030
  7E6E663C 003C6676 18183818 007E1818 0C06663C 007E3018 1C06663C 003C6606
  6C3C1C0C 000C0C7E 067C607E 003C6606 7C60301C 003C6666 180C067E 00303030
  3C66663C 003C6666 3E66663C 00380C06 18180000 00181800 18180000 30181800
  6030180C 000C1830 007E0000 0000007E 060C1830 0030180C 180C663C 00180018
  6A6E663C 003C606E 7E66663C 00666666 7C66667C 007C6666 6060663C 003C6660
  66666C78 00786C66 7C60607E 007E6060 7C60607E 00606060 6E60663C 003C6666
  7E666666 00666666 1818187E 007E1818 0C0C0C3E 00386C0C 70786C66 00666C78
  60606060 007E6060 6B7F7763 0063636B 7E766666 0066666E 6666663C 003C6666
  7C66667C 00606060 6666663C 00366C6A 7C66667C 0066666C 3C60663C 003C6606
  1818187E 00181818 66666666 003C6666 66666666 00183C66 6B6B6363 0063777F
  183C6666 0066663C 3C666666 00181818 180C067E 007E6030 6060607C 007C6060
  18306000 0000060C 0606063E 003E0606 42663C18 00000000 00000000 FF000000
  7C30361C 007E3030 063C0000 003E663E 667C6060 007C6666 663C0000 003C6660
  663E0606 003E6666 663C0000 003C607E 7C30301C 00303030 663E0000 3C063E66
  667C6060 00666666 18380018 003C1818 18380018 70181818 6C666060 00666C78
  18181838 003C1818 7F360000 00636B6B 667C0000 00666666 663C0000 003C6666
  667C0000 60607C66 663E0000 07063E66 766C0000 00606060 603E0000 007C063C
  307C3030 001C3030 66660000 003E6666 66660000 00183C66 6B630000 00367F6B
  3C660000 00663C18 66660000 3C063E66 0C7E0000 007E3018 7018180C 000C1818
  00181818 00181818 0E181830 00301818 00466B31 00000000 FFFFFFFF FFFFFFFF
End DefineFont
