Option EXPLICIT
RANDOMIZE TIMER

Const SCREEN_W = MM.HRES
Const SCREEN_H = MM.VRES
Const MAX_VISIBLE = 25
Const MAX_FILES = 256
Const SCROLLBAR_WIDTH = 6
Const SCROLLBAR_MARGIN = 2
Const BACKGROUND_COLOR = RGB(BLACK)
Const HIGHLIGHT_COLOR = RGB(GREEN) ' Fonts & UI elements
CONST CONFIG_FILE = "/menu.ini"
Const SEARCH_TIMEOUT = 1500
CONST ERROR_TIMEOUT = 2000

CONST BACK = 8
CONST ESC = 27
CONST DEL1 = 212
CONST DEL2 = 127
CONST RETURN1 = 10
CONST RETURN2 = 13
CONST UP_ARROW = 128
CONST DOWN_ARROW = 129
CONST FUNC1 = 145
CONST FUNC2 = 146
CONST FUNC3 = 147

Const STYLE_NORMAL = 0
Const STYLE_SELECTED = 1
Const STYLE_ERASE = 2

Const TYPE_UNKNOWN = 0
Const TYPE_FOLDER = 1
Const TYPE_PROGRAM = 2
Const TYPE_TEXT = 3
Const TYPE_IMAGE = 4
Const TYPE_MUSIC = 5

Dim keyPressed$               ' input key pressed
Dim f$                        ' file
Dim fullFilename$(MAX_FILES)  ' full filename
Dim displayName$(MAX_FILES)   ' display name
Dim sizes$(MAX_FILES)         ' file size
Dim types(MAX_FILES)          ' file type
Dim INTEGER index(MAX_FILES)
Dim INTEGER prev, totalFiles, foundPos
Dim INTEGER selected = 1      ' index of selected file
Dim INTEGER top = 1           ' index in file$() of first visible row
Dim INTEGER clearDisplayNameW, clearSizesW
Dim searchBuffer$             ' accumulated typed characters
Dim lastKeyTime As FLOAT
Dim errorMsg$ = ""
Dim timerMsg = 0

Dim INTEGER excludeCount = 7
Dim exclude$(excludeCount)
exclude$(1) = "autorun"
exclude$(2) = "menu"
exclude$(3) = "startscreen"
exclude$(4) = "openAudio"
exclude$(5) = "openImage"
exclude$(6) = "openText"
exclude$(7) = "libraries"

Function IsExcluded(f$) as integer
  Local j%
  For j% = 1 To excludeCount
    If LCase$(f$) = LCase$(exclude$(j%)) Then
      IsExcluded = 1
      Exit Function
    EndIf
  Next
  IsExcluded = 0
End Function

'-------------------------------------------
' Returns icon based on file extension
'-------------------------------------------
Function GetIcon$(type) as STRING
  Select Case type
    Case TYPE_FOLDER
      GetIcon$ = Chr$(148) + " <DIR>"
    Case TYPE_PROGRAM
      GetIcon$ = Chr$(142)
    Case TYPE_TEXT
      GetIcon$ = Chr$(173)
    Case TYPE_IMAGE
      GetIcon$ = Chr$(136)
    Case TYPE_MUSIC
      GetIcon$ = Chr$(143)
    Case Else
      GetIcon$ = Chr$(142)
  End Select
End Function

'-------------------------------------------
' Returns file type based on file extension
'-------------------------------------------
Function GetTypeByExt(isDirectory, ext$) as integer
  If isDirectory Then
    GetTypeByExt = TYPE_FOLDER
  Else
    Select Case ext$
      Case "bas"
        GetTypeByExt = TYPE_PROGRAM
      Case "txt", "md"
        GetTypeByExt = TYPE_TEXT
      Case "bmp", "jpeg", "jpg", "png"
        GetTypeByExt = TYPE_IMAGE
      Case "flac", "mod", "mp3", "wav"
        GetTypeByExt = TYPE_MUSIC
      Case Else
        GetTypeByExt = TYPE_UNKNOWN
    End Select
  EndIf
End Function

