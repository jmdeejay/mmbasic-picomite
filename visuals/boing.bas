option Explicit
option BASE 0

CONST BACKGROUND_COLOR = rgb(64, 64, 64)
CONST SHADOW_COLOR = rgb(0, 0, 0)
CONST BALL_COLOR1 = RGB(255, 0, 0)
CONST BALL_COLOR2 = RGB(255, 255, 255)

CONST W = MM.HRES
CONST H = MM.VRES
const NU = 8, NV = 8
const NF = NU * (NV - 1)
const FOVC = 20, ZOFF = 7.0
const SCL = 10
const TILTZ = 0.3

dim i, j, k, n, ip, jp, t
dim bx, by, vx, vy, ry, vr
dim th, ph, xx, yy, zz, zzm, sc, xz, yz
dim rad, ballColor
dim ax3, ay3, az3, bx3, by3, bz3, nz
dim dx1, dx2, dx3, dy1, dy2
dim shx, shy, rxsh, rysh, ox, oy
'DIM prevBallX(NF - 1, 3), prevBallY(NF - 1, 3)
'DIM faceDrawn(NF - 1)
Dim eraseX, eraseY, eraseRadius

' model
dim mx(NU - 1, NV - 1), my(NU - 1, NV - 1), mz(NU - 1, NV - 1)
' view
dim vx3(NU - 1, NV - 1), vy3(NU - 1, NV - 1), vz3(NU - 1, NV - 1)
' screen
dim sx(NU - 1, NV - 1), sy(NU - 1, NV - 1)
' faces
dim fi(NF - 1), fj(NF - 1), fz(NF - 1), ord%(NF - 1)
' poly
dim ax%(3), ay%(3)
dim fb_bg, fb_front, wallx0, wally0, wallx1, wally1, floorY

DIM frameCount = 0
DIM fps = 0
DIM lastTime = TIMER - 1000

' motion
bx = W / 2: by = H / 2
vx = 8.0: vy = 4.7
rad = SCL * (FOVC / ZOFF)
vr = .35

' shadow offset
ox = 8 : oy = 2
eraseRadius = rad + vx + ox + 4

' --- sphere grid ---
for i = 0 to NU-1
  th = 2 * pi * i / NU
  for j = 0 to NV - 1
    ph = pi * (j / (NV - 1) - 0.5)
    mx(i, j) = cos(ph) * cos(th)
    my(i, j) = sin(ph)
    mz(i, j) = cos(ph) * sin(th)
  next
next

n = 0
for i = 0 to NU - 1
  for j = 0 to NV - 2
    fi(n) = i: fj(n) = j: ord%(n) = n: n = n+1
  next
next

'framebuffer create
'framebuffer write F
cls BACKGROUND_COLOR

