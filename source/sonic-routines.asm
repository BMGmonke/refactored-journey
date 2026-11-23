PalCycle_SuperSonic:
	move.b	(Super_Sonic_palette).w,d0
	beq.s	.return	; return, if Sonic isn't super
	bmi.w	.normal	; branch, if fade-in is done
	subq.b	#1,d0
	bne.s	.revert	; branch for values greater than 1

	; fade from Sonic's to Super Sonic's palette
	; run frame timer
	subq.b	#1,(Palette_timer).w
	bpl.s	.return
	move.b	#3,(Palette_timer).w

	; increment palette frame and update Sonic's palette
	lea	(CyclingPal_SSTransformation).l,a0
	move.w	(Palette_frame).w,d0
	addq.w	#8,(Palette_frame).w	; 1 palette entry = 1 word, Sonic uses 4 shades of blue
	cmpi.w	#$30,(Palette_frame).w	; has palette cycle reached the 6th frame?
	blo.s	+			; if not, branch
	move.b	#-1,(Super_Sonic_palette).w	; mark fade-in as done
	move.b	#0,(MainCharacter+obj_control).w	; restore Sonic's movement
+
	lea	(Normal_palette+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
    if fixBugs
	; underwater palettes
	lea	(CyclingPal_CPZUWTransformation).l,a0
	cmpi.b	#chemical_plant_zone,(Current_Zone).w
	beq.s	+
	cmpi.b	#aquatic_ruin_zone,(Current_Zone).w
	bne.s	.return
	lea	(CyclingPal_ARZUWTransformation).l,a0
+	lea	(Underwater_palette+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
    else
	; Note: The fade in for Sonic's underwater palette is missing.
	; Because of this, Super Sonic's transformation will be uncorrect
	; when underwater.
    endif
.return:
	rts
; ===========================================================================
; loc_2188: PalCycle_SuperSonic_revert:
.revert:	; runs the fade in transition backwards
	; run frame timer
	subq.b	#1,(Palette_timer).w
	bpl.s	.return
	move.b	#3,(Palette_timer).w

	; decrement palette frame and update Sonic's palette
	lea	(CyclingPal_SSTransformation).l,a0
	move.w	(Palette_frame).w,d0
	subq.w	#8,(Palette_frame).w	; previous frame
	bcc.s	+			; branch, if it isn't the first frame
    if fixBugs
	move.w	#0,(Palette_frame).w
    else
	; This does not clear the full variable, causing this palette cycle
	; to behave incorrectly the next time it is activated.
	move.b	#0,(Palette_frame).w
    endif
	move.b	#0,(Super_Sonic_palette).w	; stop palette cycle
+
	lea	(Normal_palette+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	; underwater palettes
	lea	(CyclingPal_CPZUWTransformation).l,a0
	cmpi.b	#chemical_plant_zone,(Current_Zone).w
	beq.s	+
	cmpi.b	#aquatic_ruin_zone,(Current_Zone).w
	bne.s	.return
	lea	(CyclingPal_ARZUWTransformation).l,a0
+	lea	(Underwater_palette+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	rts
; ===========================================================================
; loc_21E6: PalCycle_SuperSonic_normal:
.normal:
	; run frame timer
	subq.b	#1,(Palette_timer).w
	bpl.s	.return
	move.b	#7,(Palette_timer).w

	; increment palette frame and update Sonic's palette
	lea	(CyclingPal_SSTransformation).l,a0
	move.w	(Palette_frame).w,d0
	addq.w	#8,(Palette_frame).w	; next frame
	cmpi.w	#$78,(Palette_frame).w	; is it the last frame?
    if fixBugs
	bls.s	+			; if not, branch
    else
	; This condition causes the last frame to be skipped.
	blo.s	+			; if not, branch
    endif
	move.w	#$30,(Palette_frame).w	; reset frame counter (Super Sonic's normal palette cycle starts at $30. Everything before that is for the palette fade)
+
	lea	(Normal_palette+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	; underwater palettes
	lea	(CyclingPal_CPZUWTransformation).l,a0
	cmpi.b	#chemical_plant_zone,(Current_Zone).w
	beq.s	+
	cmpi.b	#aquatic_ruin_zone,(Current_Zone).w
	bne.w	.return
	lea	(CyclingPal_ARZUWTransformation).l,a0
+	lea	(Underwater_palette+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	rts
; End of function PalCycle_SuperSonic

; ===========================================================================
;----------------------------------------------------------------------------
;Palette for transformation to Super Sonic
;----------------------------------------------------------------------------
; Pal_2246:

MoveSonicInDemo:
	tst.w	(Demo_mode_flag).w	; is demo mode on?
	bne.w	MoveDemo_On	; if yes, branch
	rts
; ---------------------------------------------------------------------------
; demo recording routine
; (unused/dead code, but obviously used during development)
; ---------------------------------------------------------------------------
; MoveDemo_Record: loc_4828:
	; calculate output location of recorded player 1 demo?
	lea	(DemoScriptPointers).l,a1
	moveq	#0,d0
	move.b	(Current_Zone).w,d0
	lsl.w	#2,d0
	movea.l	(a1,d0.w),a1
	move.w	(Demo_button_index).w,d0
	adda.w	d0,a1

	move.b	(Ctrl_1_Held).w,d0	; load input of player 1
	cmp.b	(a1),d0			; is same button held?
	bne.s	+			; if not, branch
	addq.b	#1,1(a1)		; increment press length counter
	cmpi.b	#$FF,1(a1)		; is button held too long?
	beq.s	+			; if yes, branch
	bra.s	MoveDemo_Record_P2	; go to player 2
; ===========================================================================
+
	move.b	d0,2(a1)		; store last button press
	move.b	#0,3(a1)		; reset hold length counter
	addq.w	#2,(Demo_button_index).w ; advance to next button press
	andi.w	#$3FF,(Demo_button_index).w ; wrap at max button press changes 1024
; loc_486A:

SSHUD_SonicMilesTotal:
	dc.b   3		; Sprite count
	dc.b   $80		; X-pos
	dc.b   0,  1,  3	; Sprite 1 frame, Sprite 2 frame, etc
; byte_7057:

SSHUD_Sonic:
	dc.b   1
	dc.b   $D4
	dc.b   0
; byte_705A:

SSHUD_SonicTailsTotal:
	dc.b   3
	dc.b   $80
	dc.b   0,  2,  3
; byte_7062:

SSHUD_Sonic_2:
	dc.b   1
	dc.b   $D4
	dc.b   0
; byte_7065:

SSHUD_SonicMiles:
	dc.b   2
	dc.b   $80
	dc.b   0,  1
; byte_706C:

SSHUD_SonicTails:
	dc.b   2
	dc.b   $80
	dc.b   0,  2
; -----------------------------------------------------------------------------------
; sprite mappings
; -----------------------------------------------------------------------------------

ObjDB_Sonic_Init:
	addq.b	#2,routine(a0) ; => ObjDB_Sonic_Wait
	move.w	#$9C,x_pos(a0)
	move.w	#$19C,y_pos(a0)
	move.l	#MapUnc_Sonic,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtUnc_Sonic,0,0),art_tile(a0)
	move.b	#1<<render_flags.level_fg,render_flags(a0)
	move.b	#2,priority(a0)
	move.b	#AniIDSonAni_Lying,anim(a0)

; loc_7BD2:

ObjDB_Sonic_Wait:
	tst.b	(Ctrl_1_Press).w	; is start pressed?
	bmi.s	ObjDB_Sonic_StartRunning ; if yes, branch
	jsr	(Sonic_Animate).l
	jmp	(LoadSonicDynPLC).l
; ---------------------------------------------------------------------------
; loc_7BE4:

ObjDB_Sonic_StartRunning:
	addq.b	#2,routine(a0) ; => ObjDB_Sonic_Run
	move.b	#AniIDSonAni_LieDown,anim(a0)
	clr.w	inertia(a0)
	move.b	#SndID_SpindashRev,d0 ; super peel-out sound
	bsr.w	PlaySound

; loc_7BFA:

ObjDB_Sonic_Run:
	cmpi.w	#$800,inertia(a0)
	bne.s	+
	move.w	#$1000,x_vel(a0)
	bra.s	++
; ---------------------------------------------------------------------------
+
	addi.w	#$20,inertia(a0)
+
	jsr	(ObjectMove).l
	jsr	(Sonic_Animate).l
	jmp	(LoadSonicDynPLC).l
; ===========================================================================
; loc_7C22:

Anim_SonicMilesBG:	zoneanimstart
	; Sonic/Miles animated background
	zoneanimdecl  -1, ArtUnc_MenuBack,    1,  6, $A
	dc.b   0,$C7
	dc.b  $A,  5
	dc.b $14,  5
	dc.b $1E,$C7
	dc.b $14,  5
	dc.b  $A,  5
	even

	zoneanimend

; off_87DC:

super_sonic_cheat:
	; Book of Genesis, 41:26, which makes frequent reference to the
	; number 7. 7 happens to be the number of Chaos Emeralds.
	; The Mega Drive is known as the Genesis in the US.
	dc.b   4,   1,   2,   6,   0
	rev02even

	; set the character set for menu text
	charset '@',"\27\30\31\32\33\34\35\36\37\38\39\40\41\42\43\44\45\46\47\48\49\50\51\52\53\54\55"
	charset '0',"\16\17\18\19\20\21\22\23\24\25"
	charset '*',$1A
	charset ':',$1C
	charset '.',$1D
	charset ' ',0

	; options screen menu text


TextOptScr_SonicAndMiles:	menutxt	"SONIC AND MILES"	; byte_97DC:

TextOptScr_SonicAndTails:	menutxt	"SONIC AND TAILS"	; byte_97EC:

TextOptScr_SonicAlone:		menutxt	"SONIC ALONE    "	; byte_97FC:

EndingSequence_LoadCharacterArt_Sonic:
	move.l	#vdpComm(tiles_to_bytes(ArtTile_EndingCharacter),VRAM,WRITE),(VDP_control_port).l
	lea	(ArtNem_EndingSonic).l,a0
	jmpto	JmpTo_NemDec
; ===========================================================================
; loc_AC08:

EndingSequence_LoadCharacterArt_SuperSonic:
	move.l	#vdpComm(tiles_to_bytes(ArtTile_EndingCharacter),VRAM,WRITE),(VDP_control_port).l
	lea	(ArtNem_EndingSuperSonic).l,a0
	jmpto	JmpTo_NemDec
; ===========================================================================
; loc_AC1C:

AnimalFaceSonic:
	bset	#render_flags.x_flip,render_flags(a0)
	move.w	x_pos(a0),d0
	sub.w	(MainCharacter+x_pos).w,d0
	bcc.s	+	; rts
	bclr	#render_flags.x_flip,render_flags(a0)
+
	rts
; End of function AnimalFaceSonic


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

;sub_11DB8

CollectRing_Sonic:
	cmpi.w	#999,(Rings_Collected).w ; did Sonic collect 999 or more rings?
	bhs.s	CollectRing_1P		; if yes, branch
	addq.w	#1,(Rings_Collected).w	; add 1 to the number of collected rings


SolidObject_Monitor_Sonic:
	btst	d6,status(a0)			; is Sonic standing on the monitor?
	bne.s	Obj26_ChkOverEdge		; if yes, branch
	cmpi.b	#AniIDSonAni_Roll,anim(a1)		; is Sonic spinning?
	bne.w	SolidObject_cont		; if not, branch
	rts
; End of function SolidObject_Monitor_Sonic


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_12768:

sonic_1up:
	addq.w	#1,(Monitors_Broken).w
	addq.b	#1,(Life_count).w
	addq.b	#1,(Update_HUD_lives).w
	move.w	#MusID_ExtraLife,d0
	jmp	(PlayMusic).l	; Play extra life music
; ===========================================================================
; ---------------------------------------------------------------------------
; Tails 1up Monitor
; gives Tails an extra life in two player mode
; ---------------------------------------------------------------------------

Ani_obj26_Sonic:
	dc.b   1,  0,  2,  2,  1,  2,  2,$FF
; byte_12CF0:

Obj0E_Sonic:
	addq.w	#1,obj0e_current_frame(a0)
	cmpi.w	#288,obj0e_current_frame(a0)
	bhs.s	+
	bsr.w	TitleScreen_SetFinalState
+
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	Obj0E_Sonic_Index(pc,d0.w),d1
	jmp	Obj0E_Sonic_Index(pc,d1.w)
; ===========================================================================
; off_12E76:

Obj0E_Sonic_Index: offsetTable
	offsetTableEntry.w Obj0E_Sonic_Init			;   0
	offsetTableEntry.w Obj0E_Sonic_FadeInAndPlayMusic	;   2
	offsetTableEntry.w Obj0E_Sonic_LoadPalette		;   4
	offsetTableEntry.w Obj0E_Sonic_Move			;   6
	offsetTableEntry.w Obj0E_Animate			;   8
	offsetTableEntry.w Obj0E_Sonic_AnimationFinished	;  $A
	offsetTableEntry.w Obj0E_Sonic_SpawnTails		;  $C
	offsetTableEntry.w Obj0E_Sonic_FlashBackground		;  $E
	offsetTableEntry.w Obj0E_Sonic_SpawnFallingStar		; $10
	offsetTableEntry.w Obj0E_Sonic_MakeStarSparkle		; $12
; ===========================================================================
; spawn more stars

Obj0E_Sonic_Init:
	addq.b	#2,routine_secondary(a0)	; Obj0E_Sonic_FadeInAndPlayMusic
	move.b	#5,mapping_frame(a0)

	move.w	#spriteScreenPositionXCentered(-16),x_pixel(a0)
	move.w	#spriteScreenPositionYCentered(-16),y_pixel(a0)

	; Load flashing star object.
	lea	(IntroFlashingStar).w,a1
	move.b	#ObjID_TitleIntro,id(a1)
	move.b	#8,subtype(a1)

	; Load emblem top object.
	lea	(IntroEmblemTop).w,a1
	move.b	#ObjID_TitleIntro,id(a1)
	move.b	#6,subtype(a1)

	; Play twinkling sound.
	moveq	#signextendB(SndID_Sparkle),d0
	jmpto	JmpTo4_PlaySound
; ===========================================================================
; loc_12EC2:

Obj0E_Sonic_FadeInAndPlayMusic:
	; Wait.
	cmpi.w	#56,obj0e_current_frame(a0)
	bhs.s	+
	rts
; ===========================================================================
+
	addq.b	#2,routine_secondary(a0)	; Obj0E_Sonic_LoadPalette

	; Load palette-changer object.
	lea	(TitleScreenPaletteChanger3).w,a1
	move.b	#ObjID_TtlScrPalChanger,id(a1)
	move.b	#0,subtype(a1)

	; Play title screen music.
	st.b	obj0e_music_playing(a0)
	moveq	#signextendB(MusID_Title),d0
	jmpto	JmpTo4_PlayMusic
; ===========================================================================
; loc_12EE8:

Obj0E_Sonic_LoadPalette:
	; Wait.
	cmpi.w	#128,obj0e_current_frame(a0)
	bhs.s	+
	rts
; ===========================================================================
+
	addq.b	#2,routine_secondary(a0)	; Obj0E_Sonic_Move

	; Load Sonic's palette to palette line 1.
	lea	(Pal_133EC).l,a1
	lea	(Normal_palette).w,a2
	moveq	#bytesToWcnt(palette_line_size),d6
-	move.w	(a1)+,(a2)+
	dbf	d6,-
; sub_12F08: Obj0E_Sonic_LoadSky:

Obj0E_Sonic_Move:
	; 'd2' is used to detect when the end of the position array has been
	; reached.
	moveq	#Obj0E_Sonic_Positions_End-Obj0E_Sonic_Positions+4,d2
	lea	(Obj0E_Sonic_Positions).l,a1
; loc_12F20:

Obj0E_Sonic_AnimationFinished:
	addq.b	#2,routine_secondary(a0)	; Obj0E_Sonic_SpawnTails
	move.b	#$12,mapping_frame(a0)

	; Load Sonic's hand object.
	lea	(IntroSonicHand).w,a1
	move.b	#ObjID_TitleIntro,id(a1)
	move.b	#$A,subtype(a1)

	bra.w	DisplaySprite
; ===========================================================================
; loc_12F7C:

Obj0E_Sonic_SpawnTails:
	cmpi.w	#192,obj0e_current_frame(a0)
	blo.s	+
	addq.b	#2,routine_secondary(a0)	; Obj0E_Sonic_FlashBackground

	; Load Tails object.
	lea	(IntroTails).w,a1
	move.b	#ObjID_TitleIntro,id(a1)
	move.b	#4,subtype(a1)
+
	bra.w	DisplaySprite
; ===========================================================================
; loc_12F9A:

Obj0E_Sonic_FlashBackground:
	cmpi.w	#288,obj0e_current_frame(a0)
	blo.s	+
	addq.b	#2,routine_secondary(a0)	; Obj0E_Sonic_SpawnFallingStar
	clr.w	obj0e_array_index(a0)
	st.b	obj0e_intro_complete(a0)

	; Fill palette line 3 with white.
	lea	(Normal_palette_line3).w,a1
	move.w	#$EEE,d0
	moveq	#bytesToWcnt(palette_line_size),d6
-	move.w	d0,(a1)+
	dbf	d6,-

	; Load palette-changer object.
	lea	(TitleScreenPaletteChanger2).w,a1
	move.b	#ObjID_TtlScrPalChanger,id(a1)
	move.b	#2,subtype(a1)

	; Load title screen menu object.
	move.b	#ObjID_TitleMenu,(TitleScreenMenu+id).w
+
	bra.w	DisplaySprite
; ===========================================================================
; loc_12FD6:

Obj0E_Sonic_SpawnFallingStar:
	; Wait a different amount of time on PAL consoles so that it's timed
	; right with the music.
	btst	#6,(Graphics_Flags).w
	beq.s	+
	cmpi.w	#400,obj0e_current_frame(a0)
	beq.s	++
	bra.w	DisplaySprite
; ===========================================================================
+
	cmpi.w	#464,obj0e_current_frame(a0)
	beq.s	+
	bra.w	DisplaySprite
; ===========================================================================
+
	; Create falling star object.
	lea	(IntroFallingStar).w,a1
	move.b	#ObjID_TitleIntro,id(a1)
	move.b	#$C,subtype(a1)

	addq.b	#2,routine_secondary(a0)	; Obj0E_Sonic_MakeStarSparkle

	; Delete sprite mask object.
	lea	(IntroMaskingSprite).w,a1
	bsr.w	DeleteObject2

	bra.w	DisplaySprite
; ===========================================================================
; loc_13014:

Obj0E_Sonic_MakeStarSparkle:
	; Animate the falling star every 8 frames.
	move.b	(Vint_runcount+3).w,d0
	andi.b	#7,d0
	bne.s	++

	; Advance index, while checking if we've reached the end of the
	; colour array.
	move.w	obj0e_array_index(a0),d0
	addq.w	#2,d0
	cmpi.w	#CyclingPal_TitleStar_End-CyclingPal_TitleStar,d0
	blo.s	+
	moveq	#0,d0
+
	move.w	d0,obj0e_array_index(a0)

	; Obtain colour from the array and apply it to the palette line.
	move.w	CyclingPal_TitleStar(pc,d0.w),(Normal_palette_line3+5*2).w
+
	bra.w	DisplaySprite
; ===========================================================================
; word_1303A:

Obj0E_Sonic_Positions:
	;                             X,   Y
	obj0e_make_sprite_position  -24, -32
	obj0e_make_sprite_position  -32, -48
	obj0e_make_sprite_position  -40, -64
	obj0e_make_sprite_position  -42, -74
	obj0e_make_sprite_position  -38, -82
	obj0e_make_sprite_position  -32, -86
	obj0e_make_sprite_position  -28, -87
	obj0e_make_sprite_position  -24, -88
Obj0E_Sonic_Positions_End
; ===========================================================================


Obj0E_SonicHand:
	moveq	#0,d0
	move.b	routine_secondary(a0),d0
	move.w	Obj0E_SonicHand_Index(pc,d0.w),d1
	jmp	Obj0E_SonicHand_Index(pc,d1.w)
; ===========================================================================
; off_1320E:

Obj0E_SonicHand_Index: offsetTable
	offsetTableEntry.w Obj0E_SonicHand_Init		; 0
	offsetTableEntry.w Obj0E_SonicHand_Move		; 2
	offsetTableEntry.w BranchTo13_DisplaySprite	; 4
; ===========================================================================


Obj0E_SonicHand_Init:
	addq.b	#2,routine_secondary(a0)	; Obj0E_SonicHand_Move
	move.b	#9,mapping_frame(a0)
    if fixBugs
	; This matches 'TitleScreen_SetFinalState'.
	move.b	#2,priority(a0)
    else
	; This is inconsistent with 'TitleScreen_SetFinalState'.
	move.b	#3,priority(a0)
    endif
	move.w	#spriteScreenPositionXCentered(37),x_pixel(a0)
	move.w	#spriteScreenPositionYCentered(-49),y_pixel(a0)

BranchTo13_DisplaySprite ; BranchTo
	bra.w	DisplaySprite
; ===========================================================================
; loc_13234:

Obj0E_SonicHand_Move:
	moveq	#Obj0E_SonicHand_Positions_End-Obj0E_SonicHand_Positions+4,d2
	lea	(Obj0E_SonicHand_Positions).l,a1
	bra.w	Obj0E_Move
; ===========================================================================
; word_13240:

Obj0E_SonicHand_Positions:
	;                            X,   Y
	obj0e_make_sprite_position  35, -47
	obj0e_make_sprite_position  32, -46
	obj0e_make_sprite_position  33, -47
Obj0E_SonicHand_Positions_End
; ===========================================================================


Ani_obj0E_Sonic:
	dc.b   1
	dc.b   5
	dc.b   6
	dc.b   7
    if ~~fixBugs
	; This appears to be a leftover prototype frame: it's a duplicate of
	; frame $12, except Sonic is missing his right arm. The old frame
	; being here in this animation script causes Sonic to appear with
	; both of his arms missing for a single frame.
	dc.b   8
    endif
	dc.b $FA
	even
; byte_13694:

EOL_Sonic:	spriteHeader	; SONIC GOT
	spritePiece	-$40, 0, 2, 2, $5D0, 0, 0, 0, 1	; S
	spritePiece	-$30, 0, 2, 2, $588, 0, 0, 0, 1	; O
	spritePiece	-$20, 0, 2, 2, $584, 0, 0, 0, 1	; N
	spritePiece	-$10, 0, 1, 2, $5C0, 0, 0, 0, 1	; I
	spritePiece	-8, 0, 2, 2, $5B4, 0, 0, 0, 1	; C

	spritePiece	$10, 0, 2, 2, $5B8, 0, 0, 0, 1	; G
	spritePiece	$20, 0, 2, 2, $588, 0, 0, 0, 1	; O
	spritePiece	$2F, 0, 2, 2, $5D4, 0, 0, 0, 1	; T
EOL_Sonic_End

; word_14D1C:

ObjPtr_Sonic:		dc.l Obj01	; Sonic

ObjPtr_SonicSS:		dc.l Obj09	; Sonic in Special Stage

ObjPtr_SuperSonicStars:	dc.l Obj7E	; Super Sonic's stars

ObjPtr_MechaSonic:	dc.l ObjAF	; Mecha Sonic / Silver Sonic from DEZ

ObjPtr_SonicOnSegaScr:	dc.l ObjB0	; Sonic on the Sega screen

ObjPtr_EndingSeqSonic:

MvSonicOnPtfm:
	move.w	y_pos(a0),d0
	sub.w	d3,d0
	bra.s	loc_19BA2
; ===========================================================================
	; a couple lines of unused/leftover/dead code from Sonic 1 ; a0=object
	move.w	y_pos(a0),d0
	subi.w	#9,d0


MvSonicOnSlope:
	btst	#status.player.on_object,status(a1)
	beq.s	return_19C0C
	move.w	x_pos(a1),d0
	sub.w	x_pos(a0),d0
	add.w	d1,d0
	lsr.w	#1,d0
	btst	#render_flags.x_flip,render_flags(a0)
	beq.s	loc_19BEC
	not.w	d0
	add.w	d1,d0


MvSonicOnDoubleSlope:
	btst	#status.player.on_object,status(a1)
	beq.s	return_19C0C
	move.w	x_pos(a1),d0
	sub.w	x_pos(a0),d0
	add.w	d1,d0
	btst	#render_flags.x_flip,render_flags(a0)
	beq.s	loc_19C2C
	not.w	d0
	add.w	d1,d0


Obj01:
	; a0=character
	tst.w	(Debug_placement_mode).w	; is debug mode being used?
	beq.s	Obj01_Normal			; if not, branch
	jmp	(DebugMode).l
; ---------------------------------------------------------------------------
; loc_19F5C:

Obj01_Normal:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj01_Index(pc,d0.w),d1
	jmp	Obj01_Index(pc,d1.w)
; ===========================================================================
; off_19F6A: Obj01_States:

Obj01_Index:	offsetTable
		offsetTableEntry.w Obj01_Init		;  0 - object init
		offsetTableEntry.w Obj01_Control	;  2 - main mode
		offsetTableEntry.w Obj01_Hurt		;  4 - while being knocked back from damage
		offsetTableEntry.w Obj01_Dead		;  6 - while dying and falling off screen
		offsetTableEntry.w Obj01_Gone		;  8 - after dying and waiting for the level to restart
		offsetTableEntry.w Obj01_Respawning	; $A - while waiting for the camera to scroll to the respawn point
; ===========================================================================
; loc_19F76: Obj_01_Sub_0: Obj01_Main:

Obj01_Init:
	addq.b	#2,routine(a0)	; => Obj01_Control
	move.b	#38/2,y_radius(a0)	; this sets Sonic's collision height (2*pixels)
	move.b	#18/2,x_radius(a0) 	; this sets Sonic's Collision width (2*pixels)
	move.l	#MapUnc_Sonic,mappings(a0)	; load Sonic's mappings
	move.b	#2,priority(a0)				; set sprite priority
	move.b	#48/2,width_pixels(a0)		; set render width
	move.b	#1<<render_flags.level_fg,render_flags(a0)	; set to playfield-positioned mode
	move.w	#$600,(Sonic_top_speed).w	; set Sonic's top speed
	move.w	#$C,(Sonic_acceleration).w	; set Sonic's acceleration
	move.w	#$80,(Sonic_deceleration).w	; set Sonic's deceleration
	tst.b	(Last_star_pole_hit).w	; is Sonic starting at a checkpoint?
	bne.s	Obj01_Init_Continued	; if so, branch
	move.w	#make_art_tile(ArtTile_ArtUnc_Sonic,0,0),art_tile(a0)	; load Sonic's art
	bsr.w	Adjust2PArtPointer	; adjust Sonic's art pointer if in 2-player mode
	move.b	#$C,top_solid_bit(a0)
	move.b	#$D,lrb_solid_bit(a0)
	move.w	x_pos(a0),(Saved_x_pos).w
	move.w	y_pos(a0),(Saved_y_pos).w
	move.w	art_tile(a0),(Saved_art_tile).w
	move.w	top_solid_bit(a0),(Saved_Solid_bits).w


Obj01_Init_Continued:
	move.b	#0,flips_remaining(a0)	; reset flips
	move.b	#4,flip_speed(a0)		; reset flip speed(?)
	move.b	#0,(Super_Sonic_flag).w	; reset Super Sonic flag
	move.b	#30,air_left(a0)		; reset air count
	subi.w	#$20,x_pos(a0)
	addi_.w	#4,y_pos(a0)
	move.w	#0,(Sonic_Pos_Record_Index).w

	move.w	#$3F,d2
-	bsr.w	Sonic_RecordPos
	subq.w	#4,a1
	move.l	#0,(a1)
	dbf	d2,-

	addi.w	#$20,x_pos(a0)
	subi_.w	#4,y_pos(a0)

; ---------------------------------------------------------------------------
; Normal state for Sonic
; ---------------------------------------------------------------------------
; loc_1A030: Obj_01_Sub_2:

Obj01_Control:
	tst.w	(Debug_mode_flag).w	; is debug cheat enabled?
	beq.s	+			; if not, branch
	btst	#button_B,(Ctrl_1_Press).w	; is button B pressed?
	beq.s	+			; if not, branch
	move.w	#1,(Debug_placement_mode).w	; change Sonic into a ring/item
	clr.b	(Control_Locked).w		; unlock control
	rts
; -----------------------------------------------------------------------
+	tst.b	(Control_Locked).w	; are controls locked?
	bne.s	+			; if yes, branch
	move.w	(Ctrl_1).w,(Ctrl_1_Logical).w	; copy new held buttons, to enable joypad control
+
	btst	#0,obj_control(a0)	; is Sonic interacting with another object that holds him in place or controls his movement somehow?
	bne.s	+			; if yes, branch to skip Sonic's control
	moveq	#0,d0
	move.b	status(a0),d0
	andi.w	#1<<status.player.in_air|1<<status.player.rolling,d0	; %0000 %0110
	move.w	Obj01_Modes(pc,d0.w),d1
	jsr	Obj01_Modes(pc,d1.w)	; run Sonic's movement control code
+
	cmpi.w	#-$100,(Camera_Min_Y_pos).w	; is vertical wrapping enabled?
	bne.s	+				; if not, branch
	andi.w	#$7FF,y_pos(a0) 		; perform wrapping of Sonic's y position
+
	bsr.s	Sonic_Display	; display Sonic sprite and handle power-up expiration
	bsr.w	Sonic_Super		; handle Sonic in his Super form
	bsr.w	Sonic_RecordPos	; record Sonic's previous position for invincibility stars and Tails
	bsr.w	Sonic_Water		; handle Sonic while underwater
	move.b	(Primary_Angle).w,next_tilt(a0)	; update front collision hot spot
	move.b	(Secondary_Angle).w,tilt(a0)	; update rear collision hot spot
	tst.b	(WindTunnel_flag).w		; is Sonic in a wind tunnel?
	beq.s	+						; if not, branch
	tst.b	anim(a0)				; is current animation null/id_Walk?
	bne.s	+						; if not, branch
	move.b	prev_anim(a0),anim(a0)	;  make sure Sonic is in the correct animation while in a wind tunnel
+
	bsr.w	Sonic_Animate	; run Sonic's animation scripts
	tst.b	obj_control(a0)	; is object interactions ignore flag set?
	bmi.s	+				; if yes, branch
	jsr	(TouchResponse).l	; handle object interactions with Sonic
+
	bra.w	LoadSonicDynPLC	; update Sonic's graphics if necessary

; ===========================================================================
; secondary states under state Obj01_Control
; off_1A0BE:

Obj01_Modes:	offsetTable
		offsetTableEntry.w Obj01_MdNormal_Checks	; 0 - not airborne or rolling
		offsetTableEntry.w Obj01_MdAir			; 2 - airborne
		offsetTableEntry.w Obj01_MdRoll			; 4 - rolling
		offsetTableEntry.w Obj01_MdJump			; 6 - jumping
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A0C6:

Sonic_Display:
	move.w	invulnerable_time(a0),d0	; get Sonic's remaining invulnerability frames after getting hurt
	beq.s	Obj01_Display				; if there are none, branch
	subq.w	#1,invulnerable_time(a0)	; decrease invulnerability frames
	lsr.w	#3,d0						; check every 3 or 4 frames
	bcc.s	Obj01_ChkInvin				; don't render Sonic's sprite
; loc_1A0D4:

Obj01_Display:
	jsr	(DisplaySprite).l				; display Sonic sprite normally
; loc_1A0DA:

Obj01_ChkInvin:
	btst	#status_secondary.invincible,status_secondary(a0)	; is Sonic invincible?
	beq.s	Obj01_ChkShoes										; if not, branch
	tst.w	invincibility_time(a0)		; is there time remaining for invincibility?
	beq.s	Obj01_ChkShoes				; if not, branch
	subq.w	#1,invincibility_time(a0)	; subtract 1 from time
	bne.s	Obj01_ChkShoes				; if time remains, branch
	tst.b	(Current_Boss_ID).w			; is a boss fight active?
	bne.s	Obj01_RmvInvin				; if yes, branch
	cmpi.b	#12,air_left(a0)			; is drowning countdown active?
	blo.s	Obj01_RmvInvin				; if yes, branch
	move.w	(Level_Music).w,d0			; load normal level music
	jsr	(PlayMusic).l					; play normal level music
;loc_1A106:

Obj01_RmvInvin:
	bclr	#status_secondary.invincible,status_secondary(a0)	; remove invincibility
; loc_1A10C:

Obj01_ChkShoes:
	btst	#status_secondary.speed_shoes,status_secondary(a0)	; does Sonic have speed shoes?
	beq.s	Obj01_ExitChk					; if not, branch
	tst.w	speedshoes_time(a0)				; is there time remaining for speed shoes?
	beq.s	Obj01_ExitChk					; if not, branch
	subq.w	#1,speedshoes_time(a0)			; subtract 1 from time
	bne.s	Obj01_ExitChk					; if time remains, branch
	move.w	#$600,(Sonic_top_speed).w		; restore Sonic's default top speed
	move.w	#$C,(Sonic_acceleration).w 		; restore Sonic's default acceleration
	move.w	#$80,(Sonic_deceleration).w		; restore Sonic's default deceleration
	tst.b	(Super_Sonic_flag).w			; is Sonic in his Super form?
	beq.s	Obj01_RmvSpeed					; if not, branch
	move.w	#$A00,(Sonic_top_speed).w		; restore Super Sonic's top speed
	move.w	#$30,(Sonic_acceleration).w		; restore Super Sonic's acceleration
	move.w	#$100,(Sonic_deceleration).w	; restore Super Sonic's deceleration
; loc_1A14A:

Obj01_RmvSpeed:
	bclr	#status_secondary.speed_shoes,status_secondary(a0)	; remove speed shoes
	move.w	#MusID_SlowDown,d0	; Slow down tempo
	jmp	(PlayMusic).l			; play music at normal speed
; ---------------------------------------------------------------------------
; return_1A15A:

Obj01_ExitChk:
	rts							; return
; End of subroutine Sonic_Display

; ---------------------------------------------------------------------------
; Subroutine to record Sonic's previous positions for invincibility stars
; and input/status flags for Tails' AI to follow
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A15C:

Sonic_RecordPos:
	move.w	(Sonic_Pos_Record_Index).w,d0	; get current index for the tracking array
	lea	(Sonic_Pos_Record_Buf).w,a1			; load tracking array
	lea	(a1,d0.w),a1						; set pointer to current index
	move.w	x_pos(a0),(a1)+					; store Sonic's current X-position
	move.w	y_pos(a0),(a1)+					; store Sonic's current Y-position
	addq.b	#4,(Sonic_Pos_Record_Index+1).w	; advance to next tracking pointer (this is a byte, so it wraps from $FC back to $00)

	lea	(Sonic_Stat_Record_Buf).w,a1
	lea	(a1,d0.w),a1
	move.w	(Ctrl_1_Logical).w,(a1)+
	move.w	status(a0),(a1)+ ; Copies `status` AND the byte after it...

	rts
; End of subroutine Sonic_RecordPos

; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

obj0a_character = objoff_3C

; loc_1A186:

Sonic_Water:
	tst.b	(Water_flag).w	; does level have water?
	bne.s	Obj01_InWater	; if yes, branch


Obj01_InWater:
	move.w	(Water_Level_1).w,d0
	cmp.w	y_pos(a0),d0	; is Sonic above the water?
	bge.s	Obj01_OutWater	; if yes, branch

	bset	#status.player.underwater,status(a0)	; set underwater flag
	bne.s	return_1A18C	; if already underwater, branch

	movea.l	a0,a1
	bsr.w	ResumeMusic	; replenish air (music won't resume here, we've only just entered water...)
	move.b	#ObjID_SmallBubbles,(Sonic_BreathingBubbles+id).w ; load Obj0A (Sonic's breathing bubbles) at $FFFFD080
	move.b	#$81,(Sonic_BreathingBubbles+subtype).w	; prepare subtype so it sets itself to Drown_Countdown
	move.l	a0,(Sonic_BreathingBubbles+obj0a_character).w
	move.w	#$300,(Sonic_top_speed).w	; change Sonic's top speed
	move.w	#6,(Sonic_acceleration).w	; change Sonic's acceleration
	move.w	#$40,(Sonic_deceleration).w	; change Sonic's deceleration
	tst.b	(Super_Sonic_flag).w		; is Sonic in his Super form?
	beq.s	+							; if not, branch
	move.w	#$500,(Sonic_top_speed).w	; change Super Sonic's top speed
	move.w	#$18,(Sonic_acceleration).w	; change Super Sonic's acceleration
	move.w	#$80,(Sonic_deceleration).w	; change Super Sonic's deceleration
+
	asr.w	x_vel(a0)		; half X-speed when entering water
	asr.w	y_vel(a0)		; divide Y-speed by 4 when entering water
	asr.w	y_vel(a0)		; (memory operands can only be shifted one bit at a time)
	beq.s	return_1A18C	; if Sonic's new Y-speed is 0, don't load splash object
	move.w	#(1<<8)|(0<<0),(Sonic_Dust+anim).w	; load splash animation from Obj08
	move.w	#SndID_Splash,d0	; load splash sound
	jmp	(PlaySound).l			; play splash sound
; ---------------------------------------------------------------------------
; loc_1A1FE:

Obj01_OutWater:
	bclr	#status.player.underwater,status(a0) ; unset underwater flag
	beq.s	return_1A18C ; if already above water, branch

	movea.l	a0,a1
	bsr.w	ResumeMusic	; replenish air and resume music if necessary
	move.w	#$600,(Sonic_top_speed).w		; restore Sonic's default top speed
	move.w	#$C,(Sonic_acceleration).w		; restore Sonic's default acceleration
	move.w	#$80,(Sonic_deceleration).w		; restore Sonic's default deceleration
	tst.b	(Super_Sonic_flag).w			; is Sonic in his Super form?
	beq.s	+								; if not, branch
	move.w	#$A00,(Sonic_top_speed).w		; restore Super Sonic's top speed
	move.w	#$30,(Sonic_acceleration).w		; restore Super Sonic's acceleration
	move.w	#$100,(Sonic_deceleration).w	; restore Super Sonic's deceleration
+
	cmpi.b	#4,routine(a0)	; is Sonic falling back from getting hurt?
	beq.s	+		; if yes, branch
	asl	y_vel(a0)	; double Y-speed while exiting water
+
	tst.w	y_vel(a0)		; test Sonic's Y-speed
	beq.w	return_1A18C	; branch if 0
	move.w	#(1<<8)|(0<<0),(Sonic_Dust+anim).w	; load splash animation from Obj08
	movea.l	a0,a1
	bsr.w	ResumeMusic	; (why is this repeated?)
	cmpi.w	#-$1000,y_vel(a0)	; is Sonic's new Y-speed too fast?
	bgt.s	+					; if not, branch
	move.w	#-$1000,y_vel(a0)	; limit upward Y-speed
+
	move.w	#SndID_Splash,d0	; load splash sound
	jmp	(PlaySound).l			; play splash sound
; End of subroutine Sonic_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Start of subroutine Obj01_MdNormal
; Called if Sonic is neither airborne nor rolling this frame
; ---------------------------------------------------------------------------
; loc_1A26E:

Obj01_MdNormal_Checks:
	; If Sonic has been waiting for a while, and is tapping his foot
	; impatiently, then make him blink once the player starts moving
	; again. Likewise, if he's been waiting for so long that he's laying
	; down, then make him play an animation of standing up.
	move.b	(Ctrl_1_Press_Logical).w,d0						; load currently pressed buttons
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0	; is A, B, or C pressed?
	bne.s	Obj01_MdNormal									; if yes, branch
	cmpi.b	#AniIDSonAni_Blink,anim(a0)		; is Sonic's animation "Blink"?
	beq.s	Obj01_MdNormal_Skip				; if yes, branch
	cmpi.b	#AniIDSonAni_GetUp,anim(a0)		; is Sonic's animation "GetUp"?				
	beq.s	Obj01_MdNormal_Skip				; if yes, branch
	cmpi.b	#AniIDSonAni_Wait,anim(a0)		; is Sonic's animation "Wait"?
	bne.s	Obj01_MdNormal					; if not, branch
	cmpi.b	#$1E,anim_frame(a0)				; is the animation frame $1E or higher?
	blo.s	Obj01_MdNormal					; if not, branch
	move.b	(Ctrl_1_Held_Logical).w,d0		; load currently held buttons
	andi.b	#button_up_mask|button_down_mask|button_left_mask|button_right_mask|button_B_mask|button_C_mask|button_A_mask,d0	; are the D-Pad or face buttons being held?
	beq.s	Obj01_MdNormal_Skip				; if not, branch
	move.b	#AniIDSonAni_Blink,anim(a0)		; set Sonic's animation to "Blink"
	cmpi.b	#$AC,anim_frame(a0)				; is the animation frame $AC or higher?
	blo.s	Obj01_MdNormal_Skip				; if not, branch
	move.b	#AniIDSonAni_GetUp,anim(a0)		; set Sonic's animation to "GetUp"
	bra.s	Obj01_MdNormal_Skip				; skip normal checks (beware the fixBugs below)
; ---------------------------------------------------------------------------
; loc_1A2B8:

Obj01_MdNormal:
	bsr.w	Sonic_CheckSpindash	; check for spindash
	bsr.w	Sonic_Jump			; check for jumping
	bsr.w	Sonic_SlopeResist	; handle resistance from running up slopes
	bsr.w	Sonic_Move			; handle Sonic's left/right movement
	bsr.w	Sonic_Roll			; check for rolling

    if fixBugs

Obj01_MdNormal_Skip:
    endif
	bsr.w	Sonic_LevelBound	; keep Sonic within level bounds and handle bottomless pits
	jsr	(ObjectMove).l			; update Sonic's position based on his current velocities
	bsr.w	AnglePos			; update Sonic's current angle as he walks along the floor
	bsr.w	Sonic_SlopeRepel	; handle Sonic detaching from walls if not fast enough

    if ~~fixBugs
; return_1A2DE:

Obj01_MdNormal_Skip:
    endif
	rts
; End of subroutine Obj01_MdNormal
; ===========================================================================
; Start of subroutine Obj01_MdAir
; Called if Sonic is airborne, but not in a ball (thus, probably not jumping)
; loc_1A2E0: Obj01_MdJump

Obj01_MdAir:
	bsr.w	Sonic_JumpHeight	; handle Sonic's jump height based on whether the jump button is still held
	bsr.w	Sonic_ChgJumpDir	; handle midair direction adjustments while jumping
	bsr.w	Sonic_LevelBound	; keep Sonic within level bounds and handle bottomless pits
	jsr	(ObjectMoveAndFall).l	; apply gravity and update Sonic's position based on his current velocities
	btst	#status.player.underwater,status(a0)	; is Sonic underwater?
	beq.s	+										; if not, branch
	subi.w	#$28,y_vel(a0)			; reduce gravity by $28 ($38-$28=$10)
+
	bsr.w	Sonic_JumpAngle			; steadily return Sonic's angle while jumping to 0
	bsr.w	Sonic_DoLevelCollision	; handle collision with level while airborne
	rts
; End of subroutine Obj01_MdAir
; ===========================================================================
; Start of subroutine Obj01_MdRoll
; Called if Sonic is in a ball, but not airborne (thus, probably rolling)
; loc_1A30A:

Obj01_MdRoll:
	tst.b	pinball_mode(a0)	; is Sonic in pinball mode?
	bne.s	+					; if yes, branch
	bsr.w	Sonic_Jump			; check for jumping
+
	bsr.w	Sonic_RollRepel		; handle resistance from rolling up slopes
	bsr.w	Sonic_RollSpeed		; update speed as Sonic rolls
	bsr.w	Sonic_LevelBound	; keep Sonic within level bounds and handle bottomless pits
	jsr	(ObjectMove).l			; update Sonic's position based on his current velocities
	bsr.w	AnglePos			; update Sonic's current angle as he walks along the floor
	bsr.w	Sonic_SlopeRepel	; handle Sonic detaching from walls if not fast enough
	rts
; End of subroutine Obj01_MdRoll
; ===========================================================================
; Start of subroutine Obj01_MdJump
; Called if Sonic is in a ball and airborne (he could be jumping but not necessarily)
; Notes: This is identical to Obj01_MdAir, at least at this outer level.
;        Why they gave it a separate copy of the code, I don't know.
; loc_1A330: Obj01_MdJump2:

Obj01_MdJump:
	bsr.w	Sonic_JumpHeight	; handle Sonic's jump height based on whether the jump button is still held
	bsr.w	Sonic_ChgJumpDir	; handle midair direction adjustments while jumping
	bsr.w	Sonic_LevelBound	; keep Sonic within level bounds and handle bottomless pits
	jsr	(ObjectMoveAndFall).l	; apply gravity and update Sonic's position based on his current velocities
	btst	#status.player.underwater,status(a0)	; is Sonic underwater?
	beq.s	+										; if not, branch
	subi.w	#$28,y_vel(a0)			; reduce gravity by $28 ($38-$28=$10)
+
	bsr.w	Sonic_JumpAngle			; steadily return Sonic's angle while jumping to 0
	bsr.w	Sonic_DoLevelCollision	; handle collision with level while airborne
	rts
; End of subroutine Obj01_MdJump

; ---------------------------------------------------------------------------
; Subroutine to make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A35A:

Sonic_Move:
	move.w	(Sonic_top_speed).w,d6		; load Sonic's current top speed
	move.w	(Sonic_acceleration).w,d5	; load Sonic's current acceleration
	move.w	(Sonic_deceleration).w,d4	; load Sonic's current deceleration
	_btst	#status_secondary.sliding,status_secondary(a0)	; is Sonic sliding?
	_bne.w	Obj01_Traction									; if yes, branch
	tst.w	move_lock(a0)									; is D-Pad input locked?
	bne.w	Obj01_ResetScr									; if yes, branch
	btst	#button_left,(Ctrl_1_Held_Logical).w	; is left being pressed?
	beq.s	Obj01_NotLeft							; if not, branch
	bsr.w	Sonic_MoveLeft							; else, branch
; loc_1A382:

Obj01_NotLeft:
	btst	#button_right,(Ctrl_1_Held_Logical).w	; is right being pressed?
	beq.s	Obj01_NotRight							; if not, branch
	bsr.w	Sonic_MoveRight							; else, branch
; loc_1A38E:

Obj01_NotRight:
	move.b	angle(a0),d0	; load Sonic's current angle
	addi.b	#$20,d0			; rotate it 45 degrees clockwise
	andi.b	#$C0,d0			; snap to nearest multiple of 90 degrees
	bne.w	Obj01_ResetScr	; if Sonic is on a slope, then branch
	tst.w	inertia(a0)		; is Sonic moving?
	bne.w	Obj01_ResetScr	; if yes, branch
	bclr	#status.player.pushing,status(a0)	; clear pushing flag
	move.b	#AniIDSonAni_Wait,anim(a0)			; use "standing" animation
	btst	#status.player.on_object,status(a0)	; is Sonic standing on a platform object?
	beq.w	Sonic_Balance						; if not, branch
	moveq	#0,d0								; clear d0
	move.b	interact(a0),d0			; get OST index of object Sonic is currently standing on
    if object_size=$40
	lsl.w	#object_size_bits,d0	; multiply by $40
    else
	mulu.w	#object_size,d0			; multiply by object_size
    endif
	lea	(Object_RAM).w,a1	; load object space (a1=character)
	lea	(a1,d0.w),a1		; load stood-on object (a1=object)
	_btst	#status.npc.no_balancing,status(a1)
	_bne.w	Sonic_Lookup
	moveq	#0,d1				; clear d1
	move.b	width_pixels(a1),d1	; get physical width of stood-on object
	move.w	d1,d2				; copy width
	add.w	d2,d2				; double it
	subq.w	#2,d2				; minus 4
	add.w	x_pos(a0),d1		; get Sonic's current X-position
	sub.w	x_pos(a1),d1		; subtract stood-on object's X-position
	tst.b	(Super_Sonic_flag).w	; is Sonic in his Super form?
	bne.w	SuperSonic_Balance		; if yes, branch
	cmpi.w	#2,d1					; is Sonic within 2px of the objects left edge?
	blt.s	Sonic_BalanceOnObjLeft	; if yes, branch
	cmp.w	d2,d1					; is Sonic within 2px of the objects right edge?
	bge.s	Sonic_BalanceOnObjRight	; if yes, branch
	bra.w	Sonic_Lookup			; else, branch
; ---------------------------------------------------------------------------
; loc_1A3FE:

SuperSonic_Balance:
	cmpi.w	#2,d1							; is Super Sonic within 2px of the objects left edge?
	blt.w	SuperSonic_BalanceOnObjLeft		; if yes, branch
	cmp.w	d2,d1							; is Super Sonic within 2px of the objects right edge?
	bge.w	SuperSonic_BalanceOnObjRight	; if yes, branch
	bra.w	Sonic_Lookup					; else, branch
; ---------------------------------------------------------------------------
; balancing checks for when you're on the right edge of an object
; loc_1A410:

Sonic_BalanceOnObjRight:
	btst	#status.player.x_flip,status(a0)	; is Sonic facing right?
	bne.s	+									; if not, branch
	move.b	#AniIDSonAni_Balance,anim(a0)		; set Sonic's animation to "Balance"
	addq.w	#6,d2
	cmp.w	d2,d1
	blt.w	Obj01_ResetScr
	move.b	#AniIDSonAni_Balance2,anim(a0)		; set Sonic's animation to "Balance2"
	bra.w	Obj01_ResetScr
	; on right edge of object but facing left:
+	move.b	#AniIDSonAni_Balance3,anim(a0)		; set Sonic's animation to "Balance3"
	addq.w	#6,d2
	cmp.w	d2,d1
	blt.w	Obj01_ResetScr
	move.b	#AniIDSonAni_Balance4,anim(a0)		; set Sonic's animation to "Balance4"
	bclr	#status.player.x_flip,status(a0)	; clear X-flip flag (face right)
	bra.w	Obj01_ResetScr
; ---------------------------------------------------------------------------
; balancing checks for when you're on the left edge of an object
; loc_1A44E:

Sonic_BalanceOnObjLeft:
	btst	#status.player.x_flip,status(a0)	; is Sonic facing left?
	beq.s	+									; if not, branch
	move.b	#AniIDSonAni_Balance,anim(a0)		; set Sonic's animation to "Balance"
	cmpi.w	#-4,d1
	bge.w	Obj01_ResetScr
	move.b	#AniIDSonAni_Balance2,anim(a0)		; set Sonic's animation to "Balance2"
	bra.w	Obj01_ResetScr
	; on left edge of object but facing right:
+	move.b	#AniIDSonAni_Balance3,anim(a0)		; set Sonic's animation to "Balance3"
	cmpi.w	#-4,d1
	bge.w	Obj01_ResetScr
	move.b	#AniIDSonAni_Balance4,anim(a0)		; set Sonic's animation to "Balance4"
	bset	#status.player.x_flip,status(a0)	; set X-flip flag (face left)
	bra.w	Obj01_ResetScr
; ---------------------------------------------------------------------------
; balancing checks for when you're on the edge of part of the level
; loc_1A48C:

Sonic_Balance:
	jsr	(ChkFloorEdge).l	; get distance of Sonic to nearest floor
	cmpi.w	#$C,d1			; is he within $C (12px) to floor?
	blt.w	Sonic_Lookup	; if yes, don't do balance animation (would look awkward)
	tst.b	(Super_Sonic_flag).w	; is Sonic in his Super form?
	bne.w	SuperSonic_Balance2		; if yes, branch
	cmpi.b	#3,next_tilt(a0)
	bne.s	Sonic_BalanceLeft
	btst	#status.player.x_flip,status(a0)	; is Sonic facing right?
	bne.s	+									; if not, branch
	move.b	#AniIDSonAni_Balance,anim(a0)		; set Sonic's animation to "Balance"
	move.w	x_pos(a0),d3
	subq.w	#6,d3
	jsr	(ChkFloorEdge_Part2).l
	cmpi.w	#$C,d1
	blt.w	Obj01_ResetScr
	move.b	#AniIDSonAni_Balance2,anim(a0)		; set Sonic's animation to "Balance2"
	bra.w	Obj01_ResetScr
	; on right edge but facing left:
+	move.b	#AniIDSonAni_Balance3,anim(a0)		; set Sonic's animation to "Balance3"
	move.w	x_pos(a0),d3
	subq.w	#6,d3
	jsr	(ChkFloorEdge_Part2).l
	cmpi.w	#$C,d1
	blt.w	Obj01_ResetScr
	move.b	#AniIDSonAni_Balance4,anim(a0)		; set Sonic's animation to "Balance4"
	bclr	#status.player.x_flip,status(a0)
	bra.w	Obj01_ResetScr
; ---------------------------------------------------------------------------

Sonic_BalanceLeft:
	cmpi.b	#3,tilt(a0)
	bne.s	Sonic_Lookup
	btst	#status.player.x_flip,status(a0)	; is Sonic facing left?
	beq.s	+									; if not, branch
	move.b	#AniIDSonAni_Balance,anim(a0)		; set Sonic's animation to "Balance"
	move.w	x_pos(a0),d3
	addq.w	#6,d3
	jsr	(ChkFloorEdge_Part2).l
	cmpi.w	#$C,d1
	blt.w	Obj01_ResetScr
	move.b	#AniIDSonAni_Balance2,anim(a0)		; set Sonic's animation to "Balance2"
	bra.w	Obj01_ResetScr
	; on left edge but facing right:
+	move.b	#AniIDSonAni_Balance3,anim(a0)		; set Sonic's animation to "Balance3"
	move.w	x_pos(a0),d3
	addq.w	#6,d3
	jsr	(ChkFloorEdge_Part2).l
	cmpi.w	#$C,d1
	blt.w	Obj01_ResetScr
	move.b	#AniIDSonAni_Balance4,anim(a0)		; set Sonic's animation to "Balance4"
	bset	#status.player.x_flip,status(a0)	; set X-flip flag (face left)
	bra.w	Obj01_ResetScr
; ---------------------------------------------------------------------------
; loc_1A55E:

SuperSonic_Balance2:
	cmpi.b	#3,next_tilt(a0)
	bne.s	loc_1A56E

; loc_1A566:

SuperSonic_BalanceOnObjRight:
	bclr	#status.player.x_flip,status(a0)	; clear X-flip flag (face right)
	bra.s	loc_1A57C
; ---------------------------------------------------------------------------

SuperSonic_BalanceOnObjLeft:
	bset	#status.player.x_flip,status(a0)	; set X-flip flag (face left)


Sonic_Lookup:
	btst	#button_up,(Ctrl_1_Held_Logical).w	; is up being pressed?
	beq.s	Sonic_Duck							; if not, branch
	move.b	#AniIDSonAni_LookUp,anim(a0)		; use "looking up" animation
	addq.w	#1,(Sonic_Look_delay_counter).w
	cmpi.w	#$78,(Sonic_Look_delay_counter).w
	blo.s	Obj01_ResetScr_Part2
	move.w	#$78,(Sonic_Look_delay_counter).w
	cmpi.w	#$C8,(Camera_Y_pos_bias).w
	beq.s	Obj01_UpdateSpeedOnGround
	addq.w	#2,(Camera_Y_pos_bias).w
	bra.s	Obj01_UpdateSpeedOnGround
; ---------------------------------------------------------------------------
; loc_1A5B2:

Sonic_Duck:
	btst	#button_down,(Ctrl_1_Held_Logical).w	; is down being pressed?
	beq.s	Obj01_ResetScr							; if not, branch
	move.b	#AniIDSonAni_Duck,anim(a0)				; use "ducking" animation
	addq.w	#1,(Sonic_Look_delay_counter).w
	cmpi.w	#$78,(Sonic_Look_delay_counter).w
	blo.s	Obj01_ResetScr_Part2
	move.w	#$78,(Sonic_Look_delay_counter).w
	cmpi.w	#8,(Camera_Y_pos_bias).w
	beq.s	Obj01_UpdateSpeedOnGround
	subq.w	#2,(Camera_Y_pos_bias).w
	bra.s	Obj01_UpdateSpeedOnGround

; ===========================================================================
; moves the screen back to its normal position after looking up or down
; loc_1A5E0:

Obj01_ResetScr:
	move.w	#0,(Sonic_Look_delay_counter).w
; loc_1A5E6:

Obj01_ResetScr_Part2:
	cmpi.w	#(screen_height/2)-16,(Camera_Y_pos_bias).w	; is screen in its default position?
	beq.s	Obj01_UpdateSpeedOnGround	; if yes, branch.
	bhs.s	+				; depending on the sign of the difference,
	addq.w	#4,(Camera_Y_pos_bias).w	; either add 2
+	subq.w	#2,(Camera_Y_pos_bias).w	; or subtract 2

; ---------------------------------------------------------------------------
; updates Sonic's speed on the ground
; ---------------------------------------------------------------------------
; sub_1A5F8:

Obj01_UpdateSpeedOnGround:
	tst.b	(Super_Sonic_flag).w	; is Sonic in his Super form?
	beq.w	+						; if not, branch
	move.w	#$C,d5					; hardcoded Super Sonic deceleration override
+
	move.b	(Ctrl_1_Held_Logical).w,d0				; load currently held buttons
	andi.b	#button_left_mask|button_right_mask,d0	; is left/right pressed?
	bne.s	Obj01_Traction							; if yes, branch
	move.w	inertia(a0),d0							; get Sonic's current ground speed
	beq.s	Obj01_Traction							; is he standing still? if yes, branch
	bmi.s	Obj01_SettleLeft						; is he moving to the left? if yes, branch

; slow down when facing right and not pressing a direction
; Obj01_SettleRight:
	sub.w	d5,d0					; reduce current rightward speed by acceleration
	bcc.s	+						; if result is still to the right, branch
	move.w	#0,d0					; reset speed to zero on sign change
+
	move.w	d0,inertia(a0)			; set Sonic's new ground speed
	bra.s	Obj01_Traction			; skip over
; ---------------------------------------------------------------------------
; slow down when facing left and not pressing a direction
; loc_1A624:

Obj01_SettleLeft:
	add.w	d5,d0					; reduce current leftward speed by acceleration
	bcc.s	+						; if result is still to the left, branch
	move.w	#0,d0					; reset speed to zero on sign change
+
	move.w	d0,inertia(a0)			; set Sonic's new ground speed

; increase or decrease speed on the ground
; loc_1A630:

Obj01_Traction:
	move.b	angle(a0),d0			; get Sonic's current angle in relation to the floor
	jsr	(CalcSine).l				; get sine and cosine values based on angle
	muls.w	inertia(a0),d1			; multiply cosine value by current ground speed
	asr.l	#8,d1					; shift result up a byte
	move.w	d1,x_vel(a0)			; set new X-velocity
	muls.w	inertia(a0),d0			; multiply sine value by current ground spee
	asr.l	#8,d0					; shift result up a byte
	move.w	d0,y_vel(a0)			; set new Y-velocity

; stops Sonic from running through walls that meet the ground
; loc_1A64E:

Obj01_CheckWallsOnGround:
    if fixBugs
	; These lines were added in S3K to fix an oversight where Sonic could
	; run through walls if he is upside-down, or moving on a wall when
	; his angle was exactly $80 (most noticeable in Carnival Night in S3A).
	move.b	angle(a0),d0	; get Sonic's current angle in relation to the floor
	andi.b	#$3F,d0			; is Sonic standing on a flat surface in any of the four quadrants?
	beq.s	.noearlyexit	; if yes, branch
    endif
	move.b	angle(a0),d0	; get Sonic's current angle in relation to the floor
	addi.b	#$40,d0			; rotate it by 90 degrees
	bmi.s	return_1A6BE	; if Sonic is upside down, branch (to prevent potential collision issues with loops)
    if fixBugs
.noearlyexit:
    endif
	move.b	#$40,d1			; Rotate 90 degrees clockwise
	tst.w	inertia(a0)		; Check inertia
	beq.s	return_1A6BE	; If not moving, don't do anything
	bmi.s	+				; If negative, branch
	neg.w	d1				; Otherwise, we want to rotate counterclockwise
+
	move.b	angle(a0),d0	; get Sonic's current angle in relation to the floor
	add.b	d1,d0			; rotate it by 90 degrees depending on directional speed
	move.w	d0,-(sp)		; backup d0
	bsr.w	CalcRoomInFront	; calculate distance to the wall in front of Sonic (if any)
	move.w	(sp)+,d0		; restore d0
	tst.w	d1				; has Sonic touched a wall?
	bpl.s	return_1A6BE	; if not, branch
	asl.w	#8,d1			; convert diff to wall into 8.8 fixed point for adjusting velocity
	addi.b	#$20,d0			; rotate angle by 45 degrees clockwise
	andi.b	#$C0,d0			; snap angle to nearest multiple of 90 degrees
	beq.s	loc_1A6BA		; if Sonic is facing down, branch
	cmpi.b	#$40,d0			; is Sonic facing left?
	beq.s	loc_1A6A8		; if yes, branch
	cmpi.b	#$80,d0			; is Sonic facing up?
	beq.s	loc_1A6A2		; if yes, branch
	; d0 is $C0, Sonic is facing right
	add.w	d1,x_vel(a0)	; adjust X-velocity to prevent Sonic from walking into the wall
	bset	#status.player.pushing,status(a0)	; set pushing flag
	move.w	#0,inertia(a0)						; clear ground speed
	rts
; ---------------------------------------------------------------------------

Sonic_MoveLeft:
	move.w	inertia(a0),d0	; get Sonic's current ground speed
	beq.s	+				; is Sonic standing still? if yes, branch
	bpl.s	Sonic_TurnLeft	; if Sonic is already moving to the right, branch
+
	bset	#status.player.x_flip,status(a0)	; set X-flip flag (Sonic is facing left)
	bne.s	+									; if he already was facing left, branch
	bclr	#status.player.pushing,status(a0)	; clear pushing flag
	move.b	#AniIDSonAni_Run,prev_anim(a0)		; force walking animation to restart if it's already in-progress
+
	sub.w	d5,d0	; add acceleration to the left
	move.w	d6,d1	; get current top speed
	neg.w	d1		; negate it for left-side check
	cmp.w	d1,d0	; compare new speed with top speed
	bgt.s	+		; if new speed is less than the maximum, branch
	add.w	d5,d0	; remove this frame's acceleration change
	cmp.w	d1,d0	; compare speed with top speed
	ble.s	+		; if speed was already greater than the maximum, branch
	move.w	d1,d0	; limit speed on ground going left
+
	move.w	d0,inertia(a0)				; set new ground speed
	move.b	#AniIDSonAni_Walk,anim(a0)	; use walking animation
	rts
; ---------------------------------------------------------------------------
; loc_1A6FA:

Sonic_TurnLeft:
	sub.w	d4,d0			; apply deceleration to current speed
	bcc.s	+				; if still decelerating, branch
	move.w	#-$80,d0		; set minimum speed on sign change
+
	move.w	d0,inertia(a0)	; set new ground speed
    if fixBugs
	move.b	angle(a0),d1	; get Sonic's current angle
	addi.b	#$20,d1			; rotate by 45 degrees clockwise
	andi.b	#$C0,d1			; snap to nearest multiple of 90 degrees
    else
	; These three instructions partially overwrite the inertia value in
	; 'd0'! This causes the character to trigger their skidding
	; animation at different speeds depending on whether they're going
	; right or left. To fix this, make these instructions use 'd1'
	; instead.
	move.b	angle(a0),d0	; get Sonic's current angle (and partially overwrite d0...)
	addi.b	#$20,d0			; rotate by 45 degrees clockwise
	andi.b	#$C0,d0			; snap to nearest multiple of 90 degrees
    endif
	bne.s	return_1A744	; if Sonic is on a wall or ceiling, prevent stopping animation
	cmpi.w	#$400,d0		; has Sonic changed direction while being really fast?
	blt.s	return_1A744	; if not, don't play skidding animation/sound
	move.b	#AniIDSonAni_Stop,anim(a0)			; use "stopping" animation
	bclr	#status.player.x_flip,status(a0)	; clear X-flip flag (Sonic is now facing right)
	move.w	#SndID_Skidding,d0					; load skidding sound
	jsr	(PlaySound).l							; play skidding sound
	cmpi.b	#12,air_left(a0)					; is Sonic drowning?
	blo.s	return_1A744						; if yes, branch
	move.b	#6,(Sonic_Dust+routine).w			; set Obj08's routine to skidding
	move.b	#$15,(Sonic_Dust+mapping_frame).w	; set skidding dust's frame


Sonic_MoveRight:
	move.w	inertia(a0),d0	; get Sonic's current ground speed
	bmi.s	Sonic_TurnRight	; if Sonic is already moving to the left, branch
	bclr	#status.player.x_flip,status(a0)	; clear X-flip flag (Sonic is facing right)
	beq.s	+									; if he already was facing right, branch
	bclr	#status.player.pushing,status(a0)	; clear pushing flag
	move.b	#AniIDSonAni_Run,prev_anim(a0)		; force walking animation to restart if it's already in-progress
+
	add.w	d5,d0	; add acceleration to the right
	cmp.w	d6,d0	; compare new speed with top speed
	blt.s	+		; if new speed is less than the maximum, branch
	sub.w	d5,d0	; remove this frame's acceleration change
	cmp.w	d6,d0	; compare speed with top speed
	bge.s	+		; if speed was already greater than the maximum, branch
	move.w	d6,d0	; limit speed on ground going right
+
	move.w	d0,inertia(a0)				; set new ground speed
	move.b	#AniIDSonAni_Walk,anim(a0)	; use walking animation
	rts
; ---------------------------------------------------------------------------
; loc_1A77A:

Sonic_TurnRight:
	add.w	d4,d0	; apply deceleration to current speed
	bcc.s	+		; if still decelerating, branch
	move.w	#$80,d0	; set minimum speed on sign change
+
	move.w	d0,inertia(a0)	; set new ground speed
    if fixBugs
	move.b	angle(a0),d1	; get Sonic's current angle
	addi.b	#$20,d1			; rotate by 45 degrees clockwise
	andi.b	#$C0,d1			; snap to nearest multiple of 90 degrees
    else
	; These three instructions partially overwrite the inertia value in
	; 'd0'! This causes the character to trigger their skidding
	; animation at different speeds depending on whether they're going
	; right or left. To fix this, make these instructions use 'd1'
	; instead.
	move.b	angle(a0),d0	; get Sonic's current angle (and partially overwrite d0...)
	addi.b	#$20,d0			; rotate by 45 degrees clockwise
	andi.b	#$C0,d0			; snap to nearest multiple of 90 degrees
    endif
	bne.s	return_1A7C4	; if Sonic is on a wall or ceiling, prevent stopping animation
	cmpi.w	#-$400,d0		; has Sonic changed direction while being really fast?
	bgt.s	return_1A7C4	; if not, don't play skidding animation/sound
	move.b	#AniIDSonAni_Stop,anim(a0)			; use "stopping" animation
	bset	#status.player.x_flip,status(a0)	; set X-flip flag (Sonic is now facing left)
	move.w	#SndID_Skidding,d0					; load skidding sound
	jsr	(PlaySound).l							; play skidding sound
	cmpi.b	#12,air_left(a0)					; is Sonic drowning?
	blo.s	return_1A7C4						; if yes, branch
	move.b	#6,(Sonic_Dust+routine).w			; set Obj08's routine to skidding
	move.b	#$15,(Sonic_Dust+mapping_frame).w	; set skidding dust's frame


Sonic_RollSpeed:
	move.w	(Sonic_top_speed).w,d6
	asl.w	#1,d6
	move.w	(Sonic_acceleration).w,d5
	asr.w	#1,d5	; natural roll deceleration = 1/2 normal acceleration
	move.w	#$20,d4	; controlled roll deceleration... interestingly,
			; this should be Sonic_deceleration/4 according to Tails_RollSpeed,
			; which means Sonic is much better than Tails at slowing down his rolling when he's underwater
	_btst	#status_secondary.sliding,status_secondary(a0)
	_bne.w	Obj01_Roll_ResetScr
	tst.w	move_lock(a0)
	bne.s	Sonic_ApplyRollSpeed
	btst	#button_left,(Ctrl_1_Held_Logical).w	; is left being pressed?
	beq.s	+				; if not, branch
	bsr.w	Sonic_RollLeft
+
	btst	#button_right,(Ctrl_1_Held_Logical).w	; is right being pressed?
	beq.s	Sonic_ApplyRollSpeed		; if not, branch
	bsr.w	Sonic_RollRight

; loc_1A7FC:

Sonic_ApplyRollSpeed:
	move.w	inertia(a0),d0
	beq.s	Sonic_CheckRollStop
	bmi.s	Sonic_ApplyRollSpeedLeft

; Sonic_ApplyRollSpeedRight:
	sub.w	d5,d0
	bcc.s	+
	move.w	#0,d0
+
	move.w	d0,inertia(a0)
	bra.s	Sonic_CheckRollStop
; ---------------------------------------------------------------------------
; loc_1A812:

Sonic_ApplyRollSpeedLeft:
	add.w	d5,d0
	bcc.s	+
	move.w	#0,d0
+
	move.w	d0,inertia(a0)

; loc_1A81E:

Sonic_CheckRollStop:
	tst.w	inertia(a0)
	bne.s	Obj01_Roll_ResetScr
	tst.b	pinball_mode(a0) ; note: the spindash flag has a different meaning when Sonic's already rolling -- it's used to mean he's not allowed to stop rolling
	bne.s	Sonic_KeepRolling
	bclr	#status.player.rolling,status(a0)
	move.b	#38/2,y_radius(a0)
	move.b	#18/2,x_radius(a0)
	move.b	#AniIDSonAni_Wait,anim(a0)
	subq.w	#5,y_pos(a0)
	bra.s	Obj01_Roll_ResetScr

; ---------------------------------------------------------------------------
; magically gives Sonic an extra push if he's going to stop rolling where it's not allowed
; (such as in an S-curve in HTZ or a stopper chamber in CNZ)
; loc_1A848:

Sonic_KeepRolling:
	move.w	#$400,inertia(a0)
	btst	#status.player.x_flip,status(a0)
	beq.s	Obj01_Roll_ResetScr
	neg.w	inertia(a0)

; resets the screen to normal while rolling, like Obj01_ResetScr
; loc_1A85A:

Obj01_Roll_ResetScr:
	cmpi.w	#(screen_height/2)-16,(Camera_Y_pos_bias).w	; is screen in its default position?
	beq.s	Sonic_SetRollSpeeds		; if yes, branch
	bhs.s	+				; depending on the sign of the difference,
	addq.w	#4,(Camera_Y_pos_bias).w	; either add 2
+	subq.w	#2,(Camera_Y_pos_bias).w	; or subtract 2

; loc_1A86C:

Sonic_SetRollSpeeds:
	move.b	angle(a0),d0
	jsr	(CalcSine).l
	muls.w	inertia(a0),d0
	asr.l	#8,d0
	move.w	d0,y_vel(a0)	; set y velocity based on $14 and angle
	muls.w	inertia(a0),d1
	asr.l	#8,d1
	cmpi.w	#$1000,d1
	ble.s	+
	move.w	#$1000,d1	; limit Sonic's speed rolling right
+
	cmpi.w	#-$1000,d1
	bge.s	+
	move.w	#-$1000,d1	; limit Sonic's speed rolling left
+
	move.w	d1,x_vel(a0)	; set x velocity based on $14 and angle
	bra.w	Obj01_CheckWallsOnGround
; End of function Sonic_RollSpeed


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; loc_1A8A2:

Sonic_RollLeft:
	move.w	inertia(a0),d0
	beq.s	+
	bpl.s	Sonic_BrakeRollingRight
+
	bset	#status.player.x_flip,status(a0)
	move.b	#AniIDSonAni_Roll,anim(a0)	; use "rolling" animation
	rts
; ---------------------------------------------------------------------------
; loc_1A8B8:

Sonic_BrakeRollingRight:
	sub.w	d4,d0	; reduce rightward rolling speed
	bcc.s	+
	move.w	#-$80,d0
+
	move.w	d0,inertia(a0)
	rts
; End of function Sonic_RollLeft


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; loc_1A8C6:

Sonic_RollRight:
	move.w	inertia(a0),d0
	bmi.s	Sonic_BrakeRollingLeft
	bclr	#status.player.x_flip,status(a0)
	move.b	#AniIDSonAni_Roll,anim(a0)	; use "rolling" animation
	rts
; ---------------------------------------------------------------------------
; loc_1A8DA:

Sonic_BrakeRollingLeft:
	add.w	d4,d0	; reduce leftward rolling speed
	bcc.s	+
	move.w	#$80,d0
+
	move.w	d0,inertia(a0)
	rts
; End of subroutine Sonic_RollRight


; ---------------------------------------------------------------------------
; Subroutine for moving Sonic left or right when he's in the air
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A8E8:

Sonic_ChgJumpDir:
	move.w	(Sonic_top_speed).w,d6
	move.w	(Sonic_acceleration).w,d5
	asl.w	#1,d5
	btst	#status.player.rolljumping,status(a0)	; did Sonic jump from rolling?
	bne.s	Obj01_Jump_ResetScr			; if yes, branch to skip midair control
	move.w	x_vel(a0),d0
	btst	#button_left,(Ctrl_1_Held_Logical).w
	beq.s	+	; if not holding left, branch

	bset	#status.player.x_flip,status(a0)
	sub.w	d5,d0	; add acceleration to the left
	move.w	d6,d1
	neg.w	d1
	cmp.w	d1,d0	; compare new speed with top speed
	bgt.s	+	; if new speed is less than the maximum, branch
	move.w	d1,d0	; limit speed in air going left, even if Sonic was already going faster (speed limit/cap)
+
	btst	#button_right,(Ctrl_1_Held_Logical).w
	beq.s	+	; if not holding right, branch

	bclr	#status.player.x_flip,status(a0)
	add.w	d5,d0	; accelerate right in the air
	cmp.w	d6,d0	; compare new speed with top speed
	blt.s	+	; if new speed is less than the maximum, branch
	move.w	d6,d0	; limit speed in air going right, even if Sonic was already going faster (speed limit/cap)
; Obj01_JumpMove:
+	move.w	d0,x_vel(a0)

; loc_1A932: Obj01_ResetScr2:

Obj01_Jump_ResetScr:
	cmpi.w	#(screen_height/2)-16,(Camera_Y_pos_bias).w	; is screen in its default position?
	beq.s	Sonic_JumpPeakDecelerate	; if yes, branch
	bhs.s	+				; depending on the sign of the difference,
	addq.w	#4,(Camera_Y_pos_bias).w	; either add 2
+	subq.w	#2,(Camera_Y_pos_bias).w	; or subtract 2

; loc_1A944:

Sonic_JumpPeakDecelerate:
	cmpi.w	#-$400,y_vel(a0)	; is Sonic moving faster than -$400 upwards?
	blo.s	return_1A972		; if yes, return
	move.w	x_vel(a0),d0
	move.w	d0,d1
	asr.w	#5,d1		; d1 = x_velocity / 32
	beq.s	return_1A972	; return if d1 is 0
	bmi.s	Sonic_JumpPeakDecelerateLeft	; branch if moving left

; Sonic_JumpPeakDecelerateRight:
	sub.w	d1,d0	; reduce x velocity by d1
	bcc.s	+
	move.w	#0,d0
+
	move.w	d0,x_vel(a0)
	rts
;-------------------------------------------------------------
; loc_1A966:

Sonic_JumpPeakDecelerateLeft:
	sub.w	d1,d0	; reduce x velocity by d1
	bcs.s	+
	move.w	#0,d0
+
	move.w	d0,x_vel(a0)


Sonic_LevelBound:
	move.l	x_pos(a0),d1
	move.w	x_vel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d1
	swap	d1
	move.w	(Camera_Min_X_pos).w,d0
	addi.w	#$10,d0
	cmp.w	d1,d0			; has Sonic touched the left boundary?
	bhi.s	Sonic_Boundary_Sides	; if yes, branch
	move.w	(Camera_Max_X_pos).w,d0
	addi.w	#screen_width-24,d0		; screen width - Sonic's width_pixels
	tst.b	(Current_Boss_ID).w
	bne.s	+
	addi.w	#$40,d0
+
	cmp.w	d1,d0			; has Sonic touched the right boundary?
	bls.s	Sonic_Boundary_Sides	; if yes, branch

; loc_1A9A6:

Sonic_Boundary_CheckBottom:
	move.w	(Camera_Max_Y_pos).w,d0
    if fixBugs
	; The original code does not consider that the camera boundary
	; may be in the middle of lowering itself, which is why going
	; down the S-tunnel in Green Hill Zone Act 1 fast enough can
	; kill Sonic.
	move.w	(Camera_Max_Y_pos_target).w,d1
	cmp.w	d0,d1
	blo.s	.skip
	move.w	d1,d0
.skip:
    endif
	addi.w	#screen_height,d0
	cmp.w	y_pos(a0),d0		; has Sonic touched the bottom boundary?
	blt.s	Sonic_Boundary_Bottom	; if yes, branch
	rts
; ---------------------------------------------------------------------------

Sonic_Boundary_Bottom: ;;
    if fixBugs
	; a2 needs to be set here, otherwise KillCharacter
	; will access a dangling pointer!
	movea.l	a0,a2
    endif
	jmpto	JmpTo_KillCharacter
; ===========================================================================

; loc_1A9BA:

Sonic_Boundary_Sides:
	move.w	d0,x_pos(a0)
	move.w	#0,2+x_pos(a0) ; subpixel x
	move.w	#0,x_vel(a0)
	move.w	#0,inertia(a0)
	bra.s	Sonic_Boundary_CheckBottom
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to start rolling when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A9D2:

Sonic_Roll:
	_btst	#status_secondary.sliding,status_secondary(a0)
	_bne.s	Obj01_NoRoll
	mvabs.w	inertia(a0),d0
	cmpi.w	#$80,d0		; is Sonic moving at $80 speed or faster?
	blo.s	Obj01_NoRoll	; if not, branch
	move.b	(Ctrl_1_Held_Logical).w,d0
	andi.b	#button_left_mask|button_right_mask,d0 ; is left/right being pressed?
	bne.s	Obj01_NoRoll	; if yes, branch
	btst	#button_down,(Ctrl_1_Held_Logical).w ; is down being pressed?
	bne.s	Obj01_ChkRoll			; if yes, branch
; return_1A9F8:

Obj01_NoRoll:
	rts

; ---------------------------------------------------------------------------
; loc_1A9FA:

Obj01_ChkRoll:
	btst	#status.player.rolling,status(a0)	; is Sonic already rolling?
	beq.s	Obj01_DoRoll	; if not, branch
	rts

; ---------------------------------------------------------------------------
; loc_1AA04:

Obj01_DoRoll:
	bset	#status.player.rolling,status(a0)
	move.b	#28/2,y_radius(a0)
	move.b	#14/2,x_radius(a0)
	move.b	#AniIDSonAni_Roll,anim(a0)	; use "rolling" animation
	addq.w	#5,y_pos(a0)
	move.w	#SndID_Roll,d0
	jsr	(PlaySound).l	; play rolling sound
	tst.w	inertia(a0)
	bne.s	return_1AA36
	move.w	#$200,inertia(a0)


Sonic_Jump:
	move.b	(Ctrl_1_Press_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0 ; is A, B or C pressed?
	beq.w	return_1AAE6	; if not, return
	moveq	#0,d0
	move.b	angle(a0),d0
	addi.b	#$80,d0
	bsr.w	CalcRoomOverHead
	cmpi.w	#6,d1			; does Sonic have enough room to jump?
	blt.w	return_1AAE6		; if not, branch
	move.w	#$680,d2
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	move.w	#$800,d2	; set higher jump speed if super
+
	btst	#status.player.underwater,status(a0)	; Test if underwater
	beq.s	+
	move.w	#$380,d2	; set lower jump speed if underwater
+
	moveq	#0,d0
	move.b	angle(a0),d0
	subi.b	#$40,d0
	jsr	(CalcSine).l
	muls.w	d2,d1
	asr.l	#8,d1
	add.w	d1,x_vel(a0)	; make Sonic jump (in X... this adds nothing on level ground)
	muls.w	d2,d0
	asr.l	#8,d0
	add.w	d0,y_vel(a0)	; make Sonic jump (in Y)
	bset	#status.player.in_air,status(a0)
	bclr	#status.player.pushing,status(a0)
	addq.l	#4,sp
	move.b	#1,jumping(a0)
	clr.b	stick_to_convex(a0)
	move.w	#SndID_Jump,d0
	jsr	(PlaySound).l	; play jumping sound
    if ~~fixBugs
	; These lines are a remnant of the victory animation that would play
	; when jumping at the end of a stage in the Sonic 1 prototype. Not only
	; are these two lines now useless, they also cause Sonic to incorrectly
	; reset to his standing collision when roll-jumping.
	move.b	#38/2,y_radius(a0)
	move.b	#18/2,x_radius(a0)
    endif
	btst	#status.player.rolling,status(a0)
	bne.s	Sonic_RollJump
	move.b	#28/2,y_radius(a0)
	move.b	#14/2,x_radius(a0)
	move.b	#AniIDSonAni_Roll,anim(a0)	; use "jumping" animation
	bset	#status.player.rolling,status(a0)
	addq.w	#5,y_pos(a0)


Sonic_RollJump:
	bset	#status.player.rolljumping,status(a0)	; set the rolling+jumping flag
	rts
; End of function Sonic_Jump


; ---------------------------------------------------------------------------
; Subroutine letting Sonic control the height of the jump
; when the jump button is released
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ===========================================================================
; loc_1AAF0:

Sonic_JumpHeight:
	tst.b	jumping(a0)	; is Sonic jumping?
	beq.s	Sonic_UpVelCap	; if not, branch

	move.w	#-$400,d1
	btst	#status.player.underwater,status(a0)	; is Sonic underwater?
	beq.s	+		; if not, branch
	move.w	#-$200,d1
+
	cmp.w	y_vel(a0),d1	; is Sonic going up faster than d1?
	ble.s	+		; if not, branch
	move.b	(Ctrl_1_Held_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0 ; is a jump button pressed?
	bne.s	+		; if yes, branch
	move.w	d1,y_vel(a0)	; immediately reduce Sonic's upward speed to d1
+
	tst.b	y_vel(a0)		; is Sonic exactly at the height of his jump?
	beq.s	Sonic_CheckGoSuper	; if yes, test for turning into Super Sonic
	rts
; ---------------------------------------------------------------------------
; loc_1AB22:

Sonic_UpVelCap:
	tst.b	pinball_mode(a0)	; is Sonic charging a spindash or in a rolling-only area?
	bne.s	return_1AB36		; if yes, return
	cmpi.w	#-$FC0,y_vel(a0)	; is Sonic moving up really fast?
	bge.s	return_1AB36		; if not, return
	move.w	#-$FC0,y_vel(a0)	; cap upward speed


Sonic_CheckGoSuper:
	tst.b	(Super_Sonic_flag).w	; is Sonic already Super?
	bne.s	return_1ABA4		; if yes, branch
	cmpi.b	#7,(Emerald_count).w	; does Sonic have exactly 7 emeralds?
	bne.s	return_1ABA4		; if not, branch
	cmpi.w	#50,(Ring_count).w	; does Sonic have at least 50 rings?
	blo.s	return_1ABA4		; if not, branch
    if gameRevision>=2
	; fixes a bug where the player can get stuck if transforming at the end of a level
	tst.b	(Update_HUD_timer).w	; has Sonic reached the end of the act?
	beq.s	return_1ABA4		; if yes, branch
    endif

    if fixBugs
	; If Sonic was executing a roll-jump when he turned Super, then this
	; will remove him from that state. The original code forgot to do
	; this.
	andi.b	#~(1<<status.player.rolling|1<<status.player.rolljumping),status(a0)	; Clear bits 2 and 4
	move.b	#38/2,y_radius(a0)
	move.b	#18/2,x_radius(a0)
    endif
	move.b	#1,(Super_Sonic_palette).w
	move.b	#$F,(Palette_timer).w
	move.b	#1,(Super_Sonic_flag).w
	move.b	#$81,obj_control(a0)
	move.b	#AniIDSupSonAni_Transform,anim(a0)			; use transformation animation
	move.b	#ObjID_SuperSonicStars,(SuperSonicStars+id).w ; load Obj7E (Super Sonic stars object) at $FFFFD040
	move.w	#$A00,(Sonic_top_speed).w
	move.w	#$30,(Sonic_acceleration).w
	move.w	#$100,(Sonic_deceleration).w
	move.w	#0,invincibility_time(a0)
	bset	#status_secondary.invincible,status_secondary(a0)	; make Sonic invincible
	move.w	#SndID_SuperTransform,d0
	jsr	(PlaySound).l	; Play transformation sound effect.
	move.w	#MusID_SuperSonic,d0
	jmp	(PlayMusic).l	; load the Super Sonic song and return

; ---------------------------------------------------------------------------

Sonic_Super:
	tst.b	(Super_Sonic_flag).w	; Ignore all this code if not Super Sonic
	beq.w	return_1AC3C
	tst.b	(Update_HUD_timer).w
	beq.s	Sonic_RevertToNormal ; ?
	subq.w	#1,(Super_Sonic_frame_count).w
	bpl.w	return_1AC3C
	move.w	#60,(Super_Sonic_frame_count).w	; Reset frame counter to 60
	tst.w	(Ring_count).w
	beq.s	Sonic_RevertToNormal
	ori.b	#1,(Update_HUD_rings).w
	cmpi.w	#1,(Ring_count).w
	beq.s	+
	cmpi.w	#10,(Ring_count).w
	beq.s	+
	cmpi.w	#100,(Ring_count).w
	bne.s	++
+
	ori.b	#$80,(Update_HUD_rings).w
+
	subq.w	#1,(Ring_count).w
	bne.s	return_1AC3C
; loc_1ABF2:

Sonic_RevertToNormal:
	move.b	#2,(Super_Sonic_palette).w	; Remove rotating palette
	move.w	#$28,(Palette_frame).w
	move.b	#0,(Super_Sonic_flag).w
	move.b	#AniIDSonAni_Run,prev_anim(a0)	; Force Sonic's animation to restart
	move.w	#1,invincibility_time(a0)	; Remove invincibility
	move.w	#$600,(Sonic_top_speed).w
	move.w	#$C,(Sonic_acceleration).w
	move.w	#$80,(Sonic_deceleration).w
	btst	#status.player.underwater,status(a0)	; Check if underwater, return if not
	beq.s	return_1AC3C
	move.w	#$300,(Sonic_top_speed).w
	move.w	#6,(Sonic_acceleration).w
	move.w	#$40,(Sonic_deceleration).w


Sonic_CheckSpindash:
	tst.b	spindash_flag(a0)
	bne.s	Sonic_UpdateSpindash
	cmpi.b	#AniIDSonAni_Duck,anim(a0)
	bne.s	return_1AC8C
	move.b	(Ctrl_1_Press_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
	beq.w	return_1AC8C
	move.b	#AniIDSonAni_Spindash,anim(a0)
	move.w	#SndID_SpindashRev,d0
	jsr	(PlaySound).l
	addq.l	#4,sp
	move.b	#1,spindash_flag(a0)
	move.w	#0,spindash_counter(a0)
	cmpi.b	#12,air_left(a0)	; if he's drowning, branch to not make dust
	blo.s	+
	move.b	#2,(Sonic_Dust+anim).w
+
	bsr.w	Sonic_LevelBound
	bsr.w	AnglePos


Sonic_UpdateSpindash:
	move.b	(Ctrl_1_Held_Logical).w,d0
	btst	#button_down,d0
	bne.w	Sonic_ChargingSpindash

	; unleash the charged spindash and start rolling quickly:
	move.b	#28/2,y_radius(a0)
	move.b	#14/2,x_radius(a0)
	move.b	#AniIDSonAni_Roll,anim(a0)
	addq.w	#5,y_pos(a0)	; add the difference between Sonic's rolling and standing heights
	move.b	#0,spindash_flag(a0)
	moveq	#0,d0
	move.b	spindash_counter(a0),d0
	add.w	d0,d0
	move.w	SpindashSpeeds(pc,d0.w),inertia(a0)
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	move.w	SpindashSpeedsSuper(pc,d0.w),inertia(a0)
+
	; Determine how long to lag the camera for.
	; Notably, the faster Sonic goes, the less the camera lags.
	; This is seemingly to prevent Sonic from going off-screen.
	move.w	inertia(a0),d0
	subi.w	#$800,d0 ; $800 is the lowest spin dash speed
    if fixBugs
	; To fix a bug in 'ScrollHoriz', we need an extra variable, so this
	; code has been modified to make the delay value only a single byte.
	; The lower byte has been repurposed to hold a copy of the position
	; array index at the time that the spin dash was released.
	; This is used by the fixed 'ScrollHoriz'.
	lsr.w	#7,d0
	neg.w	d0
	addi.w	#$20,d0
	move.b	d0,(Horiz_scroll_delay_val).w
	; Back up the position array index for later.
	move.b	(Sonic_Pos_Record_Index+1).w,(Horiz_scroll_delay_val+1).w
    else
	add.w	d0,d0
	andi.w	#$1F00,d0 ; This line is not necessary, as none of the removed bits are ever set in the first place
	neg.w	d0
	addi.w	#$2000,d0
	move.w	d0,(Horiz_scroll_delay_val).w
    endif

	btst	#status.player.x_flip,status(a0)
	beq.s	+
	neg.w	inertia(a0)
+
	bset	#status.player.rolling,status(a0)
	move.b	#0,(Sonic_Dust+anim).w
	move.w	#SndID_SpindashRelease,d0	; spindash zoom sound
	jsr	(PlaySound).l
	bra.s	Obj01_Spindash_ResetScr
; ===========================================================================
; word_1AD0C:

Sonic_ChargingSpindash:			; If still charging the dash...
	tst.w	spindash_counter(a0)
	beq.s	+
	move.w	spindash_counter(a0),d0
	lsr.w	#5,d0
	sub.w	d0,spindash_counter(a0)
	bcc.s	+
	move.w	#0,spindash_counter(a0)
+
	move.b	(Ctrl_1_Press_Logical).w,d0
	andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
	beq.w	Obj01_Spindash_ResetScr
	move.w	#(AniIDSonAni_Spindash<<8)|(AniIDSonAni_Walk<<0),anim(a0)
	move.w	#SndID_SpindashRev,d0
	jsr	(PlaySound).l
	addi.w	#$200,spindash_counter(a0)
	cmpi.w	#$800,spindash_counter(a0)
	blo.s	Obj01_Spindash_ResetScr
	move.w	#$800,spindash_counter(a0)

; loc_1AD78:

Obj01_Spindash_ResetScr:
	addq.l	#4,sp
	cmpi.w	#(screen_height/2)-16,(Camera_Y_pos_bias).w
	beq.s	loc_1AD8C
	bhs.s	+
	addq.w	#4,(Camera_Y_pos_bias).w
+	subq.w	#2,(Camera_Y_pos_bias).w


Sonic_SlopeResist:
	move.b	angle(a0),d0
	addi.b	#$60,d0
	cmpi.b	#$C0,d0
	bhs.s	return_1ADCA
	move.b	angle(a0),d0
	jsr	(CalcSine).l
	muls.w	#$20,d0
	asr.l	#8,d0
	tst.w	inertia(a0)
	beq.s	return_1ADCA
	bmi.s	loc_1ADC6
	tst.w	d0
	beq.s	+
	add.w	d0,inertia(a0)	; change Sonic's $14
+
	rts
; ---------------------------------------------------------------------------


Sonic_RollRepel:
	move.b	angle(a0),d0
	addi.b	#$60,d0
	cmpi.b	#$C0,d0
	bhs.s	return_1AE06
	move.b	angle(a0),d0
	jsr	(CalcSine).l
	muls.w	#$50,d0
	asr.l	#8,d0
	tst.w	inertia(a0)
	bmi.s	loc_1ADFC
	tst.w	d0
	bpl.s	loc_1ADF6
	asr.l	#2,d0


Sonic_SlopeRepel:
	nop
	tst.b	stick_to_convex(a0)
	bne.s	return_1AE42
	tst.w	move_lock(a0)
	bne.s	loc_1AE44
	move.b	angle(a0),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0
	beq.s	return_1AE42
	mvabs.w	inertia(a0),d0
	cmpi.w	#$280,d0
	bhs.s	return_1AE42
	clr.w	inertia(a0)
	bset	#status.player.in_air,status(a0)
	move.w	#$1E,move_lock(a0)


Sonic_JumpAngle:
	move.b	angle(a0),d0	; get Sonic's angle
	beq.s	Sonic_JumpFlip	; if already 0, branch
	bpl.s	loc_1AE5A	; if higher than 0, branch

	addq.b	#2,d0		; increase angle
	bcc.s	BranchTo_Sonic_JumpAngleSet
	moveq	#0,d0

BranchTo_Sonic_JumpAngleSet ; BranchTo
	bra.s	Sonic_JumpAngleSet
; ===========================================================================


Sonic_JumpAngleSet:
	move.b	d0,angle(a0)
; End of function Sonic_JumpAngle
	; continue straight to Sonic_JumpFlip

; ---------------------------------------------------------------------------
; Updates Sonic's secondary angle if he's tumbling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AE64:

Sonic_JumpFlip:
	move.b	flip_angle(a0),d0
	beq.s	return_1AEA8
	tst.w	inertia(a0)
	bmi.s	Sonic_JumpLeftFlip
; loc_1AE70:

Sonic_JumpRightFlip:
	move.b	flip_speed(a0),d1
	add.b	d1,d0
	bcc.s	BranchTo_Sonic_JumpFlipSet
	subq.b	#1,flips_remaining(a0)
	bcc.s	BranchTo_Sonic_JumpFlipSet
	move.b	#0,flips_remaining(a0)
	moveq	#0,d0

BranchTo_Sonic_JumpFlipSet ; BranchTo
	bra.s	Sonic_JumpFlipSet
; ===========================================================================
; loc_1AE88:

Sonic_JumpLeftFlip:
	tst.b	flip_turned(a0)
	bne.s	Sonic_JumpRightFlip
	move.b	flip_speed(a0),d1
	sub.b	d1,d0
	bcc.s	Sonic_JumpFlipSet
	subq.b	#1,flips_remaining(a0)
	bcc.s	Sonic_JumpFlipSet
	move.b	#0,flips_remaining(a0)
	moveq	#0,d0
; loc_1AEA4:

Sonic_JumpFlipSet:
	move.b	d0,flip_angle(a0)


Sonic_DoLevelCollision:
	move.l	#Primary_Collision,(Collision_addr).w
	cmpi.b	#$C,top_solid_bit(a0)
	beq.s	+
	move.l	#Secondary_Collision,(Collision_addr).w
+
	move.b	lrb_solid_bit(a0),d5
	move.w	x_vel(a0),d1
	move.w	y_vel(a0),d2
	jsr	(CalcAngle).l
	subi.b	#$20,d0
	andi.b	#$C0,d0
	cmpi.b	#$40,d0
	beq.w	Sonic_HitLeftWall
	cmpi.b	#$80,d0
	beq.w	Sonic_HitCeilingAndWalls
	cmpi.b	#$C0,d0
	beq.w	Sonic_HitRightWall
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	+
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Sonic since he hit a wall
+
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	+
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Sonic since he hit a wall
+
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1AF8A
	move.b	y_vel(a0),d2
	addq.b	#8,d2
	neg.b	d2
	cmp.b	d2,d1
	bge.s	+
	cmp.b	d2,d0
	blt.s	return_1AF8A
+
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	bsr.w	Sonic_ResetOnFloor
	move.b	d3,d0
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	loc_1AF68
	move.b	d3,d0
	addi.b	#$10,d0
	andi.b	#$20,d0
	beq.s	loc_1AF5A
	asr	y_vel(a0)
	bra.s	loc_1AF7C
; ===========================================================================


Sonic_HitLeftWall:
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	Sonic_HitCeiling ; branch if distance is positive (not inside wall)
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Sonic since he hit a wall
	move.w	y_vel(a0),inertia(a0)
	rts
; ===========================================================================
; loc_1AFA6:

Sonic_HitCeiling:
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	Sonic_HitFloor ; branch if distance is positive (not inside ceiling)
	sub.w	d1,y_pos(a0)
	tst.w	y_vel(a0)
	bpl.s	return_1AFBE
	move.w	#0,y_vel(a0) ; stop Sonic in y since he hit a ceiling


Sonic_HitFloor:
	tst.w	y_vel(a0)
	bmi.s	return_1AFE6
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1AFE6
    if fixBugs
	; When Sonic is moving down and a floor collision is detected, there exists
	; a check that makes it so that he doesn't clip on top of a surface that
	; he's too far below from. However, said check doesn't exist for when Sonic
	; is moving left or right. The effects of this can easily be seen if you
	; place a solid object on a top solid surface and hit the object from the bottom,
	; where Sonic's Y movement will be cancelled out, causing him to start checking
	; for floor collision, which makes him clip onto the surface.
	move.b	y_vel(a0),d2	; get Sonic's fall speed at the time of impact (upper byte only, pixel delta)
	addq.b	#8,d2		; increase it by one tile
	neg.b	d2		; mirror it
	cmp.b	d2,d1		; is result bigger than distance to floor?
	bge.s	.landed		; if yes, branch
	cmp.b	d2,d0		; is result bigger than distance to floor? (sloped variant)
	blt.s	return_1AFE6	; if not, branch

.landed:
    endif
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	bsr.w	Sonic_ResetOnFloor
	move.w	#0,y_vel(a0)
	move.w	x_vel(a0),inertia(a0)


Sonic_HitCeilingAndWalls:
	bsr.w	CheckLeftWallDist
	tst.w	d1
	bpl.s	+
	sub.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0)	; stop Sonic since he hit a wall
+
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	+
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0)	; stop Sonic since he hit a wall
+
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	return_1B042
	sub.w	d1,y_pos(a0)
	move.b	d3,d0
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	loc_1B02C
	move.w	#0,y_vel(a0) ; stop Sonic in y since he hit a ceiling
	rts
; ===========================================================================


Sonic_HitRightWall:
	bsr.w	CheckRightWallDist
	tst.w	d1
	bpl.s	Sonic_HitCeiling2
	add.w	d1,x_pos(a0)
	move.w	#0,x_vel(a0) ; stop Sonic since he hit a wall
	move.w	y_vel(a0),inertia(a0)
	rts
; ===========================================================================
; identical to Sonic_HitCeiling...
; loc_1B05E:

Sonic_HitCeiling2:
	bsr.w	Sonic_CheckCeiling
	tst.w	d1
	bpl.s	Sonic_HitFloor2
	sub.w	d1,y_pos(a0)
	tst.w	y_vel(a0)
	bpl.s	return_1B076
	move.w	#0,y_vel(a0) ; stop Sonic in y since he hit a ceiling


Sonic_HitFloor2:
	tst.w	y_vel(a0)
	bmi.s	return_1B09E
	bsr.w	Sonic_CheckFloor
	tst.w	d1
	bpl.s	return_1B09E
    if fixBugs
	; See explanation in Sonic_HitFloor
	move.b	y_vel(a0),d2	; get Sonic's fall speed at the time of impact (upper byte only, pixel delta)
	addq.b	#8,d2		; increase it by one tile
	neg.b	d2		; mirror it
	cmp.b	d2,d1		; is result bigger than distance to floor?
	bge.s	.landed		; if yes, branch
	cmp.b	d2,d0		; is result bigger than distance to floor? (sloped variant)
	blt.s	return_1B09E	; if not, branch

.landed:
    endif
	add.w	d1,y_pos(a0)
	move.b	d3,angle(a0)
	bsr.w	Sonic_ResetOnFloor
	move.w	#0,y_vel(a0)
	move.w	x_vel(a0),inertia(a0)


Sonic_ResetOnFloor:
	tst.b	pinball_mode(a0)
	bne.s	Sonic_ResetOnFloor_Part3
	move.b	#AniIDSonAni_Walk,anim(a0)
; loc_1B0AC:

Sonic_ResetOnFloor_Part2:
	; some routines outside of Tails' code can call Sonic_ResetOnFloor_Part2
	; when they mean to call Tails_ResetOnFloor_Part2, so fix that here
	_cmpi.b	#ObjID_Sonic,id(a0)	; is this object ID Sonic (obj01)?
	bne.w	Tails_ResetOnFloor_Part2	; if not, branch to the Tails version of this code

	btst	#status.player.rolling,status(a0)
	beq.s	Sonic_ResetOnFloor_Part3
	bclr	#status.player.rolling,status(a0)
	move.b	#38/2,y_radius(a0) ; this increases Sonic's collision height to standing
	move.b	#18/2,x_radius(a0)
	move.b	#AniIDSonAni_Walk,anim(a0)	; use running/walking/standing animation
	subq.w	#5,y_pos(a0)	; move Sonic up 5 pixels so the increased height doesn't push him into the ground
; loc_1B0DA:

Sonic_ResetOnFloor_Part3:
	bclr	#status.player.in_air,status(a0)
	bclr	#status.player.pushing,status(a0)
	bclr	#status.player.rolljumping,status(a0)
	move.b	#0,jumping(a0)
	move.w	#0,(Chain_Bonus_counter).w
	move.b	#0,flip_angle(a0)
	move.b	#0,flip_turned(a0)
	move.b	#0,flips_remaining(a0)
	move.w	#0,(Sonic_Look_delay_counter).w
	cmpi.b	#AniIDSonAni_Hang2,anim(a0)
	bne.s	return_1B11E
	move.b	#AniIDSonAni_Walk,anim(a0)


Obj01_Hurt:
	tst.w	(Debug_mode_flag).w
	beq.s	Obj01_Hurt_Normal
	btst	#button_B,(Ctrl_1_Press).w
	beq.s	Obj01_Hurt_Normal
	move.w	#1,(Debug_placement_mode).w
	clr.b	(Control_Locked).w
	rts
; ---------------------------------------------------------------------------
; loc_1B13A:

Obj01_Hurt_Normal:
	tst.b	routine_secondary(a0)
	bmi.w	Sonic_HurtInstantRecover
	jsr	(ObjectMove).l
	addi.w	#$30,y_vel(a0)
	btst	#status.player.underwater,status(a0)
	beq.s	+
	subi.w	#$20,y_vel(a0)
+
	cmpi.w	#-$100,(Camera_Min_Y_pos).w
	bne.s	+
	andi.w	#$7FF,y_pos(a0)
+
	bsr.w	Sonic_HurtStop
	bsr.w	Sonic_LevelBound
	bsr.w	Sonic_RecordPos
	bsr.w	Sonic_Animate
	bsr.w	LoadSonicDynPLC
	jmp	(DisplaySprite).l
; ===========================================================================
; loc_1B184:

Sonic_HurtStop:
    if fixBugs
	; a2 needs to be set here, otherwise KillCharacter
	; will access a dangling pointer!
	movea.l	a0,a2
    endif
	move.w	(Camera_Max_Y_pos).w,d0
    if fixBugs
	; The original code does not consider that the camera boundary
	; may be in the middle of lowering itself, which is why going
	; down the S-tunnel in Green Hill Zone Act 1 fast enough can
	; kill Sonic.
	move.w	(Camera_Max_Y_pos_target).w,d1
	cmp.w	d0,d1
	blo.s	.skip
	move.w	d1,d0
.skip:
    endif
	addi.w	#screen_height,d0
	cmp.w	y_pos(a0),d0
	blt.w	JmpTo_KillCharacter
	bsr.w	Sonic_DoLevelCollision
	btst	#status.player.in_air,status(a0)
	bne.s	return_1B1C8
	moveq	#0,d0
	move.w	d0,y_vel(a0)
	move.w	d0,x_vel(a0)
	move.w	d0,inertia(a0)
	move.b	d0,obj_control(a0)
	move.b	#AniIDSonAni_Walk,anim(a0)
	subq.b	#2,routine(a0)	; => Obj01_Control
	move.w	#$78,invulnerable_time(a0)
	move.b	#0,spindash_flag(a0)


Sonic_HurtInstantRecover:
	subq.b	#2,routine(a0)	; => Obj01_Control
	move.b	#0,routine_secondary(a0)
	bsr.w	Sonic_RecordPos
	bsr.w	Sonic_Animate
	bsr.w	LoadSonicDynPLC
	jmp	(DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Sonic when he dies
; ...poor Sonic
; ---------------------------------------------------------------------------

; loc_1B1E6: Obj_01_Sub_6:

Obj01_Dead:
	tst.w	(Debug_mode_flag).w
	beq.s	+
	btst	#button_B,(Ctrl_1_Press).w
	beq.s	+
	move.w	#1,(Debug_placement_mode).w
	clr.b	(Control_Locked).w
	rts
+
	bsr.w	CheckGameOver
	jsr	(ObjectMoveAndFall).l
	bsr.w	Sonic_RecordPos
	bsr.w	Sonic_Animate
	bsr.w	LoadSonicDynPLC
	jmp	(DisplaySprite).l

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1B21C:

Obj01_Finished:
	clr.b	(Update_HUD_timer).w
	clr.b	(Update_HUD_timer_2P).w
	move.b	#8,routine(a0)	; => Obj01_Gone
	move.w	#MusID_GameOver,d0
	jsr	(PlayMusic).l
	moveq	#PLCID_GameOver,d0
	jmp	(LoadPLC).l
; End of function CheckGameOver

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when the level is restarted
; ---------------------------------------------------------------------------
; loc_1B28E:

Obj01_ResetLevel:
	tst.b	(Time_Over_flag).w
	beq.s	Obj01_ResetLevel_Part2
	move.w	#0,restart_countdown(a0)
	move.b	#ObjID_TimeOver,(TimeOver_TimeText+id).w ; load Obj39
	move.b	#ObjID_TimeOver,(TimeOver_OverText+id).w ; load Obj39
	move.b	#2,(TimeOver_TimeText+mapping_frame).w
	move.b	#3,(TimeOver_OverText+mapping_frame).w
	move.w	a0,(TimeOver_TimeText+parent).w
	bra.s	Obj01_Finished
; ---------------------------------------------------------------------------

Obj01_ResetLevel_Part2:
	tst.w	(Two_player_mode).w
	beq.s	return_1B31A
	move.b	#0,(Scroll_lock).w
	move.b	#$A,routine(a0)	; => Obj01_Respawning
	move.w	(Saved_x_pos).w,x_pos(a0)
	move.w	(Saved_y_pos).w,y_pos(a0)
	move.w	(Saved_art_tile).w,art_tile(a0)
	move.w	(Saved_Solid_bits).w,top_solid_bit(a0)
	clr.w	(Ring_count).w
	clr.b	(Extra_life_flags).w
	move.b	#0,obj_control(a0)
	move.b	#5,anim(a0)
	move.w	#0,x_vel(a0)
	move.w	#0,y_vel(a0)
	move.w	#0,inertia(a0)
	move.b	#1<<status.player.in_air,status(a0)
	move.w	#0,move_lock(a0)
	move.w	#0,restart_countdown(a0)


Obj01_Gone:
	tst.w	restart_countdown(a0)
	beq.s	+
	subq.w	#1,restart_countdown(a0)
	bne.s	+
	move.w	#1,(Level_Inactive_flag).w
+
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when he's waiting for the camera to scroll back to where he respawned
; ---------------------------------------------------------------------------
; loc_1B330: Obj_01_Sub_A:

Obj01_Respawning:
	tst.w	(Camera_X_pos_diff).w
	bne.s	+
	tst.w	(Camera_Y_pos_diff).w
	bne.s	+
	move.b	#2,routine(a0)	; => Obj01_Control
+
	bsr.w	Sonic_Animate
	bsr.w	LoadSonicDynPLC
	jmp	(DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to animate Sonic's sprites
; See also: AnimateSprite
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1B350:

Sonic_Animate:
	lea	(SonicAniData).l,a1
	tst.b	(Super_Sonic_flag).w
	beq.s	+
	lea	(SuperSonicAniData).l,a1
+
	moveq	#0,d0
	move.b	anim(a0),d0
	cmp.b	prev_anim(a0),d0	; has animation changed?
	beq.s	SAnim_Do		; if not, branch
	move.b	d0,prev_anim(a0)	; set previous animation
	move.b	#0,anim_frame(a0)	; reset animation frame
	move.b	#0,anim_frame_duration(a0)	; reset frame duration
	bclr	#status.player.pushing,status(a0)
; loc_1B384:

SonicAniData:			offsetTable

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


LoadSonicDynPLC:

	moveq	#0,d0
	move.b	mapping_frame(a0),d0	; load frame number
; loc_1B84E:

LoadSonicDynPLC_Part2:
	cmp.b	(Sonic_LastLoadedDPLC).w,d0
	beq.s	return_1B89A
	move.b	d0,(Sonic_LastLoadedDPLC).w
	lea	(MapRUnc_Sonic).l,a2
	add.w	d0,d0
	adda.w	(a2,d0.w),a2
	move.w	(a2)+,d5
	subq.w	#1,d5
	bmi.s	return_1B89A
	move.w	#tiles_to_bytes(ArtTile_ArtUnc_Sonic),d4
; loc_1B86E:

TailsCPU_Normal_SonicOK:
	bsr.w	TailsCPU_CheckDespawn
	tst.w	(Tails_control_counter).w	; if CPU has control
	bne.w	TailsCPU_Normal_HumanControl		; (if not, branch)
	tst.b	obj_control(a0)			; and Tails isn't fully object controlled (&$80)
	bmi.w	TailsCPU_Normal_HumanControl		; (if not, branch)
	tst.w	move_lock(a0)			; and Tails' movement is locked (usually because he just fell down a slope)
	beq.s	+					; (if not, branch)
	tst.w	inertia(a0)			; and Tails is stopped, then...
	bne.s	+					; (if not, branch)
	move.w	#8,(Tails_CPU_routine).w	; => TailsCPU_Panic
+
	lea	(Sonic_Pos_Record_Buf).w,a1
	move.w	#$10,d1
	lsl.b	#2,d1
	addq.b	#4,d1
	move.w	(Sonic_Pos_Record_Index).w,d0
	sub.b	d1,d0
	move.w	(a1,d0.w),d2	; d2 = earlier x position of Sonic
	move.w	2(a1,d0.w),d3	; d3 = earlier y position of Sonic
	lea	(Sonic_Stat_Record_Buf).w,a1
	move.w	(a1,d0.w),d1	; d1 = earlier input of Sonic
	move.b	2(a1,d0.w),d4	; d4 = earlier status of Sonic
	move.w	d1,d0
	btst	#status.player.pushing,status(a0)	; is Tails pushing against something?
	beq.s	+					; if not, branch
	btst	#status.player.pushing,d4		; was Sonic pushing against something?
	beq.w	TailsCPU_Normal_FilterAction_Part2	; if not, branch elsewhere

; either Tails isn't pushing, or Tails and Sonic are both pushing
+	sub.w	x_pos(a0),d2
	beq.s	TailsCPU_Normal_Stand ; branch if Tails is already lined up horizontally with Sonic
	bpl.s	TailsCPU_Normal_FollowRight
	neg.w	d2

; Tails wants to go left because that's where Sonic is
; loc_1BD76: TailsCPU_Normal_FollowLeft:
	cmpi.w	#$10,d2
	blo.s	+
	andi.w	#~(((button_left_mask|button_right_mask)<<8)|(button_left_mask|button_right_mask)),d1	; AND out Sonic's left/right input...
	ori.w	#(button_left_mask<<8)|button_left_mask,d1	; ...and give Tails his own
+
	tst.w	inertia(a0)
	beq.s	TailsCPU_Normal_FilterAction
	btst	#status.player.x_flip,status(a0)
	beq.s	TailsCPU_Normal_FilterAction
	subq.w	#1,x_pos(a0)
	bra.s	TailsCPU_Normal_FilterAction
; ===========================================================================
; Tails wants to go right because that's where Sonic is
; loc_1BD98:

Sonic_Angle:
	move.b	(Secondary_Angle).w,d2	; use left side angle
	cmp.w	d0,d1
	ble.s	+ 	; branch if floor is nearer on left side
	move.b	(Primary_Angle).w,d2	; use right side angle
	move.w	d0,d1	; use distance of right side
+
	btst	#0,d2
	bne.s	loc_1E380	; branch if bit 0 of angle is set
	move.b	d2,d0
	sub.b	angle(a0),d0
	bpl.s	+
	neg.b	d0
+
	cmpi.b	#$20,d0
	bhs.s	loc_1E380
	move.b	d2,angle(a0)	; update angle
	rts
; ===========================================================================


Sonic_WalkVertR:
	move.w	y_pos(a0),d2
	move.w	x_pos(a0),d3
	moveq	#0,d0
	move.b	x_radius(a0),d0
	ext.w	d0
	neg.w	d0
	add.w	d0,d2	; d2 = y pos of upper edge of Sonic (i.e. his front or back)
	move.b	y_radius(a0),d0
	ext.w	d0
	add.w	d0,d3	; d3 = x pos of bottom edge of Sonic (i.e. his feet)
	lea	(Primary_Angle).w,a4	; write angle here
	movea.w	#$10,a3	; tile width
	move.w	#0,d6
	bsr.w	FindWall
	move.w	d1,-(sp)	; save d1 (distance to wall) to stack
	move.w	y_pos(a0),d2
	move.w	x_pos(a0),d3
	moveq	#0,d0
	move.b	x_radius(a0),d0
	ext.w	d0
	add.w	d0,d2	; d2 = y pos of lower edge of Sonic (i.e. his front or back)
	move.b	y_radius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	(Secondary_Angle).w,a4 ; write angle here
	movea.w	#$10,a3	; tile width
	move.w	#0,d6
	bsr.w	FindWall	; d1 = distance to wall lower side
	move.w	(sp)+,d0	; d0 = distance to wall upper side
	bsr.w	Sonic_Angle	; update angle
	tst.w	d1
	beq.s	return_1E400	; branch if Sonic is 0px from wall
	bpl.s	loc_1E402	; branch if Sonic is outside wall
	cmpi.w	#-$E,d1
	blt.s	return_1E400	; branch if Sonic is > 14px inside wall
	add.w	d1,x_pos(a0)	; align to wall


Sonic_WalkCeiling:
	move.w	y_pos(a0),d2
	move.w	x_pos(a0),d3
	moveq	#0,d0
	move.b	y_radius(a0),d0
	ext.w	d0
	sub.w	d0,d2	; d2 = y pos of top edge of Sonic (i.e. his feet)
	eori.w	#$F,d2	; add some amount
	move.b	x_radius(a0),d0
	ext.w	d0
	add.w	d0,d3	; d3 = x pos of right edge of Sonic
	lea	(Primary_Angle).w,a4	; write angle here
	movea.w	#-$10,a3	; tile height
	move.w	#$800,d6	; yflip tile
	bsr.w	FindFloor
	move.w	d1,-(sp)	; save d1 (distance to ceiling) to stack
	move.w	y_pos(a0),d2
	move.w	x_pos(a0),d3
	moveq	#0,d0
	move.b	y_radius(a0),d0
	ext.w	d0
	sub.w	d0,d2	; d2 = y pos of top edge of Sonic (i.e. his feet)
	eori.w	#$F,d2
	move.b	x_radius(a0),d0
	ext.w	d0
	sub.w	d0,d3	; d3 = x pos of left edge of Sonic
	lea	(Secondary_Angle).w,a4	; write angle here
	movea.w	#-$10,a3	; tile height
	move.w	#$800,d6	; yflip tile
	bsr.w	FindFloor	; d1 = distance to ceiling left side
	move.w	(sp)+,d0	; d0 = distance to ceiling right side
	bsr.w	Sonic_Angle	; update angle
	tst.w	d1
	beq.s	return_1E4AE	; branch if Sonic is 0px from ceiling
	bpl.s	loc_1E4B0	; branch if Sonic is below ceiling
	cmpi.w	#-$E,d1
	blt.s	return_1E4AE	; branch if Sonic is > 14px inside ceiling
	sub.w	d1,y_pos(a0)	; align to ceiling


Sonic_WalkVertL:
	move.w	y_pos(a0),d2
	move.w	x_pos(a0),d3
	moveq	#0,d0
	move.b	x_radius(a0),d0
	ext.w	d0
	sub.w	d0,d2	; d2 = y pos of upper edge of Sonic (i.e. his front or back)
	move.b	y_radius(a0),d0
	ext.w	d0
	sub.w	d0,d3	; d3 = x pos of bottom edge of Sonic (i.e. his feet)
	eori.w	#$F,d3	; add some amount
	lea	(Primary_Angle).w,a4	; write angle here
	movea.w	#-$10,a3	; tile width
	move.w	#$400,d6	; xflip tile
	bsr.w	FindWall
	move.w	d1,-(sp)	; save d1 (distance to wall) to stack
	move.w	y_pos(a0),d2
	move.w	x_pos(a0),d3
	moveq	#0,d0
	move.b	x_radius(a0),d0
	ext.w	d0
	add.w	d0,d2	; d2 = y pos of lower edge of Sonic (i.e. his front or back)
	move.b	y_radius(a0),d0
	ext.w	d0
	sub.w	d0,d3	; d3 = x pos of bottom edge of Sonic (i.e. his feet)
	eori.w	#$F,d3
	lea	(Secondary_Angle).w,a4	; write angle here
	movea.w	#-$10,a3	; tile width
	move.w	#$400,d6	; xflip tile
	bsr.w	FindWall	; d1 = distance to wall lower side
	move.w	(sp)+,d0	; d0 = distance to wall upper side
	bsr.w	Sonic_Angle	; update angle
	tst.w	d1
	beq.s	return_1E55C	; branch if Sonic is 0px from wall
	bpl.s	loc_1E55E	; branch if Sonic is outside wall
	cmpi.w	#-$E,d1
	blt.s	return_1E55C	; branch if Sonic is > 14px inside wall
	sub.w	d1,x_pos(a0)	; align to wall


Sonic_CheckFloor:
	move.l	#Primary_Collision,(Collision_addr).w
	cmpi.b	#$C,top_solid_bit(a0)
	beq.s	+
	move.l	#Secondary_Collision,(Collision_addr).w
+
	move.b	top_solid_bit(a0),d5
	move.w	y_pos(a0),d2
	move.w	x_pos(a0),d3
	moveq	#0,d0
	move.b	y_radius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	x_radius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	(Primary_Angle).w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	bsr.w	FindFloor
	move.w	d1,-(sp)
	move.w	y_pos(a0),d2
	move.w	x_pos(a0),d3
	moveq	#0,d0
	move.b	y_radius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	x_radius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	lea	(Secondary_Angle).w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	bsr.w	FindFloor
	move.w	(sp)+,d0
	move.b	#0,d2


Sonic_CheckCeiling:
	move.w	y_pos(a0),d2
	move.w	x_pos(a0),d3
	moveq	#0,d0
	move.b	y_radius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2 ; flip position upside-down within the current 16x16 block?
	move.b	x_radius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	(Primary_Angle).w,a4
	movea.w	#-$10,a3
	move.w	#$800,d6
	bsr.w	FindFloor
	move.w	d1,-(sp)

	move.w	y_pos(a0),d2
	move.w	x_pos(a0),d3
	moveq	#0,d0
	move.b	y_radius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	move.b	x_radius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	lea	(Secondary_Angle).w,a4
	movea.w	#-$10,a3
	move.w	#$800,d6
	bsr.w	FindFloor
	move.w	(sp)+,d0

	move.b	#$80,d2
	bra.w	loc_1ECC6
; End of function Sonic_CheckCeiling

; ===========================================================================
	; a bit of unused/dead code here
;CheckCeilingDist:
	move.w	y_pos(a0),d2 ; a0=character
	move.w	x_pos(a0),d3

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Checks a 16x16 block to find solid ceiling. May check an additional
; 16x16 block up for ceilings.
; d2 = y_pos
; d3 = x_pos
; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
; returns relevant block ID in (a1)
; returns distance in d1
; returns angle in d3, or zero if angle was odd
; loc_1EF9E: CheckSlopeDist:

LoadSSSonicDynPLC:
	move.b	ss_dplc_timer(a0),d0
	beq.s	+
	subq.b	#1,d0
	move.b	d0,ss_dplc_timer(a0)
	andi.b	#1,d0
	beq.s	+
	rts
; ===========================================================================
+
	jsrto	JmpTo42_DisplaySprite
	lea	dword_33AA2(pc),a3
	lea	(Sonic_LastLoadedDPLC).w,a4
	move.w	#tiles_to_bytes(ArtTile_ArtNem_SpecialSonic),d4
	moveq	#0,d1


SSSonic_Jump:
	lea	(Ctrl_1_Press_Logical).w,a2


SonicRunningSpriteScaleData:
copysrc := Chunk_Table
copydst := Chunk_Table + $B00
SegaScreenScaledSpriteDataStart = copydst
	rept 4 ; repeat 4 times since there are 4 frames to scale up
	; piece 1 of each frame (the smaller top piece):
	map_piece 3,2
	; piece 2 of each frame (the larger bottom piece):
	map_piece 4,4
	endm
SegaScreenScaledSpriteDataEnd = copydst
	if copysrc > SegaScreenScaledSpriteDataStart
	fatal "Scale copy source overran allocated size. Try changing the initial value of copydst to Chunk_Table+$\{copysrc-Chunk_Table}"
	endif
; ===========================================================================


Sonic_pilot_frames:
	dc.b $2D
	dc.b $2E	; 1
	dc.b $2F	; 2
	dc.b $30	; 3

Sonic_pilot_frames_end:

; byte_3AFA0:

ArtUnc_Sonic:			BINCLUDE	"art/uncompressed/Sonic's art.bin"
	align tiles_to_bytes(1)

MapUnc_Sonic:			include		"mappings/sprite/Sonic.asm"


MapRUnc_Sonic:			include		"mappings/spriteDPLC/Sonic.asm"


ArtNem_SuperSonic_stars:	BINCLUDE	"art/nemesis/Super Sonic stars.nem"
	even

ArtNem_Sonic_life_counter:	BINCLUDE	"art/nemesis/Sonic lives counter.nem"
	even

ArtNem_MiniSonic:		BINCLUDE	"art/nemesis/Sonic continue.nem"
	even

ArtNem_SilverSonic:		BINCLUDE	"art/nemesis/Silver Sonic.nem"
	even

MapEng_EndingSonicPlane:	BINCLUDE	"mappings/misc/Closeup of Sonic flying plane in ending sequence.eni"
	even

; Strange unused mappings (duplicates of MapEng_EndGameLogo)
    rept 9
				BINCLUDE	"mappings/misc/Sonic 2 end of game logo.eni"
	even
    endm


ArtNem_EndingSonic:		BINCLUDE	"art/nemesis/Small pictures of Sonic and final image of Sonic.nem"
	even

ArtNem_EndingSuperSonic:	BINCLUDE	"art/nemesis/Small pictures of Sonic and final image of Sonic in Super Sonic mode.nem"
	even

ArtNem_SpecialSonicAndTails:	BINCLUDE	"art/nemesis/Sonic and Tails animation frames in special stage.nem" ; [fixBugs] In this file, Tails' arms are tan instead of orange.
	even

Mus_SuperSonic:	include	"sound/music/generated/96 - Super Sonic.inc"

SndPtr_MechaSonicBuzz:	rom_ptr_z80	Sound6E	; Silver Sonic buzz saw

