CSEG at 0h
LJMP init

ORG 000Bh
LJMP isr_timer0

ORG 0100h
init:
MOV R0, #0d
MOV TMOD, #00000010b
MOV TL0, #0d
MOV TH0, #0d
SETB IT0
SETB TR0
SJMP haupt

haupt:
JNB P1.0, haupt
CLR TR0
LCALL anzeigen
LCALL einlesen

anzeigen:
LCALL zufall
MOV A, R0
ANL A, #00001111b
MOV DPTR, #tabelle
MOVC A, @A+DPTR
MOV P0, A
LCALL warte
RET

einlesen:
;todo
RET

isr_timer0:
INC R0
RETI

warte:
;todo
RET

zufall:
mov A, R0   ; initialisiere A mit R0
jnz zub
cpl A
mov R0, A
zub:
anl A, #10111000b
mov C, P
mov A, R0
rlc A
mov R0, A
ret

tabelle:
DB 00000001b, 00000010b, 00000100b, 00001000b, 00010000b, 00100000b, 01000000b, 10000000b

END
