; Extracted Sonic 2 animation data

; Source: s2.asm
SonicAniData:			offsetTable

; Source: s2.asm
SonAni_Walk_ptr:		offsetTableEntry.w SonAni_Walk		;  0 ;   0

; Source: s2.asm
SonAni_Run_ptr:			offsetTableEntry.w SonAni_Run		;  1 ;   1

; Source: s2.asm
SonAni_Roll_ptr:		offsetTableEntry.w SonAni_Roll		;  2 ;   2

; Source: s2.asm
SonAni_Roll2_ptr:		offsetTableEntry.w SonAni_Roll2		;  3 ;   3

; Source: s2.asm
SonAni_Push_ptr:		offsetTableEntry.w SonAni_Push		;  4 ;   4

; Source: s2.asm
SonAni_Wait_ptr:		offsetTableEntry.w SonAni_Wait		;  5 ;   5

; Source: s2.asm
SonAni_Balance_ptr:		offsetTableEntry.w SonAni_Balance	;  6 ;   6

; Source: s2.asm
SonAni_LookUp_ptr:		offsetTableEntry.w SonAni_LookUp	;  7 ;   7

; Source: s2.asm
SonAni_Duck_ptr:		offsetTableEntry.w SonAni_Duck		;  8 ;   8

; Source: s2.asm
SonAni_Spindash_ptr:		offsetTableEntry.w SonAni_Spindash	;  9 ;   9

; Source: s2.asm
SonAni_Blink_ptr:		offsetTableEntry.w SonAni_Blink		; 10 ;  $A

; Source: s2.asm
SonAni_GetUp_ptr:		offsetTableEntry.w SonAni_GetUp		; 11 ;  $B

; Source: s2.asm
SonAni_Balance2_ptr:		offsetTableEntry.w SonAni_Balance2	; 12 ;  $C

; Source: s2.asm
SonAni_Stop_ptr:		offsetTableEntry.w SonAni_Stop		; 13 ;  $D

; Source: s2.asm
SonAni_Float_ptr:		offsetTableEntry.w SonAni_Float		; 14 ;  $E

; Source: s2.asm
SonAni_Float2_ptr:		offsetTableEntry.w SonAni_Float2	; 15 ;  $F

; Source: s2.asm
SonAni_Spring_ptr:		offsetTableEntry.w SonAni_Spring	; 16 ; $10

; Source: s2.asm
SonAni_Hang_ptr:		offsetTableEntry.w SonAni_Hang		; 17 ; $11

; Source: s2.asm
SonAni_Dash2_ptr:		offsetTableEntry.w SonAni_Dash2		; 18 ; $12

; Source: s2.asm
SonAni_Dash3_ptr:		offsetTableEntry.w SonAni_Dash3		; 19 ; $13

; Source: s2.asm
SonAni_Hang2_ptr:		offsetTableEntry.w SonAni_Hang2		; 20 ; $14

; Source: s2.asm
SonAni_Bubble_ptr:		offsetTableEntry.w SonAni_Bubble	; 21 ; $15

; Source: s2.asm
SonAni_DeathBW_ptr:		offsetTableEntry.w SonAni_DeathBW	; 22 ; $16

; Source: s2.asm
SonAni_Drown_ptr:		offsetTableEntry.w SonAni_Drown		; 23 ; $17

; Source: s2.asm
SonAni_Death_ptr:		offsetTableEntry.w SonAni_Death		; 24 ; $18

; Source: s2.asm
SonAni_Hurt_ptr:		offsetTableEntry.w SonAni_Hurt		; 25 ; $19

; Source: s2.asm
SonAni_Hurt2_ptr:		offsetTableEntry.w SonAni_Hurt		; 26 ; $1A

; Source: s2.asm
SonAni_Slide_ptr:		offsetTableEntry.w SonAni_Slide		; 27 ; $1B

; Source: s2.asm
SonAni_Blank_ptr:		offsetTableEntry.w SonAni_Blank		; 28 ; $1C

; Source: s2.asm
SonAni_Balance3_ptr:		offsetTableEntry.w SonAni_Balance3	; 29 ; $1D

; Source: s2.asm
SonAni_Balance4_ptr:		offsetTableEntry.w SonAni_Balance4	; 30 ; $1E

; Source: s2.asm
SupSonAni_Transform_ptr:	offsetTableEntry.w SupSonAni_Transform	; 31 ; $1F