DO WHILE INKEY$ <> CHR$(27)

  ' rotate+project (Y only)
  ry = ry + vr
  for i = 0 to NU - 1
    for j = 0 to NV - 1
      xx = mx(i, j) * cos(ry) - mz(i, j) * sin(ry)
      zz = mx(i, j) * sin(ry) + mz(i, j) * cos(ry)
      yy = my(i, j)
      xz = xx * cos(TILTZ) - yy * sin(TILTZ)
      yz = xx * sin(TILTZ) + yy * cos(TILTZ)
      xx = xz
      yy = yz
      vz3(i, j) = zz
      vx3(i, j) = xx
      vy3(i, j) = yy
      sc = FOVC /(zz + ZOFF)
      sx(i, j) = bx + xx * sc * SCL
      sy(i, j) = by + yy * sc * SCL
    next
  next

  ' depth per face
  for k = 0 to NF - 1
    i = fi(k) : j = fj(k)
    ip = (i + 1) mod NU: jp = j + 1
    fz(k) = (vz3(i, j) + vz3(ip, j) + vz3(ip, jp) + vz3(i, jp)) / 4
  next

  ' Erase shadow and ball
  'circle shx, shy, rad + 2, 1, 1, BACKGROUND_COLOR, BACKGROUND_COLOR
  'for k = 0 to NF - 1
    'if faceDrawn(k) then
      'ax%(0)=prevBallX(k,0): ay%(0)=prevBallY(k,0)
      'ax%(1)=prevBallX(k,1): ay%(1)=prevBallY(k,1)
      'ax%(2)=prevBallX(k,2): ay%(2)=prevBallY(k,2)
      'ax%(3)=prevBallX(k,3): ay%(3)=prevBallY(k,3)
      'polygon 4, ax%(), ay%(), BACKGROUND_COLOR, BACKGROUND_COLOR
      'faceDrawn(k) = 0
    'ENDIF
  'next
  
  eraseX = bx + ox / 2
  eraseY = by + oy / 2
  circle eraseX, eraseY, eraseRadius, 1, 1, BACKGROUND_COLOR, BACKGROUND_COLOR
  
  ' --- ball shadow behind ball
  shx = bx + ox
  shy = by + oy
  circle shx, shy, rad + 2, 1, 1, SHADOW_COLOR, SHADOW_COLOR

  ' draw visible faces only (cull)
  for k = 0 to NF - 1
    'faceDrawn(k) = 0
    i = fi(ord%(k)): j = fj(ord%(k))
    ip=(i + 1) mod NU: jp = j + 1
    
    ' Cull
    ax3 = vx3(ip, j) - vx3(i, j)
    ay3 = vy3(ip, j) - vy3(i, j)
    az3 = vz3(ip, j) - vz3(i, j)
    bx3 = vx3(i, jp) - vx3(i, j)
    by3 = vy3(i, jp) - vy3(i, j)
    bz3 = vz3(i, jp) - vz3(i, j)
    nz  = ax3 * by3 - ay3 * bx3
    if nz > 0 then continue for
    
    ax%(0) = int(sx(i, j))  : ay%(0) = int(sy(i, j))
    ax%(1) = int(sx(ip, j)) : ay%(1) = int(sy(ip, j))
    ax%(2) = int(sx(ip, jp)): ay%(2) = int(sy(ip, jp))
    ax%(3) = int(sx(i, jp)) : ay%(3) = int(sy(i, jp))
    
    if ((i + j) and 1) = 0 then
      ballColor = BALL_COLOR1
    else
      ballColor = BALL_COLOR2
    endif
    
    ' seam/viewport guards to avoid popping
    dx1 = abs(sx(ip, j) - sx(i, j))
    dx2 = abs(sx(i, jp) - sx(i, j))
    dx3 = abs(sx(ip, jp) - sx(i, j))
    if dx1 > W / 2 or dx2 > W / 2 or dx3 > W / 2 then continue for
    if ax%(0) < -32 or ax%(0) > W + 32 then continue for
    if ax%(1) < -32 or ax%(1) > W + 32 then continue for
    if ax%(2) < -32 or ax%(2) > W + 32 then continue for
    if ax%(3) < -32 or ax%(3) > W + 32 then continue for
    
    'prevBallX(k, 0) = ax%(0) : prevBallX(k, 1) = ax%(1)
    'prevBallX(k, 2) = ax%(2) : prevBallX(k, 3) = ax%(3)
    'prevBallY(k, 0) = ay%(0) : prevBallY(k, 1) = ay%(1)
    'prevBallY(k, 2) = ay%(2) : prevBallY(k, 3) = ay%(3)
    polygon 4, ax%(), ay%(), ballColor, ballColor
    'faceDrawn(k) = 1
  next

  ' Move & bounce
  if bx < rad then vx= abs(vx) : vr = abs(vr)
  if bx > W - rad then vx = -abs(vx): vr = -abs(vr)
  if by < rad then vy = abs(vy)
  if by > H - rad then vy = -abs(vy)
  bx = bx + vx: by = by + vy

  ' FPS counter
  frameCount = frameCount + 1
  IF TIMER - lastTime >= 1000 THEN
    fps = frameCount
    frameCount = 0
    lastTime = TIMER
    ' TEXT W, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
  END IF
  TEXT W, 0, STR$(fps) + " FPS", "R", , 1, RGB(GREEN)
  PAUSE 1
  
  'FRAMEBUFFER COPY F, N
loop

'FrameBUFFER WRITE N
CLS

END
