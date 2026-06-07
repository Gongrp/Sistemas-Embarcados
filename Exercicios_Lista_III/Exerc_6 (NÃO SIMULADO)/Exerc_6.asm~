;6)Crie um programa em assembly que faça a leitura do sinal proveniente
;de um sensor de temperatura LM35 com 8 bits, conforme o circuito da Figura 2 e
;faça a média simples dos últimos 8 valores medidos (filtro média-móvel sem
;superposição de amostras). De acordo com o valor da média o sistema deve realizar
;as seguintes funções:

;a)Se o valor médio for superior ou igual a 0x15 (aproximadamente 40ºC),
;um cooler deve ser acionado através de um sinal PWM gerado no comparador A do
;timer0 com fator de trabalho de 75%
;(valor do registrador do comparador OCR0A deve ser ajustado em 0xBF – modo fast PWM, non-inverting)

;b)Se o valor médio for inferior a 0x15 (aproximadamente 40ºC) e superior ou igual
;a 0x0F (aproximadamente 30ºC), o cooler deve ser acionado através de um sinal
;PWM com fator de trabalho de 50% (valor do registrador do comparador OCR0A
;deve ser ajustado em 0x80 – modo fast PWM, non-inverting)

;c)Se o valor médio for inferior a 0x0F (aproximadamente 30ºC), o cooler deve ser
;desligado (saída do comparador A do timer0 desconectado ou fator de trabalho
;ajustado em 0%).

;Dica: programe o ADC para operar no modo single convertion com prescaler de 32x.
;Programe o timer0 com prescaler de 32x para ajuste da frequência do PWM.



.include m328Pdef.inc

config:
;configura pilha
ldi    R16,low(RAMEND)
out    SPL,R16
ldi    R16,high(RAMEND)
out    SPH,R16

;constantes iniciais:
ldi    r16,0x08
mov    r12,r16      ;Registra o número de amostras antes de cada média
clr    r18          ;Registrador de amostras coletadas
clr    r19
clr    r20          ;Registradores que acumulam a soma (R20:R19)
clr    r21          ;Registrador auxiliar para soma com carry

rcall  config_pins
rcall   config_adc
rcall   config_pwm

loop:
lds    r16,ADCSRA
ori    r16,(1<<ADSC)
sts    ADCSRA,r16 ;Seta o bit ADSC para iniciar conversão, sem influenciar os outros
rjmp   wait_adc

wait_adc:
lds     r16, ADCSRA
sbrc    r16, ADSC       ;Pula a próxima instrução se ADSC for 0 (terminou)
rjmp    wait_adc        ;Se ainda for 1, continua esperando

lds     r17,ADCH        ;Faz a leitura do valor do ADC
add     r19,r17
adc     r20,r21         ;Acumula resultado
inc     r18
cpse    r18,r12         ;Repete aquisição enquanto não tiver 8 amostras
rjmp    loop
clr     r18             ;Reseta para zero aquisições para próximo loop

average:

lsr     r20
ror     r19
clc
lsr     r20
ror     r19
clc
lsr     r20
ror     r19
clc                     ; Executa divisão por 8. Resultado da média ficará apenas em r19

compare_average:
cpi     r19,0x15
brsh    mode_1
cpi     r19,0x0F
brsh    mode_2
rjmp    mode_3

mode_1:
rcall  enable_comparator     ;Conecta comparador A
ldi    r16,0xBF
out    OCR0A,r16         ;Ativa cooler com duty cycle de 75%
out    PORTB,r16         ;depurador
rjmp   reset

mode_2:
rcall  enable_comparator    ;Conecta comparador A
ldi    r16,0x80
out    OCR0A,r16         ;Ativa cooler com duty cycle de 50%
out    PORTB,r16         ;depurador
rjmp   reset

mode_3:
rcall  disable_comparator    ;Desconecta o comparador A
clr    r16
out    OCR0A,r16
out    PORTB,r16         ;depurador
rjmp   reset


reset:
clr   r19                ;Zera o registrador da média para próximo loop
rjmp loop


config_pins:
;Configura depurador
ldi      R16,0xff
out      DDRB,R16
clr      R16
out      PORTB,R16
;final configuração depurador
ldi      r16,0b0100_0000
out      DDRD,r16       ;Seta PD6 como saída (sinal PWM do cooler)
ret

config_adc:    ;CH.1
ldi      r16,0b01_1_0_0001
sts      ADMUX,r16             ;Configura ADC com referência em VCC, justificado para a esquerda (8 bits) e no ch.1
ldi      r16,0b1_0_0_00_101      ;Dá enable no ADC, mas não inicia conversão e desabilita auto-trigger (modo single-conversion); PS32
sts      ADCSRA,r16
clr      r16
sts      ADCSRB,r16             ;Na prática, não seria necessário configurar o ADSRB no modo single conversion
ret

config_pwm: ;timer0
ldi      r16,0b00_00_00_10
out      TCCR0A,r16            ;Inicia comparador A desabilitado (cooler desligado) e ajusta fast PWM
ldi      r16,0b00000_011       ;Ajusta PS 64
out      TCCR0B,r16
clr      r16
out      OCR0A,r16
ret


enable_comparator:
lds   r16,TCCR0A
ori   r16,(1<<COM0A1)
sts   TCCR0A,r16
ret

disable_comparator:
lds   r16,TCCR0A
ori   r16,(0<<COM0A1)
sts   TCCR0A,r16
ret