; Source: s2.asm
SonAni_Lying_ptr:		offsetTableEntry.w SonAni_Lying		; 32 ; $20

; Source: s2.asm
SonAni_LieDown_ptr:		offsetTableEntry.w SonAni_LieDown	; 33 ; $21


; Source: s2.asm
SonAni_Walk:	dc.b $FF, $F,$10,$11,$12,$13,$14, $D, $E,$FF
	rev02even

; Source: s2.asm
SonAni_Run:	dc.b $FF,$2D,$2E,$2F,$30,$FF,$FF,$FF,$FF,$FF
	rev02even

; Source: s2.asm
SonAni_Roll:	dc.b $FE,$3D,$41,$3E,$41,$3F,$41,$40,$41,$FF
	rev02even

; Source: s2.asm
SonAni_Roll2:	dc.b $FE,$3D,$41,$3E,$41,$3F,$41,$40,$41,$FF
	rev02even

; Source: s2.asm
SonAni_Push:	dc.b $FD,$48,$49,$4A,$4B,$FF,$FF,$FF,$FF,$FF
	rev02even

; Source: s2.asm
SonAni_Wait:
	dc.b   5,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
	dc.b   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  2
	dc.b   3,  3,  3,  3,  3,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5
	dc.b   5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  6,  6,  6
	dc.b   6,  6,  6,  6,  6,  6,  6,  4,  4,  4,  5,  5,  5,  4,  4,  4
	dc.b   5,  5,  5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  6
	dc.b   6,  6,  6,  6,  6,  6,  6,  6,  6,  4,  4,  4,  5,  5,  5,  4
	dc.b   4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5
	dc.b   5,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  4,  4,  4,  5,  5
	dc.b   5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  4,  4,  4
	dc.b   5,  5,  5,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  7,  8,  8
	dc.b   8,  9,  9,  9,$FE,  6
	rev02even

; Source: s2.asm
SonAni_Balance:	dc.b   9,$CC,$CD,$CE,$CD,$FF
	rev02even

; Source: s2.asm
SonAni_LookUp:	dc.b   5, $B, $C,$FE,  1
	rev02even

; Source: s2.asm
SonAni_Duck:	dc.b   5,$4C,$4D,$FE,  1
	rev02even

; Source: s2.asm
SonAni_Spindash:dc.b   0,$42,$43,$42,$44,$42,$45,$42,$46,$42,$47,$FF
	rev02even

; Source: s2.asm
SonAni_Blink:	dc.b   1,  2,$FD,  0
	rev02even

; Source: s2.asm
SonAni_GetUp:	dc.b   3, $A,$FD,  0
	rev02even

; Source: s2.asm
SonAni_Balance2:dc.b   3,$C8,$C9,$CA,$CB,$FF
	rev02even

; Source: s2.asm
SonAni_Stop:	dc.b   5,$D2,$D3,$D4,$D5,$FD,  0 ; halt/skidding animation
	rev02even

; Source: s2.asm
SonAni_Float:	dc.b   7,$54,$59,$FF
	rev02even

; Source: s2.asm
SonAni_Float2:	dc.b   7,$54,$55,$56,$57,$58,$FF
	rev02even

; Source: s2.asm
SonAni_Spring:	dc.b $2F,$5B,$FD,  0
	rev02even

; Source: s2.asm
SonAni_Hang:	dc.b   1,$50,$51,$FF
	rev02even

; Source: s2.asm
SonAni_Dash2:	dc.b  $F,$43,$43,$43,$FE,  1
	rev02even

; Source: s2.asm
SonAni_Dash3:	dc.b  $F,$43,$44,$FE,  1
	rev02even

; Source: s2.asm
SonAni_Hang2:	dc.b $13,$6B,$6C,$FF
	rev02even

; Source: s2.asm
SonAni_Bubble:	dc.b  $B,$5A,$5A,$11,$12,$FD,  0 ; breathe
	rev02even

; Source: s2.asm
SonAni_DeathBW:	dc.b $20,$5E,$FF
	rev02even

; Source: s2.asm
SonAni_Drown:	dc.b $20,$5D,$FF
	rev02even

; Source: s2.asm
SonAni_Death:	dc.b $20,$5C,$FF
	rev02even

; Source: s2.asm
SonAni_Hurt:	dc.b $40,$4E,$FF
	rev02even

; Source: s2.asm
SonAni_Slide:	dc.b   9,$4E,$4F,$FF
	rev02even

