;5. Elaborar um programa para ler a tensão proveniente de um potenciômetro com o
;ADC do ATmega328p (ver a fig. 1) com 8 bits. Apresente o valor binário na porta
;D. Depois aumente a resolução do ADC para 10 bits e utilize dois pinos adicionais
;da porta B.

;Entrada analógica -> PC0
;Saída em 8 bits -> porta D

.include m328Pdef.inc

config:
;configura pilha
ldi    R16,low(RAMEND)
out    SPL,R16
ldi    R16,high(RAMEND)
out    SPH,R16

rcall config_pins
rcall config_adc


wait_adc:
lds    r16, ADCSRA
sbrs   r16, ADSC         ; Pula e vai para a leitura se conversão estiver sendo realizada
rjmp   wait_adc
rjmp   read_adc


read_adc:
lds    r17,ADCL  ;Leitura sempre começa por ADCL!
lds    r18,ADCH
out    PORTD,r17 ;Exibe 8 primeiros bits na porta D
out    PORTB,r18 ;Exibe os 2 últimos bits nos pinos (B1:B0)

rjmp wait_adc    ;Retorna para nova conversão e leitura


config_pins:
; Pino do ADC (PC0 não deve ser configurada como entrada!)
ser     r16
out     DDRD,r16
out     DDRB,r16 ;Configura portas D e B para exibir leitura do ADC (primeiro apenas na D com 8 bits, depois com 2 da B)
clr     r16
out     PORTD,r16
out     PORTB,r16;Inicia com saídas nas portas B e D zeradas
ret

config_adc:
ldi     r16,0b01_0_0_0000     ;Configura ADC com referência em VCC, justificado para a direita (10 bits) e no ch.0
sts     ADMUX,r16
ldi     r16,0b1_1_1_0_0_110   ;Habilita ADC, inicia conversão, configura autotrigger e PS64
sts     ADCSRA,r16
ldi     r16,0b00000_000       ;Configura modo free-running
sts     ADCSRB,r16
ret
