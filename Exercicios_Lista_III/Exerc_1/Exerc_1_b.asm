;Monte um código que obtém uma palavra de 8 bits na porta D e guarda na memória
;RAM de forma sequencial do primeiro endereço até o último, com os seguintes
;gatilhos


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

;constantes iniciais
ldi     r16,0x9c
mov     r11,r16; 156 (0x9C) é o num de contagens para delay entre salvamentos -> com PS1024 para delay de 10ms

rcall config_pins;
rcall config_timers; Após chamado já inicia o timer

wait_delay:
in      r16,TCNT0
cpse    r16,r11
rjmp    wait_delay; retorna para início enquanto não tiver passado o delay
rjmp    store_data; vai para SR de salvamento quando terminar o delay


store_data:
in      r17,PIND  ;salva valores de entrada da porta D
st      X+,r17    ;guarda valor de r17 no endereço da memória armazenado em X e o incrementa em uma unidade
clr     R16
out     TCNT0,R16 ;zera timer para iniciar novo delay
rjmp    wait_delay;retorna ao delay inicial


;config_pins
config_pins:
clr     r16
out     DDRD,r16; define porta D inteira como input
ret

;config_timers
config_timers:
;configura timer0 - delay
ldi   r16,0b0000_0000
out   TCCR0A,r16
ldi   r16, 0b00_0_00_101 ; Define PS de 1024 (101)
out   TCCR0B, r16
ret