FUNCTION GetFileName$(prompt$) AS STRING
  LOCAL x, y
  LOCAL a$, k$
  
  a$ = ""
  prompt$ = prompt$ + "? "
  x = LEN(prompt$) * MM.FONTWIDTH
  y = SCREEN_H - MM.FONTHEIGHT
  
  DisplayMessageError(prompt$, 200)
  FRAMEBUFFER COPY F, N
  
  DO
    k$ = INKEY$
    IF k$ <> "" THEN
      SELECT CASE k$
        CASE CHR$(BACK)
          IF LEN(a$) > 0 THEN
            x = x - MM.FONTWIDTH
            a$ = LEFT$(a$, LEN(a$) - 1)
            TEXT x, y, " "
          END IF
        CASE CHR$(RETURN1), CHR$(RETURN2)
          EXIT DO
        CASE CHR$(ESC)
          a$ = ""
          EXIT DO
        CASE ELSE
          IF ASC(k$) >= 32 AND ASC(k$) <= 122 THEN
            a$ = a$ + k$
            TEXT x, y, k$
            x = x + MM.FONTWIDTH
          ENDIF
      END SELECT
      FRAMEBUFFER COPY F, N
    END IF
    PAUSE 10
  LOOP
  
  GetFileName$ = a$
  DisplayMessageError(SPACE$(LEN(prompt$)), 0)
END FUNCTION

function ConfirmDialog(msg$) as integer
  local a$
  
  a$ = ""
  DisplayMessageError(msg$, 200)
  FRAMEBUFFER COPY F, N
  
  do
    a$ = ucase$(inkey$)
    if a$ = "Y" then
      ConfirmDialog = 1
      exit DO
    ELSEif a$ = "N" then
      ConfirmDialog = 0
      exit DO
    endif
  loop
  
  DisplayMessageError(SPACE$(LEN(msg$)), 0)
end function

Sub LoadFiles()
  Local i, j, totaldisplayNameW, totalSizesW
  Local fsize
  Local fName$, ext$
  Local isDirectory
  
  totalFiles = 0
  clearDisplayNameW = 0
  clearSizesW = 0

  ' Add "../" only if not at root (Ex: B:/)
  If Len(Cwd$) > 3 Then
    totalFiles = totalFiles + 1
    fullFilename$(totalFiles) = ".."
    types(totalFiles) = TYPE_FOLDER
    displayName$(totalFiles) = GetIcon$(types(totalFiles)) + " ../"
    sizes$(totalFiles) = ""
    totaldisplayNameW = Len(displayName$(totalFiles))
  EndIf

  f$ = Dir$("*", ALL)
  Do While f$ <> ""
    isDirectory = (MM.Info(EXISTS DIR f$) = 1)
    If (isDirectory) Then
      fName$ = f$ + "/"
    Else
      ext$ = GetExt$(f$)
      fName$ = Left$(f$, Len(f$) - Len(ext$) - 1)
    EndIf

    If Not IsExcluded(fName$) Then
      totalFiles = totalFiles + 1
      fullFilename$(totalFiles) = LCase$(f$)
      types(totalFiles) = GetTypeByExt(isDirectory, ext$)
      displayName$(totalFiles) = GetIcon$(types(totalFiles)) + " " + fName$
      fsize = MM.Info(FILESIZE f$)
      If (fsize > 0) Then
        sizes$(totalFiles) = "(" + FormatSize$(fsize) + ")"
      EndIf

      totaldisplayNameW = Len(displayName$(totalFiles))
      If totaldisplayNameW > clearDisplayNameW Then
        clearDisplayNameW = totaldisplayNameW
      EndIf
      totalSizesW = Len(sizes$(totalFiles))
      If totalSizesW > clearSizesW Then
        clearSizesW = totalSizesW
      EndIf
    EndIf
    f$ = Dir$()
  Loop

  If totalFiles = 0 Then
    totalFiles = totalFiles + 1
    fullFilename$(totalFiles) = ""
    types(totalFiles) = TYPE_UNKNOWN
    displayName$(totalFiles) = "No files found."
    sizes$(totalFiles) = ""
    totaldisplayNameW = Len(displayName$(totalFiles))
  EndIf

  For i = 1 To totalFiles
    index(i) = i
  Next i
  ' Bubble-sort index array by fullFilename$
  For i = 1 To totalFiles - 1
    For j = i + 1 To totalFiles
      CompareAndSwap(i, j)
    Next j
  Next i
  
  OpenConfig()
End Sub

