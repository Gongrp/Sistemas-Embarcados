

.include "m328pdef.inc" ; Define device ATmega328P
.list

.dseg
.org SRAM_START


.cseg
.org 000000

;Configurando port D no modo entrada e incializando r20

ldi r20, 0x00;
out ddrd, r20;

ldi r19, 0xff;
out ddrb, r19;

; WHILE
WHILE:  inc r20;
        out pinb, r20;
        in r21, pind;
        cpi r21, 0x00;
        breq loop;
        rjmp while;


; LOOP
LOOP:  nop
       rjmp	LOOP


