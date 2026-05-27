; Exemplo - Aula 12 - Portas digitais

; Programa para leitura dos dados das portas B e D, soma entre eles e seta o pino 0 da porta C caso a soma for superior a 100.

.include "m328Pdef.inc"

.cseg
.org 0x0000

ldi  R16,low(RAMEND)
out  SPL,R16
ldi  R16,high(RAMEND)
out  SPH,R16
call conf_DPorts
rjmp main

main:
call read_DPorts
call soma
brcs write_one
cpi  R16,0x64
brsh write_one
call write_zero
rjmp main

conf_DPorts:
clr	  R16          ; Zera o R16
out 	DDRB,R16     ; Configura porta B como entrada
out 	DDRD,R16     ; Configura porta D como entrada
ser 	R16          ; Coloca em 1 os bits do R16
out 	PORTB,R16    ; Aciona os resitores de Pull-up da porta B
out 	PORTD,R16    ; Aciona os resitores de Pull-up da porta D
sbi 	DDRC,0       ; Configura pino 0 da porta C como saída
ret

read_DPorts:
in	R16,PINB
in 	R17,PIND
ret

soma:
add  R16,R17
ret

write_one:
sbi  PORTC,0
rjmp main

write_zero:
cbi  PORTC,0
ret


