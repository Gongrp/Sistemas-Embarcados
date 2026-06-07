;2) Monte um programa, após apertado um botão, realiza 4 aquisições de palavras de 8
;bits (4 bits na porta B e 4 bits na porta C), calcula a média aritmética e publica o
;resultado na porta D.

.include "m328Pdef.inc"
.org 0x0000
rjmp config_sp

.org 0X0002
rjmp SR_int0; Vai para a SR de interrupção desencadeada pelo aperto do botão

.org 0x0034; Início do código principal

;Inicializando SP
config_sp:
ldi     r16, LOW(RAMEND)
out     SPL,R16
ldi     r16, HIGH(RAMEND)
out     SPH,R16

;constantes do programa
ldi     r16, 0x7D
mov     r11,r16; Define constante de tempo de delay para debounce do botão (125 contagens com PS de 64 -> 500 mu_s)
ldi     r16, 0b1111_0000
mov     r12,r16; Máscara para extrair apenas os 4 bits superiores com AND

clr     r19
clr     r20    ;Registradores para armazenar a soma acumulada e a média (apenas r19) dos 4 valores
clr     r21    ;Controla a quantidade de valores coletados
clr     r22    ;Constante zero

rcall   config_pins
rcall   config_timer
rcall   config_int

; Fica nesse loop até que o botão seja apertado e ative a interrupção
wait_loop:
nop
rjmp   wait_loop


SR_int0:
clr    r16
out    TCNT0,r16; reseta o timer 0
rjmp   button_delay

button_delay:
in    r16,TCNT0
cpse  r16,r11
rjmp  button_delay
rjmp  button_check

button_check:
sbic  PIND,2
reti        ;Volta para onde a interrupção foi chamada se o botao não estiver mais pressionado
rjmp  button_reset

button_reset:
sbis  PIND,2
rjmp  button_reset
rjmp  get_data; Vai para a SR de receber os valores das portas B e D

get_data:

in r17, PINB
in r18, PIND
;Extrair apenas os valores em PINB(4:7) e PIND(4:7)
and r17,r12
lsr r17
lsr r17
lsr r17
lsr r17; 4 bits shifts para a direita de cada para valores ficarem no byte inferior -> Valor em R18:R17
and r18,r12

sum:
add r17,r18 ;sem chance de ter carry
add r19,r17
adc r20,r22 ; trata o carry

inc r21; Incrementa r21 para contabilizar um novo dado
cpi r21,0x04
breq average; vai para SR da média quando tiver coletado 4 valores
rjmp get_data; Vai para o próximo fator caso contrário

average:
lsr r20
ror r19
clc
lsr r20
ror r19
clc
out PORTC,r19 ;Exibe o resultado na porta C
reti


;config_pins
config_pins:

clr   r16
out   DDRB,R16
out   DDRD,R16; Define todas as portas B e D como entrada
ldi   r16, (1<<PIND2)
out   PORTD,r16; Configura pullup no pino 2 da porta D para o botão (apenas os bits 4:7 das portas B e D serão usados para os vals de entrada)
ser   r16
out   DDRC,R16; Define toda a porta C como saída para exibir os resultados
clr   r16
out   PORTC,R16
ret

;configura timer 0 para debounce botão
config_timer:
ldi    R16,0b00_00_00_00
out    TCCR0A,R16            ;Configura modo normal = delay
ldi    R16,0b00_00_0_011
out    TCCR0B,R16            ;Configura clk com prescaler de PS64 = 011
ret

;configuração do INT0
config_int:
ldi    R16,0b0000_00_10
sts    EICRA,R16             ;configura o INT0 como falling edge
ldi    R16,0b000000_0_1
out    EIMSK,R16             ;habilita o interrupt in INT0
sei
ret







