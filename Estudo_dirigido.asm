.include m328Pdef.inc
.org 0x0000


;Configurando SP
ldi      r16,LOW(RAMEND)
out      SPL,r16
ldi      r16,HIGH(RAMEND)
out      SPH,r16

rcall    config_timer
rcall    config_adc
rcall    config_pointer

;constantes
clr    r18         ;Registrador para armazenar qtd de aquisições (vai até 32)
ldi    r16,0x9C
mov    r12,r16    ;Número de contagens do timer de delay
ldi    r16,0xf4
mov    r14,r16
ldi    r16,0x02
mov    r15,r16    ;Registradores que guardam o último endereço da RAm antes de reiniciar
clr    r22
clr    r21        ;Registradores para acumular a soma
clr    r23        ;Constante zero pra soma com carry

main_loop:
clr    r16
out    TCNT0,r16  ;Reinicia timer
rjmp   wait_delay

wait_delay:
in   r16,TCNT0
cpse r12,r16  ;Pula se número de contagens tiver chegado em 156
rjmp wait_delay
rjmp start_adc

start_adc:
lds  r16,ADCSRA
ori  r16, (1<<ADSC) ; Seta o bit ADSC para iniciar conversão
sts  ADCSRA,r16

wait_conversion:
lds  r16,ADCSRA
sbrc r16,ADSC
rjmp wait_conversion
lds  r17,ADCH
add  r21,r17
adc  r22,r23
inc  r11
cpi  r18,0x20  ;Compara o registrador da qtd de aquisições com 32
breq average
rjmp start_adc ;Seta o bit ADSC para iniciar uma nova conversão enquanto não cgegar em 32

average:       ;Divide por 32 para calcular a média
clr r16

for:
lsr r22
ror r21
clc
inc r16
cpi r16,0x05
breq save
rjmp for

save:
clr   r18         ;Reinicializa a contagem de aquisições
clr   r21         ;Zera registador que acumula soma
st    X+,R21
cpse  XH,r15
cpse  r23,r23
cpse  XL,r14
cpse  r23,r23
rcall config_pointer
rjmp  main_loop


config_adc:
ldi   r16,0b01_1_0_0011
sts   ADMUX,r16
ldi   r16,0b1_0000_101
sts   ADCSRA,r16
clr   r16
sts   ADCSRB,r16
ret

config_timer:
ldi   r16,0b0000_00_00
out   TCCR0A,r16
ldi   r16,0b000_00_101
out   TCCR0B,r16
ret

config_pointer:
ldi   XL,0x00
ldi   XH,0x01
ret





