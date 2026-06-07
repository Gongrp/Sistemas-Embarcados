;Monte um código que obtém uma palavra de 8 bits na porta D e guarda na memória
;RAM de forma sequencial do primeiro endereço até o último, com os seguintes
;gatilhos

;a) apertando um botão (ex.:PB0)

;b)a cada 10 ms usando um timer

.include "m328Pdef.inc"

.cseg
.org 0x00

; Configuração do Stacker Pointer -> Define o SP no final da memória SRAM x08ff
ldi	R16,LOW(RAMEND)
out	SPL,R16
ldi	R16,HIGH(RAMEND)
out	SPH,R16

; Configuração do registrador X com o endereço 0x0100 (início da memória de dados)
ldi XL,LOW(SRAM_START)
ldi XH,HIGH(SRAM_START)

rcall config_pins;
rcall config_timers;

;constantes iniciais
ldi     r16, 0x7d
mov     r11,r16; num de contagens para delay do botão -> com PS64 para delay de 500 mu_s

wait:
sbic    PINB,0
rjmp    wait
clr     r16
out     TCNT0,R16       ;zera timer
rjmp    filter_delay    ;Parte para SR de debounce se pino 0 estiver apertado (LOW)


filter_delay:
in      r16,TCNT0
cpse    r16,r11
rjmp    filter_delay
rjmp    filter_confirm

filter_confirm:
sbic    PINB,0   ;Confere se botão segue apertado, pula se estiver
rjmp    wait     ;volta ao loop inicial
rjmp    filter_reset

filter_reset:
sbis    PINB,0; Espera botão ser solto
rjmp    filter_reset
rjmp    store_data; Pula para SR de armazenar valor da porta D

store_data:
in      r17,PIND  ;salva valores de entrada da porta D
st      X+,r17    ;guarda valor de r17 no endereço da memória armazenado em X e o incrementa em uma unidade
rjmp wait         ;retorna ao loop original



;config_pins
config_pins:
clr     r16
out     DDRD,r16; define porta D inteira como input
ldi     r16,(0<<PINB0)
out     DDRB,r16; define pino B0 como input (botão)
ldi     r16,(1<<PINB0)
out     PORTB, r16; configura pullup no pino B0
ret

;config_timers
config_timers:

;configura timer0 - delay do botão
ldi   r16,0b0000_0000
out   TCCR0A,r16
ldi   r16, 0b00_0_00_010 ; Define PS de 8 (010) ou 64 (011)
out   TCCR0B, r16

ret