Sub OpenConfig()
  LOCAL currentDir$, lastSelected$, lastTop$
  
  IF MM.INFO(exists file CONFIG_FILE) THEN
    OPEN CONFIG_FILE FOR INPUT AS #1
    LINE INPUT #1, currentDir$
    LINE INPUT #1, lastSelected$
    LINE INPUT #1, lastTop$
    CLOSE #1
    
    IF currentDir$ = CWD$ THEN
      selected = VAL(lastSelected$)
      top = VAL(lastTop$)
      
      IF selected < 1 THEN selected = 1
      IF selected > totalFiles THEN selected = totalFiles
      IF top < 1 THEN top = 1
      IF top > totalFiles THEN top = totalFiles
    ENDIF
  ENDIF
END Sub

Sub SaveConfig()
  OPEN CONFIG_FILE FOR OUTPUT AS #1
  PRINT #1, CWD$
  PRINT #1, STR$(selected)
  PRINT #1, STR$(top)
  CLOSE #1
END Sub

Sub CompareAndSwap(i, j)
  Local idxI, idxJ
  Local idxIIsFolder, idxJIsFolder

  idxI = index(i)
  idxJ = index(j)
  idxIIsFolder = (types(idxI) = TYPE_FOLDER)
  idxJIsFolder = (types(idxJ) = TYPE_FOLDER)

  ' Folder priority
  If Not idxIIsFolder And idxJIsFolder Then
    index(i) = idxJ : index(j) = idxI
  ElseIf (idxIIsFolder And idxJIsFolder) Or (Not idxIIsFolder And Not idxJIsFolder) Then
    If fullFilename$(idxJ) < fullFilename$(idxI) Then
      index(i) = idxJ : index(j) = idxI
    EndIf
  EndIf
End Sub

Sub DrawItem(xx, yy, position, style)
  Local itemName$, sizeStr$
  Local bgColor
  ' Style: 0 = normal, 1 = selected, 2 = erase

  itemName$ = displayName$(index(position))
  sizeStr$ = sizes$(index(position))
  bgColor = BACKGROUND_COLOR

  If (style = STYLE_SELECTED) Then
    Color BACKGROUND_COLOR, HIGHLIGHT_COLOR
    bgColor = HIGHLIGHT_COLOR
  EndIf
  If (style <> STYLE_NORMAL) Then
    Box xx, yy, SCREEN_W - (SCROLLBAR_WIDTH + SCROLLBAR_MARGIN + xx), MM.FONTHEIGHT, , bgColor, bgColor
  EndIf
  Text xx, yy, itemName$, "L"
  Text SCREEN_W - (SCROLLBAR_WIDTH + SCROLLBAR_MARGIN), yy, sizeStr$, "R"
  If (style = STYLE_SELECTED) Then
    Color HIGHLIGHT_COLOR, BACKGROUND_COLOR
  EndIf
End Sub

Sub DrawWindow()
  Local row, position
  Local w1, w2, h

  w1 = clearDisplayNameW * MM.FONTWIDTH
  h = MAX_VISIBLE * MM.FONTHEIGHT
  Box 0, 0, w1, h, , BACKGROUND_COLOR, BACKGROUND_COLOR

  w2 = SCREEN_W - (clearSizesW * MM.FONTWIDTH) - (SCROLLBAR_WIDTH + SCROLLBAR_MARGIN)
  Box w2, 0, (clearSizesW * MM.FONTWIDTH), h, , BACKGROUND_COLOR, BACKGROUND_COLOR

  For row = 0 To MAX_VISIBLE - 1
    position = top + row
    If position <= totalFiles Then
      DrawItem(0, row * MM.FONTHEIGHT, position, STYLE_NORMAL)
    EndIf
  Next row
End Sub

Sub DrawSelection(prev, new)
  ' Remove highlight on previous
  If prev >= top And prev < top + MAX_VISIBLE Then
    DrawItem(0, (prev - top) * MM.FONTHEIGHT, prev, STYLE_ERASE)
  EndIf
  ' Highlight new
  If new >= top And new < top + MAX_VISIBLE Then
    DrawItem(0, (new - top) * MM.FONTHEIGHT, new, STYLE_SELECTED)
  EndIf
  DrawScrollbar()
  DrawErrorMsg()
  DrawSelectionCounter()
End Sub

Sub DrawScrollbar()
  Local barH As INTEGER, barY As INTEGER
  Local usableHeight As INTEGER
  Local scrollRatio As FLOAT

  If totalFiles <= MAX_VISIBLE Then Exit Sub

  usableHeight = MAX_VISIBLE * MM.FONTHEIGHT
  barH = Int(usableHeight * (MAX_VISIBLE / totalFiles))
  If barH < 2 Then barH = 2
  barY = Int((top - 1) / (totalFiles - MAX_VISIBLE) * (usableHeight - barH))

  Box SCREEN_W - SCROLLBAR_WIDTH, 0, SCROLLBAR_WIDTH, usableHeight, , BACKGROUND_COLOR, BACKGROUND_COLOR

  Box SCREEN_W - SCROLLBAR_WIDTH, barY, SCROLLBAR_WIDTH, barH, , HIGHLIGHT_COLOR, HIGHLIGHT_COLOR