; Source: s2.asm
SonAni_Blank:	dc.b $77,  0,$FD,  0
	rev02even

; Source: s2.asm
SonAni_Balance3:dc.b $13,$D0,$D1,$FF
	rev02even

; Source: s2.asm
SonAni_Balance4:dc.b   3,$CF,$C8,$C9,$CA,$CB,$FE,  4
	rev02even

; Source: s2.asm
SonAni_Lying:	dc.b   9,  8,  9,$FF
	rev02even

; Source: s2.asm
SonAni_LieDown:	dc.b   3,  7,$FD,  0
	even

; ---------------------------------------------------------------------------
; Animation script - Super Sonic
; (many of these point to the data above this)
; ---------------------------------------------------------------------------

; Source: s2.asm
SuperSonicAniData: offsetTable
	offsetTableEntry.w SupSonAni_Walk	;  0 ;   0
	offsetTableEntry.w SupSonAni_Run	;  1 ;   1
	offsetTableEntry.w SonAni_Roll		;  2 ;   2
	offsetTableEntry.w SonAni_Roll2		;  3 ;   3
	offsetTableEntry.w SupSonAni_Push	;  4 ;   4
	offsetTableEntry.w SupSonAni_Stand	;  5 ;   5
	offsetTableEntry.w SupSonAni_Balance	;  6 ;   6
	offsetTableEntry.w SonAni_LookUp	;  7 ;   7
	offsetTableEntry.w SupSonAni_Duck	;  8 ;   8
	offsetTableEntry.w SonAni_Spindash	;  9 ;   9
	offsetTableEntry.w SonAni_Blink		; 10 ;  $A
	offsetTableEntry.w SonAni_GetUp		; 11 ;  $B
	offsetTableEntry.w SonAni_Balance2	; 12 ;  $C
	offsetTableEntry.w SonAni_Stop		; 13 ;  $D
	offsetTableEntry.w SonAni_Float		; 14 ;  $E
	offsetTableEntry.w SonAni_Float2	; 15 ;  $F
	offsetTableEntry.w SonAni_Spring	; 16 ; $10
	offsetTableEntry.w SonAni_Hang		; 17 ; $11
	offsetTableEntry.w SonAni_Dash2		; 18 ; $12
	offsetTableEntry.w SonAni_Dash3		; 19 ; $13
	offsetTableEntry.w SonAni_Hang2		; 20 ; $14
	offsetTableEntry.w SonAni_Bubble	; 21 ; $15
	offsetTableEntry.w SonAni_DeathBW	; 22 ; $16
	offsetTableEntry.w SonAni_Drown		; 23 ; $17
	offsetTableEntry.w SonAni_Death		; 24 ; $18
	offsetTableEntry.w SonAni_Hurt		; 25 ; $19
	offsetTableEntry.w SonAni_Hurt		; 26 ; $1A
	offsetTableEntry.w SonAni_Slide		; 27 ; $1B
	offsetTableEntry.w SonAni_Blank		; 28 ; $1C
	offsetTableEntry.w SonAni_Balance3	; 29 ; $1D
	offsetTableEntry.w SonAni_Balance4	; 30 ; $1E
	offsetTableEntry.w SupSonAni_Transform	; 31 ; $1F


; Source: s2.asm
SupSonAni_Walk:		dc.b $FF,$77,$78,$79,$7A,$7B,$7C,$75,$76,$FF
	rev02even

; Source: s2.asm
SupSonAni_Run:		dc.b $FF,$B5,$B9,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	rev02even

; Source: s2.asm
SupSonAni_Push:		dc.b $FD,$BD,$BE,$BF,$C0,$FF,$FF,$FF,$FF,$FF
	rev02even

; Source: s2.asm
SupSonAni_Stand:	dc.b   7,$72,$73,$74,$73,$FF
	rev02even

; Source: s2.asm
SupSonAni_Balance:	dc.b   9,$C2,$C3,$C4,$C3,$C5,$C6,$C7,$C6,$FF
	rev02even

; Source: s2.asm
SupSonAni_Duck:		dc.b   5,$C1,$FF
	rev02even

; Source: s2.asm
SupSonAni_Transform:	dc.b   2,$6D,$6D,$6E,$6E,$6F,$70,$71,$70,$71,$70,$71,$70,$71,$FD,  0
	even

; ---------------------------------------------------------------------------
; Sonic pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1B848:
