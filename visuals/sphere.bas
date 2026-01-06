Dim CM(15)=(RGB(0,0,0),RGB(0,0,255),RGB(0,64,0),RGB(0,64,255),RGB(0,128,0),RGB(0,128,255),RGB(0,255,0),RGB(0,255,255),RGB(255,0,0),RGB(255,0,255),RGB(255,64,0),RGB(255,64,255),RGB(255,128,0),RGB(255,128,255),RGB(255,255,0),RGB(255,255,255))
RANDOMIZE TIMER

Dim Xa(255), Ya(255)
x0 = MM.HRES \ 2
y0 = MM.VRES \ 2
Xdir = 1
Ydir = 1
C = CM(Int(Rnd * 15) + 1)
n = 4
r = n * 16

DIM frameCount = 0
DIM fps = 0
DIM lastTime = TIMER - 1000

CLS

DO WHILE INKEY$ <> CHR$(27)
    i = 0
    t = Timer
    tr = t - n * 50
    ra = tr / 1234
    rb = tr / 2345

    For a = 0 To Pi Step .39268
        For b = 0 To Pi * 2 Step .8-.6*Sin(a)
            o = Sin(a) * Cos(b)
            k = Sin(a) * Sin(b)
            e = Cos(a) * Cos(ra) + k * Sin(ra)
            'BOX Xa(i), Ya(i), 2, 2, , CM(0), CM(0)
            Pixel Xa(i), Ya(i), CM(0)
            Xa(i) = (o * Cos(rb) + e * Sin(rb)) * r + x0
            Ya(i) = (e * Cos(rb) - o * Sin(rb)) * r + y0
            'BOX Xa(i), Ya(i), 2, 2, , C, C
            Pixel Xa(i), Ya(i), C
            Inc i
        Next b
    Next a

    If x0 < r Then Xdir = 1 : C = CM(Int(Rnd * 15) + 1)
    If y0 < r Then Ydir = 1 : C = CM(Int(Rnd * 15) + 1)
    If x0 > MM.HRES - r Then Xdir = -1 : C = CM(Int(Rnd * 15) + 1)
    If y0 > MM.VRES - r Then Ydir = -1 : C = CM(Int(Rnd * 15) + 1)
    Inc x0, Xdir
    Inc y0, Ydir

    ' FPS counter
    frameCount = frameCount + 1
    IF TIMER - lastTime >= 1000 THEN
        fps = frameCount
        frameCount = 0
        lastTime = TIMER
        TEXT MM.HRES, 0, STR$(fps) + " FPS", "R", , 1, CM(6)
    END IF
    
    PAUSE 1
LOOP

CLS

END