End Sub

Sub DrawSelectionCounter()
  Local s$, maxChars, maxWidth

  s$ = Str$(selected) + " / " + Str$(totalFiles)
  maxChars = Len(Str$(totalFiles)) * 2 + 3
  maxWidth = maxChars * MM.FONTWIDTH
  Text SCREEN_W - 8 - maxWidth, SCREEN_H - MM.FONTHEIGHT, Space$(maxChars), "L"
  Text SCREEN_W - 8 - (Len(s$) * MM.FONTWIDTH), SCREEN_H - MM.FONTHEIGHT, s$, "L"
End Sub

Sub ExecuteFile()
  Local filename$, ext$
  Local type

  filename$ = fullFilename$(index(selected))
  type = types(index(selected))
  If (type = TYPE_FOLDER) Then
    Chdir filename$
    Initialize(1, 1)
  Else
    SaveConfig()
    ext$ = GetExt$(filename$)
    Select Case type
      Case TYPE_PROGRAM
        Run filename$
      ' Required: we need to open text files in a custom editor. 
      ' We can't run "EDIT" inside a program.
      Case TYPE_TEXT
        ' Edit filename$
        RUN "/openText.bas", filename$
      ' Required: We need to load images & audio
      ' in a separate program in order to free up memory.
      Case TYPE_IMAGE
        Run "/openImage.bas", filename$
      Case TYPE_MUSIC
        Run "/openAudio.bas", filename$
      Case Else
        DisplayMessageError("Unknown file type: " + ext$, ERROR_TIMEOUT)
    End Select
  EndIf
End Sub

Sub DisplayMessageError(value$, durationMs)
  errorMsg$ = value$
  timerMsg = Timer + durationMs
  DrawErrorMsg()
End Sub

Sub DrawErrorMsg()
  LOCAL x, y, w

  If errorMsg$ = "" Then Exit Sub
  
  x = 0
  y = SCREEN_H - MM.FONTHEIGHT
  If Timer > timerMsg Then
    w = Len(errorMsg$) * MM.FONTWIDTH
    Box x, y, w, MM.FONTHEIGHT, , BACKGROUND_COLOR, BACKGROUND_COLOR
    errorMsg$ = ""
  ELSE
    Text x, y, errorMsg$, "L", , 1, HIGHLIGHT_COLOR
  EndIf
End Sub

Sub DeleteEntry()
  Local filename$
  Local type

  filename$ = fullFilename$(index(selected))
  type = types(index(selected))
  
  IF ConfirmDialog("Delete current entry? (Y/N)") THEN
    SaveConfig()
    if (type = TYPE_FOLDER) then
      on error skip 1
      rmdir filename$
      if MM.ERRNO <> 0 then DisplayMessageError(MM.ERRMSG$, 1000)
    else
      kill filename$
      if MM.ERRNO <> 0 then DisplayMessageError(MM.ERRMSG$, 1000)             
    endif
    Initialize(1, 0)
  ENDIF
END Sub

Sub CopyEntry()
  LOCAl newFile$
  
  newFile$ = GetFileName$("Copy to")
  if newFile$ <> "" then
    SaveConfig()
    on error skip 1
    copy fullFilename$(index(selected)) to newFile$
    if MM.ERRNO <> 0 then DisplayMessageError(MM.ERRMSG$, 1000)
    Initialize(1, 0)
  endif
END Sub

Sub RenameEntry()
  LOCAl newFile$
  
  newFile$ = GetFileName$("New name")
  if newFile$ <> "" then
    SaveConfig()
    on error skip 1
    rename fullFilename$(index(selected)) AS newFile$
    if MM.ERRNO <> 0 then DisplayMessageError(MM.ERRMSG$, 1000)
    Initialize(1, 0)
  endif
END Sub

Sub CreateDirectory()
  LOCAl newFile$
  
  newFile$ = GetFileName$("Dir name")
  if newFile$ <> "" then
    SaveConfig()
    on error skip 1
    mkdir newFile$
    if MM.ERRNO <> 0 then DisplayMessageError(MM.ERRMSG$, 1000)
    Initialize(1, 0)
  endif
