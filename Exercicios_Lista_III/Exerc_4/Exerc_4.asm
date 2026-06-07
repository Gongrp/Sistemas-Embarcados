;4. Monte um programa que gere um PWM na saída OC0A, cuja frequência pode ser
;selecionada de forma externa em 4 diferentes opções, utilizando para isso os pinos
;PB0 e PB1 e os pinos PB2:5 para escolher o Duty Cicle com 4 bits de resolução.

.include "m328Pdef.inc"

.cseg
.org 0x0000

;Configuração do Stacker Pointer -> Define o SP no final da memória SRAM x08ff
ldi	R16,LOW(RAMEND)
out	SPL,R16
ldi	R16,HIGH(RAMEND)
out	SPH,R16

;Constantes
ldi   r16,0x02 ;
mov   r13,r16  ;Valor que será somado ao input de frequência para ajustar o Prescaler (00 -> 010 (8) ; 01 -> 011 (64) ; ...)
ldi   r17,0x11          ;Carrega r17 com 17
rcall config_pins
rcall config_pwm

;Registar valor inicial de PINB
in    r18,PINB

read_inputs:
in    r16,PINB
cpse  r16,r18
rjmp  adjust_params ;Se houver diferença no valor anterior de PINB e no detectado, muda a configuração do PWM
rjmp  read_inputs   ;Se for igual ao anterior, não ajusta de novo, continua conferindo

adjust_params:

;Ajuste de Duty Cycle
mov   r20,r16
andi  r20,0b00_1111_00  ;Máscara mantém apenas os bits de configuração do Duty cycle (PB2:PB5)
lsr   r20
lsr   r20               ;Alinha o final com o bit zero (0:3)
mul   r20,r17           ;Ao multiplicar um valor em resolução de 4 bits por d17, chegamos a um valor em resolução de 8 bits -> 15 x 17 = 255)
;O valor do ajuste estará armazenado em (R1:R0). Como terá no máximo 8 bits (255), na verdade apenas R0
mov   r20,r0

;Ajuste de frequência
mov   r19,r16
andi  r19,0b00_0000_11  ;Máscara mantém apenas os bits (PB0:PB1)
add   r19,r13           ;Soma com constante (10) para converter da seleção de input direto pro código de PS correspondente


set_parameters:
out  TCCR0B,r19        ;Configura frequência (opções de PS 8, 64, 256 e 1024)
out  OCR0A,r20          ;Configura duty cycle (0-255)
mov  r18,r16           ;Registra novo ajuste como ajuste anterior para comparar no próximo ciclo
rjmp read_inputs       ;Reinicia ciclo

config_pins:
clr   r16
out   DDRB,r16; Configura toda a porta B como entrada
ret

config_pwm:
;configurando timer 0
ldi   r16,0b10_00_00_11
out   TCCR0A,r16          ;Configura modo FPWM e saída no modo não inversor no comparador A
ldi   r16,0b00000_001
out   TCCR0B,r16          ;Começa com PS de 1 -> f_pwm = 16kHz / 255 ~ 62,7kHz
ldi   r16,0x80
;out   OCR0A,r16           ;Inicia valor do comparador em 50%
ret



