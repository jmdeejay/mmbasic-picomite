OPTION EXPLICIT

CONST FONT_W = MM.FONTWIDTH
CONST FONT_H = MM.FONTHEIGHT
CONST WIDTH = 20
CONST HEIGHT = 10
CONST PADDLE_SIZE = 3

DIM ballX, ballY, ballDX, ballDY
DIM prevBallX, prevBallY
DIM paddleY, prevPaddleY
DIM score
DIM key$
DIM i

SUB initializeGame
    CLS

    ballX = WIDTH \ 2
    ballY = HEIGHT \ 2
    prevBallX = ballX
    prevBallY = ballY
    ballDX = 1

    paddleY = HEIGHT \ 2
    prevPaddleY = paddleY

    score = 0

    ' Draw right walls
    FOR i = 1 TO HEIGHT
        PRINT @((WIDTH - 1) * FONT_W, (i - 1) * FONT_H) "|"
    NEXT i

    ' Draw initial paddle
    FOR i = 0 TO PADDLE_SIZE-1
        PRINT @(1 * FONT_W, (paddleY + i - 1) * FONT_H) "|"
    NEXT i

    ' Draw initial ball
    PRINT @((ballX - 1) * FONT_W, (ballY - 1) * FONT_H) "O"

    ' Display score & instructions
    PRINT @(0, HEIGHT * FONT_H) "Score: "; score
    PRINT @(0, (HEIGHT + 1) * FONT_H) "Move=Up/Down, Esc=Quit"
END SUB

RANDOMIZE TIMER
initializeGame()

DO
    ' Erase previous ball
    PRINT @((prevBallX - 1) * FONT_W, (prevBallY - 1) * FONT_H) " "

    ' Move ball
    ballX = ballX + ballDX
    ballY = ballY + ballDY

    ' Bounce
    IF ballY <= 1 OR ballY >= HEIGHT THEN ballDY = -ballDY
    IF ballX >= WIDTH THEN ballDX = -ballDX

    ' Bounce off paddle
    IF ballX = 2 AND ballY >= paddleY AND ballY < paddleY + PADDLE_SIZE THEN
        ballDX = -ballDX
        score = score + 1
        PRINT @(0, HEIGHT * FONT_H) "Score: "; score;
    END IF

    ' Missed paddle
    IF ballX <= 1 THEN
        PRINT @(0, (HEIGHT + 1) * FONT_H) "Game Over! Final Score: "; score
        END
    END IF

    ' Handle paddle movement
    key$ = INKEY$
    IF ASC(key$) = 128 AND paddleY > 1 THEN
        PRINT @(1 * FONT_W, (paddleY + PADDLE_SIZE - 2) * FONT_H) " "   ' erase bottom
        paddleY = paddleY - 1
    END IF
    IF ASC(key$) = 129 AND paddleY < HEIGHT - PADDLE_SIZE + 1 THEN
        PRINT @(1 * FONT_W, (paddleY - 1) * FONT_H) " "                ' erase top
        paddleY = paddleY + 1
    END IF
    IF key$ = CHR$(27) THEN 
        CLS
        END
    END IF

    ' Draw paddle
    FOR i = 0 TO PADDLE_SIZE - 1
        PRINT @(1 * FONT_W, (paddleY + i - 1) * FONT_H) "|"
    NEXT i

    ' Draw right wall
    FOR i = 1 TO HEIGHT
        PRINT @((WIDTH - 1) * FONT_W, (i - 1) * FONT_H) "|"
    NEXT i

    ' Draw ball
    PRINT @((ballX - 1) * FONT_W, (ballY - 1) * FONT_H) "O"

    prevBallX = ballX
    prevBallY = ballY

    PAUSE 100
LOOP
