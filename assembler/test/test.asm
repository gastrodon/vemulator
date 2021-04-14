;main:
    lxi b,0xfdfd    ; load a pretty number into BC
    ldax b          ; load BC into A for some reason
                    ; even though A is 8 bytes and BC is 16
    inr b
    mov b,a         ; slide to the left
    mvi b,0xcc      ; criss cross
