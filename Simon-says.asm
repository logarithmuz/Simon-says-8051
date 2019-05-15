CSEG at 0h
LJMP init

ORG 000Bh
LJMP isr_timer0

ORG 0100h
init:
MOV R0, #0d		; Startwert für Zufallszahlen mit 0 initialisieren
MOV TMOD, #00000010b	; Timermodus 8-Bit-Timer mit Autoreload auf Timer0
MOV TL0, #0d		; Startwert Timer
MOV TH0, #0d		; Nachladewert Timer
SETB IT0		; fallende Taktflanke
SETB TR0		; starte Timer
SJMP haupt		; springe zum Hauptprogramm

haupt:
JNB P1.0, haupt		; mache nichts, bis Taster P1.0 gedrückt wird
CLR TR0			; stoppe Timer
LCALL anzeigen		; Muster anzeigen
LCALL einlesen		; Eingaben des Nutzers einlesen
LCALL ergebnis		; Eingaben mit tatsächlichem Muster vergleichen und entsprechend Ergebnis darstellen
SJMP haupt

anzeigen:
MOV R1, #4d		; initialisiere R1 mit 4 (es sollen 4 verschiedene Muster angezeigt werden)
s1:
LCALL zufall		; aus dem Startwert eine Zufallszahl generieren
MOV A, R0		; lade Zufallszahl in den Akku
ANL A, #00001111b	; maskiere Akku, um eine zufällige Zahl zwischen 0 und 7 zu erhalten
MOV DPTR, #tabelle	; Datenpointer auf tabelle legen
MOVC A, @A+DPTR		; hole das entsprechende Bit-Muster aus der Tabelle
MOV P0, A		; zeige das Bit-Muster auf P0 an
LCALL warte		; warte
DJNZ R1, s1		; springe zu s1, wenn noch nicht 4 Muster angezeigt wurden
RET

einlesen:
;todo
RET

ergebnis:
;todo
RET

isr_timer0:
INC R0			; Generierung Startwert für Zufallszahl
RETI

warte:
;todo
RET

zufall:
MOV A, R0		; initialisiere A mit R0
JNZ zub			; Startwert darf nicht 0 sein
CPL A			; complementiere, falls doch 0
MOV R0, A
zub:
ANL A, #10111000b	; 
MOV C, P		;
MOV A, R0		;
RLC A			;
MOV R0, A		;
RET

tabelle:
DB 00000001b, 00000010b, 00000100b, 00001000b, 00010000b, 00100000b, 01000000b, 10000000b

END
