; 
;    This example does not use the common control library as it only uses the standard controls
; 

    include \masm32\include\masm32rt.inc
    include \masm32\include\dialogs.inc

    dlgproc PROTO :DWORD, :DWORD, :DWORD, :DWORD
    GetTextDialog PROTO :DWORD, :DWORD, :DWORD

    .data?
      hInstance dd ?

    .code


start:
    mov hInstance, rv(GetModuleHandle, NULL)
    call main
    invoke ExitProcess, eax


main proc

    LOCAL firstDigit  : DWORD
    LOCAL secondDigit : DWORD

    invoke InitCommonControls

    mov firstDigit, rv(GetTextDialog, "Two digits sum", "Enter first digit", NULL)

    .if firstDigit != 0
      invoke atodw, firstDigit
      mov firstDigit, eax

      .if firstDigit >= 0 && firstDigit <= 9
        mov secondDigit, rv(GetTextDialog, "Two digits sum", "Enter second digit", NULL)

        .if secondDigit != 0
          invoke atodw, secondDigit
          mov secondDigit, eax

          .if secondDigit >= 0 && secondDigit <= 9
            xor eax, eax
            mov eax, firstDigit
            add eax, secondDigit
            
            fn MessageBox, 0, str$(eax), "Result", MB_OK
          .else
            fn MessageBox, 0, "Second digit is invalid", "Error", MB_ICONERROR
          .endif
        .endif
      .else
        fn MessageBox, 0, "First digit is invalid", "Error", MB_ICONERROR
      .endif
    .endif

    invoke GlobalFree, firstDigit
    invoke GlobalFree, secondDigit

    ret

main endp


GetTextDialog proc dgltxt:DWORD, grptxt:DWORD, iconID:DWORD

    LOCAL arg1[4] : DWORD
    LOCAL parg    : DWORD

    lea eax, arg1
    mov parg, eax

  ; ---------------------------------------
  ; load the array with the stack arguments
  ; ---------------------------------------
    mov ecx, dgltxt
    mov [eax], ecx
    mov ecx, grptxt
    mov [eax+4], ecx
    mov ecx, iconID
    mov [eax+8], ecx

    Dialog "Get User Text", \               ; caption
           "Arial", 8, \                    ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            5, \                            ; number of controls
            50, 50, 292, 80, \              ; x y co-ordinates
            4096                            ; memory buffer size

    DlgIcon   0, 250, 12, 299
    DlgGroup  0, 8, 4, 231, 31, 300
    DlgEdit   ES_LEFT or WS_BORDER or WS_TABSTOP, 17, 16, 212, 11, 301
    DlgButton "Next", WS_TABSTOP, 8, 42, 100, 13, IDOK
    DlgButton "Exit", WS_TABSTOP, 110, 42, 50, 13, IDCANCEL

    CallModalDialog hInstance, 0, dlgproc, parg

    ret

GetTextDialog endp


dlgproc proc hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD

    LOCAL tlen  : DWORD
    LOCAL hMem  : DWORD
    LOCAL hIcon : DWORD

    switch uMsg
      case WM_INITDIALOG
      ; -------------------------------------------------
      ; get the arguments from the array passed in lParam
      ; -------------------------------------------------
        push esi
        mov esi, lParam
        fn SetWindowText, hWin, [esi]                           ; title text address
        fn SetWindowText, rv(GetDlgItem, hWin, 300), [esi+4]    ; groupbox text address
        mov hIcon, rv(LoadIcon, NULL, IDI_QUESTION)             ; use default system icon
        pop esi

        fn SendMessage, hWin, WM_SETICON, 1, hIcon
        invoke SendMessage, rv(GetDlgItem, hWin, 299), STM_SETIMAGE, IMAGE_ICON, hIcon
        xor eax, eax
        ret

      case WM_COMMAND
        switch wParam
          case IDOK
            mov tlen, rv(GetWindowTextLength, rv(GetDlgItem, hWin, 301))
            .if tlen == 0
              invoke SetFocus, rv(GetDlgItem, hWin, 301)
              ret
            .endif
            add tlen, 1
            mov hMem, alloc(tlen)
            fn GetWindowText, rv(GetDlgItem, hWin, 301), hMem, tlen
            invoke EndDialog, hWin, hMem
          case IDCANCEL
            invoke EndDialog, hWin, 0
        endsw
      case WM_CLOSE
        invoke EndDialog, hWin, 0
    endsw

    xor eax, eax
    ret

dlgproc endp


end start
