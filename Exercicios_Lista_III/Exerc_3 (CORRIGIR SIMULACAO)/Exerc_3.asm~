;3. Monte um programa que faz aquisição continua da porta D (8 bits) a cada 1 ms, e
;calcula a média móvel dos últimos 8 dados, apresentando o resultado de 8 bits nas
;porta B (4 bits) e porta D (4 bits).

.include "m328Pdef.inc"
.org 0x00

.equ RAMSTART = 0X0100

;configurando SP
ldi R16,LOW(RAMEND)
out	SPL,R16
ldi	R16,HIGH(RAMEND)
out	SPH,R16

; Configuração do registrador X no início da SRAM
ldi XL,low(RAMSTART)
ldi XH,high(RAMSTART)

; Configuração do registrador Y também no início da SRAM (percorrer os valores na hora da soma)
ldi YL,low(RAMSTART)
ldi YH,high(RAMSTART)

;constantes iniciais e registradores
ldi   r16,0xFA
mov   r12,r16    ;250 contagens com PS64 para delay de 1ms

ldi   r16,0x08
mov   r13,r16    ;Constante oito para contagens

clr   r18        ;Constante zero para soma com carry e para zerar

clr   r19
clr   r20        ;Registradores para acumular a soma (R20:R19)

clr   r21        ;registrador para armazenar a quantidade de valores somados
clr   r22        ;registrador para armazenar a quantidade de divisões por 2




rcall config_pins
rcall config_timer

;Dá clear em todos os endereços da RAM de 0x0100 até 0x0107
clear_ram:
st    X+,r18
cpse  XL,r13
rjmp  clear_ram
ldi   XL, 0x00; Reseta para início da RAM
rjmp  delay; Inicia código principal


delay:
in    r16,TCNT0
cpse  r16,r12
rjmp  delay
rjmp  get_data

get_data:
in    r17,PIND
st    X+,r17            ;Salva o valor de r17 de forma indireta
cpse  XL,r18            ;Confere se o próximo valor seria armazenado em 0x0108, para reiniciar para a posição do primeiro
rjmp  sum               ;Se não, pula direto para a soma
ldi   XL,low(RAMSTART) ;Reinicia endereçamento no começo da RAM
rjmp  sum

sum:
ld   r16,Y+             ;Resgata o primeiro valor na RAM e incrementa o apontador Y
add  r19,r16
adc  r20,r18 ;Tratamento do carry
inc  r21
cpse r21,r13 ;Confere se já foram somados 8 valores
rjmp sum
rjmp average; Se já tiver chegado em 8 somas, vai para calcular a média

average:
lsr    r20
ror    r19
clc
inc    r22
cpi    r22,0x03
breq   show_result; se já tiver dividido por 2 3x vai para SR de exibir resultado
rjmp   average

show_result:
mov    r16,r19
andi   r16, 0b0000_1111
out    PORTB,r16          ;Filtra os 4 bits menos significativos do resultado e exibe na porta B

mov    r16,r19
andi   r16, 0b1111_0000
lsr    r16
lsr    r16
lsr    r16
lsr    r16             ;4 bit shifts para a direita para ficar nos 4 bits menos significativose exibir na porta C
out    PORTC,r16
;Obs.: Leitura do resultado de 8 bits -> PORTC(3:0):PORTB(3:0)
rjmp reset

reset:
;reseta os registradores de contagem
clr    r21
clr    r22
;reseta registradores da soma
clr    r19
clr    r20
;reseta o LSB do apontador do valor a ser somado
ldi    YL, 0x00
;reseta timer
clr    r16
out    TCNT0,r16
rjmp   delay; parte para a espera antes de registrar um novo valor



config_pins:
clr   r16
out   DDRD,R16
out   PIND,R16
ser   r16
out   DDRB,R16
out   DDRC,R16
clr   r16
out   PORTB,R16
out   PORTC,R16
ret

config_timer:
;timer_0 para delay entre cada aquisição
clr   r16
out   TCCR0A,r16; função normal de delay
ldi   r16,0b00000_011; PS de 64 (011)
out   TCCR0B,r16
ret
