OPTION EXPLICIT
OPTION FAST AUDIO OFF
OPTION CONTINUATION LINES ON
RANDOMIZE TIMER

'---------------------------------------------
' Configuration
'---------------------------------------------
CONST SPLASH_IMAGE = "/images/startup-logo.bmp"
CONST AUDIO_FOLDER = "/audio/"
CONST AUDIO_COUNT = 6

DIM selectedAudio$
DIM startupAudio$(AUDIO_COUNT)
startupAudio$(1) = "win95.mp3"
startupAudio$(2) = "win98.mp3"
startupAudio$(3) = "win2000.mp3"
startupAudio$(4) = "winxp.mp3"
startupAudio$(5) = "winxp4bits.mp3"
startupAudio$(6) = "winxp64bits.mp3"

SUB Startup()
  RUN "/startscreen.bas"
  ' RUN "/shell.bas"
END SUB

CLS
DRIVE "B:"

'---------------------------------------------
' 1. Show splash image if it exists
'---------------------------------------------
IF MM.INFO(exists file SPLASH_IMAGE) THEN
  LOAD IMAGE SPLASH_IMAGE
END IF

'---------------------------------------------
' 2. Play startup sound
'---------------------------------------------
selectedAudio$ = AUDIO_FOLDER + startupAudio$(INT(RND * AUDIO_COUNT) + 1)
IF MM.INFO(exists file selectedAudio$) THEN
  PLAY MP3 selectedAudio$, Startup
  PAUSE 10000
ELSE
  Startup()
END IF
