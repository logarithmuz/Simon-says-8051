CSEG at 0h
AUS EQU P0
EIN EQU P1
RNDMSEED EQU 50h
RNDM EQU 51h
LJMP init

ORG 03h
LJMP isr_ext0

ORG 0Bh
INC RNDM		; Generierung Startwert für Zufallszahl
RETI

ORG 01Bh
DEC R7
RETI

ORG 0100h
init:
MOV AUS, #11111111b	; Port0 mit 0 initialisieren
MOV EIN, #00000000b	; Port1 mit 0 initialisieren
MOV RNDM, #0d		; Startwert für Zufallszahlen mit 0 initialisieren
MOV TMOD, #00100010b	; Timermodus 8-Bit-Timer mit Autoreload auf Timer0
MOV TL0, #0FEh		; Startwert Timer
MOV TH0, #0FEh		; Nachladewert Timer
MOV TH1, #0D0h
MOV TL1, #0D0h
SETB ET0
SETB ET1
SETB EA
SETB IT0		; fallende Taktflanke Timer0
SETB IT1		; fallende Taktflanke Timer1
SETB TR0		; starte Timer
SJMP haupt		; springe zum Hauptprogramm

haupt:
JNB EIN.0, haupt		; mache nichts, bis Taster P1.0 gedrückt wird
CLR TR0			; stoppe Timer
LCALL anzeigen		; Muster anzeigen
LCALL einlesen		; Eingaben des Nutzers einlesen
LCALL ergebnis		; Eingaben mit tatsächlichem Muster vergleichen und entsprechend Ergebnis darstellen
SJMP haupt

anzeigen:
MOV A, RNDM
MOV RNDMSEED, A
MOV R0, #4d		; initialisiere R1 mit 4 (es sollen 4 verschiedene Muster angezeigt werden)
s1:
LCALL zufall		; aus dem Startwert eine Zufallszahl generieren
MOV A, RNDM		; lade Zufallszahl in den Akku
ANL A, #00000111b	; maskiere Akku, um eine zufällige Zahl zwischen 0 und 7 zu erhalten
MOV DPTR, #tabelle	; Datenpointer auf tabelle legen
MOVC A, @A+DPTR		; hole das entsprechende Bit-Muster aus der Tabelle
CPL A
MOV AUS, A		; zeige das Bit-Muster auf P0 an
LCALL warte		; warte
DJNZ R0, s1		; springe zu s1, wenn noch nicht 4 Muster angezeigt wurden
RET

einlesen:
SETB EX0
MOV R5, #4d
e1:
CJNE R5, #3d, e1
MOV R0, A
e2:
CJNE R5, #2d, e2
MOV R1, A
e3:
CJNE R5, #1d, e3
MOV R2, A
e4:
CJNE R5, #0d, e4
MOV R3, A
RET

ergebnis:

RET

isr_ext0:
MOV A, P1
DEC R5
RETI

warte:
MOV R7, #01d
SETB TR1
s2:
CJNE R7, #0d, s2
CLR TR1
RET

zufall:
MOV A, RNDM		; initialisiere A mit R0
JNZ zub			; Startwert darf nicht 0 sein
CPL A			; complementiere, falls doch 0
MOV RNDM, A
zub:
ANL A, #10111000b	;
MOV C, P		;
MOV A, RNDM		;
RLC A			;
MOV RNDM, A		;
RET

tabelle:
DB 00000001b, 00000010b, 00000100b, 00001000b, 00010000b, 00100000b, 01000000b, 10000000b

END
