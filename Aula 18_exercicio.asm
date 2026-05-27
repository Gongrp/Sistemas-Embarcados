; Exercício - Aula 18 - PWM
;
; Nesta atividade, um LED na porta B3 é acionado por um botão na porta B4. Após o botão ser acionado, o led começar a brilhar com luminosidade
; que vai de 0% a 100% aumentando gradativamente ao longo de 10 s. Após isso desliga e é acionado novamente com um novo aperto do botão.

.include m328Pdef.inc
.org 0x0000
rjmp	inicio		;vai para SR inicio

inicio:
;configura pilha
ldi    R16,low(RAMEND)
out    SPL,R16
ldi    R16,high(RAMEND)
out    SPH,R16
;chama subrotinas de configuração
call   config_pin
call   config_tim_delay
call   config_pwm
;define constantes iniciais
clr    R16
mov    R10,R16  ; R10 é o registrador dedicado a guardar intensidade do LED.
ldi    R16,0x7D
mov    R11,R16  ; R11 tempo de espera para filtro do botão - deboucing. Com PS de 64, 500 us são necessários 125=x7D clock de timer.
ldi    R16,0x26
mov    R12,R16   ;R12 tempo de espera para avançar a rampa de PWM. Para cada rampa durar 10s, cada unidade do counter 2 deve levar 39ms, com PS de 64 são necessários cerca de 9843=x2673 clocks.
clr    R20       ;Define uma contante zero
rjmp   check_buttom

check_buttom:    ; SR para esperar o aperto do botão.
sbic   pinb,4     ; Confere o pino B4.
rjmp   check_buttom   ;se B4 estiver normal (set) volta para check_buttom.
clr    R16            ;se B4 estiver apertado (clear) segue o código.
out    TCNT0,R16      ;zera o timer (vai estar rodando desde a definição do prescaler)
rjmp   buttom_delay

buttom_delay: ; Espera um tempo para saber se o botão realmente foi apertado - deboucing filter.
in    R16,TCNT0    ;carrega o timer 0.
cpse  R16, R11     ;compara com R11.
rjmp  buttom_delay ;se diferente volta para buttom_delay.
rjmp  confirm_buttom  ;se igual vai para wait_buttom.

confirm_buttom: ; confirma de B4 ainda esta apertado.
sbic   pinb,4   ; confere B4.
rjmp   check_buttom   ;se estiver normal volta para check_buttom.
rjmp   wait_buttom    ;se estiver apertado segue o código.

wait_buttom:   ; espera botão ser solto
sbis   pinb,4   ; confere B4.
rjmp   wait_buttom  ;se ainda estiver apertado volta para wait_buttom e espera o botão ser solto.
rjmp   ramp_pwm   ;se estiver normal (set) segue o código.

ramp_pwm:
inc   r10         ; Increvementa R10 - nível de intensidade luminosa - duty cycle.
sts   OCR2A,r10    ; envia R10 para duty cicle - comparador
;Inicio depurador
mov    R16,R10
out    PORTD,R16; mostra o valor do comparador na porta D
;final depurador
cpi   r10,0x00     ; compara R10 com zero - para saber quando voltar para o inicio.
breq   check_buttom  	  ; se R10 = 0 volta para check_buttom
clr r16
sts TCNT1L, r16    ;limpa o timer 1
sts TCNT1H, r16
rjmp wait_ramp

wait_ramp:
lds r17, TCNT1L
lds r18, TCNT1H   ;carrega timer 1
cpse   r18,r12     ;compara com R12
rjmp   wait_ramp   ; se diferente volta para wait_ramp
rjmp   ramp_pwm    ; se igual segue o código para ramp_pwm e increvementar novamente o DC.

;Rotinas de Configuração

config_pin:
;Configura depurador
ldi    R16,0xff
out    DDRD,R16
clr    R16
out    PORTD,R16
;final configuração depurador
ldi    R16,0b000_0_1000
out    DDRB,R16	     ;configura PB4 com botão e PB3 como saída para o PWM.
ldi    R16,0b000_1_0000
out    PORTB,R16     ;configura porta de entrada 4 como pullup.
ret

config_tim_delay:
;configura timer 0 - delay para deboucing do botão
ldi    R16,0b00_00_00_00
out    TCCR0A,R16            ;Configura modo normal = delay
ldi    R16,0b00_00_0_010
out    TCCR0B,R16            ;Configura clk com prescaler de PS64 = 011 ou PS8 = 010.
ldi    R16,0x00
;configura timer 1 - Delay ramp
ldi    R16,0b00_00_00_00
sts    TCCR1A,R16            ;Configura modo normal
ldi    R16,0b00_0_00_011
sts    TCCR1B,R16            ;Configura clk com  PS64 = 011 ou PS8 = 010
ret

config_pwm:
ldi    R16,0b10_00_00_11
sts    TCCR2A,R16            ;Configura modo FPWM
ldi    R16,0b00_0_00_011
sts    TCCR2B,R16            ;Configura clk com prescaler de 256 = ~240Hz = 110 ou PS64 = ~1450 Hz = 011
ldi    R16,0x80              ;Configura valor de comparação em 0d128 -> Duty cycle de 128/256 = 50%
sts    OCR2A,R16
ret
