; Botao com interrupt INT0 liga um LED durante um tempo de 5s
;A intensidade do led é controlada por um potenciômetro conectado a uma porta ADC
.include "m328pdef.inc"
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
ldi    R16,0x99
mov    R10,r16   ;Duas contagens de 39168(0x9900) ~ 78125 incrementos de 64 microssegundos (CLK com PS 1024) = 5 segundos
clr    R20       ;Define uma contante zero

;configura portas digitais D2 (Botão) e B3 (LED)
clr    r16
out    DDRD,R16	     ;configura PD2 como entrada
ldi    r16,0b0000_1_000
out    DDRB,R16      ;configura PB3 como saída
ldi    R16,0b0000_0_1_00
out    PORTD,R16     ;configura porta D entrada 2 como pullup.
clr    r16
out    PORTB,r16;Inicia com LED desligado

;configura timer0 delay para deboucing
ldi    R16,0b00_00_00_00
out    TCCR0A,R16            ;Configura modo normal = delay
ldi    R16,0b00_00_0_011
out    TCCR0B,R16            ;Configura clk com prescaler de PS64 = 011

;configura timer1 delay PWM led
ldi    R16,0b00_00_00_00
sts    TCCR1A,R16            ;Configura modo normal (delay fixo)
ldi    R16,0b00_0_00_101
sts    TCCR1B,R16            ;Configura clk com  PS1024 = 101

;configura timer2 pwm - comparador A - PB3
ldi    R16,0b10_00_00_11
sts    TCCR2A,R16            ;Configura modo FPWM
ldi    R16,0b00_0_00_110
sts    TCCR2B,R16            ;Configura clk com prescaler de 256 = ~240Hz = 110 ou PS32 = ~1450 Hz = 011
ldi    R16,0x80
sts    OCR2A,R16             ;configura valor inicial para duty cicle (ajustado com potenciometro)

;configura interrupt INT0
ldi    R16,0b0000_00_10
sts    EICRA,R16             ;configura o INT0 como falling edge
ldi    R16,0b000000_0_1
out    EIMSK,R16             ;habilita o interrupt in INT0
sei

;configura ADC
ldi    R16,0b01_1_0_0000
sts    ADMUX,R16             ; configura Vref = Vcc, Justifica para esquerda (8bits), Mux no ch 0 (ADC0 - A0).
ldi    R16,0b1_1_1_00_000
sts    ADCSRA,R16            ; configura ADC on, inicia conversão no ADSC, usa autotrigger, e fator de divisão 1
ldi    R16,0b00000_000
sts    ADCSRB,R16            ; configura autotrigger em free running

;inicia loop de espera botão
wait_interrupt:    ; SR para esperar o aperto do botão.
nop     ; Confere o pino D2.
rjmp   wait_interrupt   ;se D2 estiver normal (set) volta para check_buttom.

ISR_ext_int0:      ;interrupt com INT0 em falling edge
clr    R16
out    TCNT0,R16         ; limpa timer0
rjmp   button_debouncing

button_debouncing: ; Espera um tempo para saber se o botao realmente foi apertado - deboucing filter - falling edge.
;espera um tempo de deboucing
in    R16,TCNT0    ;carrega o timer 0.
cpi   R16,0x7D     ;tempo de espera para filtro do botão - deboucing. Com PS de 64, 500 us são necessários 125=x7D clock de timer
brne  button_debouncing ;se diferente volta para button_debouncing.
;confirma se botão ainda esta apertado
sbic   PIND,2   ; confere D2.
reti   ;se estiver normal volta para wait_interrupt.
rjmp   read_adc

read_adc:
lds    R18,ADCL
lds    R18,ADCH     ; ler adc high; estamos usando apenas os 8 bits mais significativos
;Salva o valor lido no comparador do timer 2 PWM (define o duty cycle do LED)
sts    OCR2A,R18
rcall  clear_timer_1
rjmp   led_delay_1

led_delay_1:    ;mantém o LED aceso com a intensidade lida pelo ADC por 2,5 segundos
lds   R16,TCNT1L   ; carrega timer 1
lds   R16,TCNT1H
cpse  R16,R10
rjmp  led_delay_1     ;Se o MSB não for igual, reinicia o loop
rcall clear_timer_1
rjmp  led_delay_2

led_delay_2:  ;mantém o LED aceso por mais 2,5 segundos
lds   R16,TCNT1L   ; carrega timer 1
lds   R16,TCNT1H
cpse  R16,R10
rjmp  led_delay_2     ;se não forem iguais, segue contagem no loop
;Se der o segundo match - completo delay de ~5s
clr   r18
sts   OCR2A,R18    ;Ajusta o duty cycle do LED pra 0 (desligado)
reti               ;Volta para a subrotina de espera botão


clear_timer_1: ;Função para resetar timer 1
clr   R16
sts   TCNT1H,R16    ;limpa o timer 1H
sts   TCNT1L,R16     ;limpa o timer 1L
ret




