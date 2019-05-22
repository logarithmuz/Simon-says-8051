;-----------------------
; Konstanten definieren
;-----------------------
AUS EQU P0
EIN EQU P1

RNDMSEED EQU 50h
RNDM EQU 51h

PATTERN1 EQU 48h
PATTERN2 EQU 49h
PATTERN3 EQU 4Ah
PATTERN4 EQU 4Bh


CSEG at 0h
LJMP init

;-----------------------------
; Interupt-Einsprung Adressen
;-----------------------------
ORG 03h
LJMP isr_ext0

ORG 01Bh
DEC R7			; Timer1 für Unterprogramm 'warten'
RETI

;-----------------
; Initialisierung
;-----------------
ORG 0100h
init:
MOV AUS, #0FFh		; Port0 mit 0 initialisieren
MOV EIN, #0FFh		; Port1 mit 0 initialisieren
MOV RNDM, #0d		; Startwert für Zufallszahlen mit 0 initialisieren

SETB EA			; globale Interupt-Freigabe
MOV TMOD, #00100010b	; Timermodus 8-Bit-Timer mit Autoreload auf Timer0 und Timer1

; Timer1
SETB ET1		; Freigabe Timer1
MOV TL1, #0D0h		; Startwert Timer1
MOV TH1, #0D0h		; Nachladewert Timer1
SETB IT1		; fallende Taktflanke Timer1

SJMP haupt		; springe zum Hauptprogramm

;---------------
; Hauptprogramm
;---------------
haupt:
INC RNDM		; Generierung Startwert für Zufallszahlengenerator
JB P1.0, haupt		; mache nichts, bis Taster P1.0 gedrückt wird
LCALL anzeigen		; Muster anzeigen
MOV AUS, #11111111b	; LEDs wieder ausschalten
LCALL einlesen		; Eingaben des Nutzers einlesen
LCALL ergebnis		; Eingaben mit tatsächlichem Muster vergleichen und entsprechend Ergebnis darstellen
SJMP init		; beginne von Vorne

;-----------------------------------------------------
; Unterprogramm zum Anzeigen der verschiedenen Muster
;-----------------------------------------------------
anzeigen:
MOV A, RNDM
MOV RNDMSEED, A		; verwendeten Randomseed abspeichern
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

;----------------------------------------------------
; Unterprogramm zum Einlesen der eingegebenen Muster
;----------------------------------------------------
einlesen:
SETB EX0
MOV R5, #4d
e1:
CJNE R5, #3d, e1	; auf externen Interupt 0 warten
CPL A			; Muster complementieren
MOV PATTERN1, A		; Muster aus dem Akku speichern
e2:
CJNE R5, #2d, e2	; auf externen Interupt 0 warten
CPL A			; Muster complementieren
MOV PATTERN2, A		; Muster aus dem Akku speichern
e3:
CJNE R5, #1d, e3	; auf externen Interupt 0 warten
CPL A			; Muster complementieren
MOV PATTERN3, A		; Muster aus dem Akku speichern
e4:
CJNE R5, #0d, e4	; auf externen Interupt 0 warten
CPL A			; Muster complementieren
MOV PATTERN4, A		; Muster aus dem Akku speichern
RET

;----------------------------------------------------------
; Unterprogramm zum Berechnen und Ausgeben des Ergebnisses
;----------------------------------------------------------
ergebnis:
MOV A, RNDMSEED		; alten Randomseed laden um die Muster erneut zu generieren
MOV RNDM, A

LCALL zufall		; aus dem gespeicherten Startwert die erste Zufallszahl generieren
MOV A, RNDM		; lade Zufallszahl in den Akku
ANL A, #00000111b	; maskiere Akku, um eine zufällige Zahl zwischen 0 und 7 zu erhalten
MOV DPTR, #tabelle	; Datenpointer auf tabelle legen
MOVC A, @A+DPTR		; hole das entsprechende Bit-Muster aus der Tabelle
CJNE A, PATTERN1, lose

LCALL zufall		; aus dem gespeicherten Startwert die zweite Zufallszahl generieren
MOV A, RNDM		; lade Zufallszahl in den Akku
ANL A, #00000111b	; maskiere Akku, um eine zufällige Zahl zwischen 0 und 7 zu erhalten
MOV DPTR, #tabelle	; Datenpointer auf tabelle legen
MOVC A, @A+DPTR		; hole das entsprechende Bit-Muster aus der Tabelle
CJNE A, PATTERN2, lose

LCALL zufall		; aus dem gespeicherten Startwert die dritte Zufallszahl generieren
MOV A, RNDM		; lade Zufallszahl in den Akku
ANL A, #00000111b	; maskiere Akku, um eine zufällige Zahl zwischen 0 und 7 zu erhalten
MOV DPTR, #tabelle	; Datenpointer auf tabelle legen
MOVC A, @A+DPTR		; hole das entsprechende Bit-Muster aus der Tabelle
CJNE A, PATTERN3, lose

LCALL zufall		; aus dem gespeicherten Startwert die vierte Zufallszahl generieren
MOV A, RNDM		; lade Zufallszahl in den Akku
ANL A, #00000111b	; maskiere Akku, um eine zufällige Zahl zwischen 0 und 7 zu erhalten
MOV DPTR, #tabelle	; Datenpointer auf tabelle legen
MOVC A, @A+DPTR		; hole das entsprechende Bit-Muster aus der Tabelle
CJNE A, PATTERN4, lose

win:
MOV AUS, #00001111b	; bei Gewonnen leuchten die ersten vier LEDs
SJMP ergebnisWait
lose:
MOV AUS, #11110000b	; bei Verloren leuchten die letzten vier LEDs
ergebnisWait:
lcall warte		; zeige das Ergebnis für einige Zeit an
lcall warte
lcall warte
MOV AUS, #11111111b;	; LEDs wieder ausschalten
RET

;-----------------------------------------------------------------
; Interupt-Subroutine des externen Interupts 0
; wird ausgelöst, wenn ein weiteres Muster eingelesen werden soll
;-----------------------------------------------------------------
isr_ext0:
MOV A, EIN		; Eingabe in den Akku laden
DEC R5			; R5 verringern. Indikator für das Unterprogramm 'einlesen', dass ein weiters Muster eingelesen wurde
RETI

;--------------------------
; Unterprogramm zum Warten
;--------------------------
warte:
MOV R7, #01d
SETB TR1
s2:
CJNE R7, #0d, s2
CLR TR1
RET

;-----------------------------------------------------------------------------
; Unterprogramm um eine (Pseudo-)Zufallszahl aus einem Startwert zu Berechnen
;-----------------------------------------------------------------------------
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

;-----------------------------------------------------------------------------
; Datentabelle um aus einer Zahl n zwischen 0 und 7 den Wert 2^n zu ermitteln
; wird für die Ausgabe eines Musters auf dem LED-Panel benötigt
;-----------------------------------------------------------------------------
tabelle:
DB 00000001b, 00000010b, 00000100b, 00001000b, 00010000b, 00100000b, 01000000b, 10000000b

END