END Sub

Sub Initialize(reinitialize, resetConfig)
  Local i

  If (reinitialize) Then
    f$ = ""
    selected = 1
    top = 1
    totalFiles = 0
    clearDisplayNameW = 0
    clearSizesW = 0
    prev = selected
    keyPressed$ = ""
    If (resetConfig) Then SaveConfig()
    
    For i = 1 To MAX_FILES
      fullFilename$(i) = ""
      displayName$(i) = ""
      sizes$(i) = ""
      types(i) = 0
      index(i) = 0
    Next
  EndIf

  Color HIGHLIGHT_COLOR, BACKGROUND_COLOR
  LoadFiles()
  CLS
  DrawWindow()
  DrawSelection(selected, selected)
  FRAMEBUFFER COPY F, N
End Sub

' ==============================
'       INITIALIZATION
' ==============================
FRAMEBUFFER CREATE
FRAMEBUFFER WRITE F
Initialize(0, 0)

' ==============================
'       MAIN LOOP
' ==============================
mainLoop:
  keyPressed$=Inkey$
  If keyPressed$ = "" Then GoTo mainLoop
  
  If Asc(keyPressed$) = ESC Then
    FRAMEBUFFER WRITE N
    CLS
    End
  ELSEIf Asc(keyPressed$) = BACK Then
    If Len(Cwd$) > 3 Then
      Chdir ".."
      Initialize(1, 1)
    End If
  ELSEIf Asc(keyPressed$) = RETURN1 Or Asc(keyPressed$) = RETURN2 Then
    ExecuteFile()
  ELSEIF Asc(keyPressed$) = DEL1 Or Asc(keyPressed$) = DEL2 Then
    DeleteEntry()
  ELSEIF Asc(keyPressed$) = FUNC1 Then
    CopyEntry()
  ELSEIF Asc(keyPressed$) = FUNC2 Then
    RenameEntry()
  ELSEIF Asc(keyPressed$) = FUNC3 Then
    CreateDirectory()
  ELSEIf Asc(keyPressed$) = DOWN_ARROW Then
    prev = selected
    DrawSelection(prev, -1)
    selected = selected + 1
    
    If selected > totalFiles Then
      selected = 1
      top = 1
      DrawWindow()
    ElseIf selected >= top + MAX_VISIBLE Then ' scroll down if selected moves past visible window
      top = top + 1
      If top > totalFiles - MAX_VISIBLE + 1 Then top = totalFiles - MAX_VISIBLE + 1
      If top < 1 Then top = 1
      DrawWindow()
    EndIf
    
    DrawSelection(prev, selected)
  ElseIf Asc(keyPressed$) = UP_ARROW Then
    prev = selected
    DrawSelection(prev, -1)
    selected = selected - 1
    
    If selected < 1 Then
      selected = totalFiles
      top = selected - MAX_VISIBLE + 1
      If top < 1 Then top = 1
      DrawWindow()
    ElseIf selected < top Then ' scroll up if selection is above visible window
      top = top - 1
      If top < 1 Then top = 1
      DrawWindow()
    EndIf
    
    DrawSelection(prev, selected)
  Else ' Simple search feature
    ' Show help, if "h" is pressed
    if LCase$(keyPressed$) = "h" THEN
      DisplayMessageError("Del=" + CHR$(166) + " F1=Cp F2=Rn F3=Mkdir", 5000)
    ENDIF
    
    If Timer - lastKeyTime > SEARCH_TIMEOUT Then
      searchBuffer$ = ""
    EndIf
    searchBuffer$ = searchBuffer$ + LCase$(keyPressed$)
    lastKeyTime = Timer
    
    For foundPos = 1 To totalFiles
      If LCase$(Left$(fullFilename$(index(foundPos)), Len(searchBuffer$))) = searchBuffer$ Then
        Exit For
      EndIf
    Next foundPos
    
    If foundPos <= totalFiles Then
      prev = selected
      DrawSelection(prev, -1)
      selected = foundPos
      If selected < top Then
        top = selected
      ElseIf selected >= top + MAX_VISIBLE Then
        top = selected - MAX_VISIBLE + 1
        If top < 1 Then top = 1
      EndIf
      DrawWindow()
      DrawSelection(prev, selected)
    EndIf
  EndIf

  Pause 1

  FRAMEBUFFER COPY F, N

  GoTo mainLoop
