;
; ***********************************
; * (Add program task here)         *
; * (Add AVR type and version here) *
; * (C)2021 by Gerhard Schmidt      *
; ***********************************
;
.nolist
.include "m328pdef.inc" ; Define device ATmega328P
.list
;

.cseg
.org 000000

;Operação: 1,5 ∙ 0,75 + 3 . (0,25) = 1,875 (Tudo sem sinal, não precisa se preocupar com C2)

;I)Primeiro produto (1,5.0,75 = 1,125)
ldi        R16, 0xC0;
ldi        R17, 0x60;
fmul       R16,R17;
movw       R2,R0;  Salvando ambos os bits do produto em R3:R2

;II)Segundo produto  (3.0,25 = 0,75)
ldi         R18, 0x20;
ldi         R19, 0x80; LSB de 0d3 (1 x 2^0 = 1)
ldi         R20, 0x01; MSB de 0d3 (1 x 2^1 = 2)
fmul        R19, R18;
movw        R4,R0;  (R5:R4 < - Resultado da multiplicação 1 x 0,25)
fmul        R20,R18;
add         R5, R0;
clr         R6;
adc         R6,R1; Produto final em R6:R5:R4 (R5 está no mesmo nível que R3 do outro termo)

;III) Somando os dois termos em R6:R5 (1,125 + 0,75 = 1,875 (F0))
add         R5, R3;
clr         R7;
adc         R6, R7;







Loop:
	rjmp loop
;
; End of source code
;
; (Add Copyright information here, e.g.
; .db "(C)2021 by Gerhard Schmidt  " ; Source code readable
; .db "C(2)20 1ybG reahdrS hcimtd  " ; Machine code format
;
