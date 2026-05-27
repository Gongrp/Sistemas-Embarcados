; Exercício - Aula 17 - Interrupções
;
; Nesta atividade, um LED na porta D3 é acionado por um botão na porta D2. Após o botão ser acionado, o led começa a brilhar com luminosidade
; que vai de 0% a 100% aumentando gradtivamente ao longo de 10 s. Após isso desliga e é acionado novamente com um novo aperto do botão. O
; botão deve ser configurado com um interrupt na porta INT0.

.include m328Pdef.inc
.org 0x0000
rjmp	config		; vai para SR config
.org 0x0002			; Criar SR para a ativação da interrupção
rjmp ISR_ext_int0

;.org x0034   ;garante que codigo não sobrepõe nenhum vetor de Interrupt.

config:
;configura pilha
ldi    R16,low(RAMEND)
out    SPL,R16
ldi    R16,high(RAMEND)
out    SPH,R16

;configura constantes iniciais
clr    R16
mov    R10,R16  ; R10 - registrador dedicado a guardar intensidade do LED.
ldi    R16,0x26
mov    R12,R16   ; R12 tempo de espera para avançar rampa de PWM. Para cada rampa duara 10s, cada unidade do counter 2 deve levar 39ms.
				 ; Com PS de 64 são necessários cerca de 9750=x2616 clocks.
clr    R20       ; Define uma contante zero

;configura portas digitais B como saída - depurador
ldi    R16,0xff
out    DDRB,R16
clr    R16
out    PORTB,R16

;configura porta digital D2 - Botão
ldi    R16,0b0000_1_0_00
out    DDRD,R16	     ;configura PD2 com botão e PD3 para a saída de alimentação do led.
ldi    R16,0b0000_0_1_00
out    PORTD,R16     ;configura porta D entrada 2 com o resistor de pullup e define estado do LED em 0

;configura timer0 delay para deboucing
ldi    R16,0b00_00_00_00
out    TCCR0A,R16            ;Configura modo normal = delay
ldi    R16,0b00_00_0_011
out    TCCR0B,R16            ;Configura clk com prescaler de PS64 = 011 ou PS8 = 010.

;configura timer1 delay rampa PWM
ldi    R16,0b00_00_00_00
sts    TCCR1A,R16            ;Configura modo normal (delay padrão)
ldi    R16,0b00_0_00_011
sts    TCCR1B,R16            ;Configura clk com  PS64 = 011 ou PS8 = 010

;configura timer2 pwm - comparador B - PD3
ldi    r16,0b00_10_00_11
sts    TCCR2A,r16            ;Configura modo Fast PWM e saída no modo non-inverting
ldi    r16,0b00000_011
sts    TCCR2B,r16            ;Configura clk com prescaler de PS32 = ~1953 Hz = 011
ldi    r16,0x80
sts    OCR2B, r16            ;configura valor inicial para duty cicle (EX: 0x80 - 50%)

;configura interrupt INT0 (PD2)
ldi    r16, 0x0000_00_10
sts    EICRA,r16            ;configura o INT0 como falling edge
ldi    r16,0x000000_0_1
out    EIMSK,r16            ;habilita o interrupt in INT0
sei                         ;habilita o global interrupt

;inicia loop de espera botao
wait_interrupt:    ; SR para esperar o aperto do botão.
nop
rjmp   wait_interrupt   ;se D2 estiver normal (set) volta para check_buttom.

ISR_ext_int0:      ;interrupt com INT0 em falling edge
clr    r16
out    TCNT0,r16          ; limpa timer0
rjmp   button_debouncing

button_debouncing: ; Espera um tempo para saber se o botão realmente foi apertado - debouncing filter - falling edge.
;espera um tempo de debouncing
in    R16,TCNT0    ;carrega o timer 0.
cpi   R16,0x7D     ;tempo de espera para filtro do botão - deboucing. Com PS de 64, 500 us são necessários 125=x7D clock de timer
brne  button_debouncing ;se diferente volta para button_debouncing.

;se igual, confirma se botão ainda esta apertado
sbic   PIND,2   ; confere D2.
reti   ;se estiver normal volta para wait_interrupt.
rjmp   ramp_pwm

ramp_pwm:
inc    r10    ; Increvementa R10 - nível de intensidade luminosa - duty cycle.
sts    OCR2B,r10    ; envia R10 para duty cicle - comparador
;depurador
out    PORTB,R10
;depurador
cp     r10, r20     ; compara R10 com zero - para saber quando voltar para o inicio.
breq   wait_interrupt                ; se R10 = 0 volta para wait_interrupt
clr    r16                           ;senão, segue com a rampa de pwm
sts    TCNT1H,r16   ;limpa o timer 1H
sts    TCNT1L,r16   ;limpa o timer 1L
rjmp   wait_ramp

wait_ramp:
lds    r16,TCNT1H
lds    r17,TCNT1L   ;carrega timer 1
cp     r16,r12      ;compara com R12
breq   ramp_pwm     ; se igual segue o código para ramp_pwm e increvementar novamente o DC.
rjmp   wait_ramp    ; se diferente volta para wait_ramp
