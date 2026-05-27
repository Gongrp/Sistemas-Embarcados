; Aula 21 - Conversor A/D - Exercício


; Nesta atividade, um botão configurado com interrupt INT0 inicia uma rampa de incremento de luminosidade de LED. O tempo para a rampa ser
; executada vai de zero a 17s e será controlado por um potenciômetro externo conectado a uma porta do ADC.


.include m328Pdef.inc
.org 0x0000
rjmp	config		;vai para SR config
.org 0x0002
rjmp    ISR_ext_int0

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
clr    R20       ;Define uma contante zero

;configura portas digitais B como saida - depurador
ldi    R16,0xff
out    DDRB,R16
clr    R16
out    PORTB,R16; Inicializa todos os pinos em 0

;configura porta digital D2 - Botão
ldi    R16,0b00_00_00_00
out    DDRD,r16	     ;configura PD2 com botão.
ldi    r16,0b00000_1_00
out    PORTD,r16    ;configura porta D entrada 2 como pullup.

;configura timer0 delay para deboucing
ldi    R16,0b00_00_00_00
out    TCCR0A,R16            ;Configura modo normal = delay
ldi    R16,0b00_00_0_010
out    TCCR0B,R16            ;Configura clk com prescaler de PS64 = 011 ou PS8 = 010.

;configura timer1 delay rampa PWM
ldi    R16,0b00_00_00_00
sts    TCCR1A,R16            ;Configura modo normal
ldi    R16,0b00_00_0_011
sts    TCCR1B,R16            ;Configura clk com  PS64 = 011

;configura timer2 pwm - comparador B - PD3
ldi    r16, 0b10_10_00_11
sts    TCCR2A,R16            ;Configura modo FPWM
ldi    r16, 0b00_0_00_110
sts    TCCR2B,R16            ;Configura clk com prescaler de 256 = ~240Hz = 110 ou PS32 = ~1450 Hz = 011
ldi    R16,0x80
sts    OCR2B,r16             ;configura valor inicial para duty cicle

;configura interrupt INT0
ldi    R16,0b0000_00_10
sts    EICRA,R16             ;configura o INT0 como falling edge
ldi    R16,0b000000_0_1
out    EIMSK,R16             ;habilita o interrupt in INT0
sei

;configura ADC
ldi    r16,0b01_1_0_0001
sts    ADMUX,r16             ; configura Vref = Vcc, Justifica para esquerda (8bits), Mux no ch 1.
ldi    r16,0b1_1_1_00_101
sts    ADCSRA,r16           ; configura ADC on, inicia conversão no ADSC, usa autotrigger, e prescaler 32x
ldi    r16,0b0_0_000_000
sts    ADCSRB,r16            ; configura autotrigger em free running

;inicia loop de espera botão
wait_interrupt:    ; SR para esperar o aperto do botão.
nop
rjmp   wait_interrupt   ;se D2 estiver normal (set) volta para check_buttom.

ISR_ext_int0:      ;interrupt com INT0 em falling edge
clr    R16
out    TCNT0,R16         ; limpa timer0
rjmp   buttom_debouncig

buttom_debouncig: ; Espera um tempo para saber se o bot?o realmente foi apertado - deboucing filter - falling edge.
;espera um tempo de deboucing
in    R16,TCNT0    ;carrega o timer 0.
cpi   R16,0x7D     ;tempo de espera para filtro do botão - deboucing. Com PS de 64, 500 us são necessários 125=x7D clock de timer
brne  buttom_debouncig ;se diferente volta para buttom_debouncing.
;confirma se botão ainda esta apertado
sbic   PIND,2   ; confere D2.
reti   ;se estiver normal volta para wait_interrupt.
rjmp   read_adc

read_adc:
ldi    r17,ADCL
ldi    r17,ADCH     ;nesse caso damos overwrite pois só consideraremos os 8 bits mais significativos (ADC9:2)
lsr    R17          ; divide adc por 2
lsr    R17          ; divide adc por 2 - para ajustar a escala ADC = 0 --> tempo 0 e ADC = 256 --> tempo = 64 --> 0x40 = ~17s na comparação
; high e com PS de 64 do timer 1
rjmp   ramp_pwm

ramp_pwm:
inc   R10         ; Increvementa R10 - nível de intensidade luminosa - duty cycle.
sts   OCR2B,R10    ; envia R10 para duty cicle - comparador
;depurador
out    PORTB,R10
;depurador
cpse   R10,R20     ; compara R10 com zero - para saber quando voltar para o inicio.
cpse   R10,R10     ;
reti               ; se R10 = 0 volta para wait_interrupt
clr    r16
sts    TCNT1H,r16   ;limpa o timer 1H
sts    TCNT1L,r16     ;limpa o timer 1L
rjmp  wait_ramp

wait_ramp:
lds   R16,TCNT1L
lds   R16,TCNT1H  ; carrega timer 1
cp    R16,R17      ; tempo de espera para avançar rampa de PWM.
breq  ramp_pwm     ; se igual segue o código para ramp_pwm e incrementar novamente o DC.
rjmp  wait_ramp   ; se diferente volta para wait_ramp
