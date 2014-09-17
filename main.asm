;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
encrypted:	.byte	0xf8,0xb7,0x46,0x8c,0xb2,0x46,0xdf,0xac,0x42,0xcb,0xba,0x03,0xc7
			.byte	0xba,0x5a,0x8c,0xb3,0x46,0xc2,0xb8,0x57,0xc4,0xff,0x4a,0xdf,0xff
			.byte	0x12,0x9a,0xff,0x41,0xc5,0xab,0x50,0x82,0xff,0x03,0xe5,0xab,0x03
			.byte	0xc3,0xb1,0x4f,0xd5,0xff,0x40,0xc3,0xb1,0x57,0xcd,0xb6,0x4d,0xdf
			.byte	0xff,0x4f,0xc9,0xab,0x57,0xc9,0xad,0x50,0x80,0xff,0x53,0xc9,0xad
			.byte	0x4a,0xc3,0xbb,0x50,0x80,0xff,0x42,0xc2,0xbb,0x03,0xdf,0xaf,0x42
			.byte	0xcf,0xba,0x50,0x8f
end:		.byte	0x00,0x00
key:		.byte	0xac,0xdf,0x23
keyEnd:		.byte	0x00
			.data
decrypted:	.space	100
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
			mov.w	#encrypted,	r6
			mov.w	#key,		r7
			mov.w	#decrypted,	r8
			mov.w	#end,		r9
			mov.w	#0,			r10			; use r10 to hold the length
			mov.w	#0,			r11			; use r11 to hold the key length
			mov.w	#keyEnd,	r12

			push.w	r6
lengthFinder:								; use a loop to find the length of the message
			inc		r10
			inc		r6
			cmp		r6,			r9
			jne		lengthFinder
			pop		r6

			push.w	r7
keyLength:
			inc		r11
			inc		r7
			cmp		r7,			r12
			jne		keyLength
			pop		r7

			call	#decryptMessage

programEnd:
			jmp		programEnd

;-------------------------------------------------------------------------------
;								Subroutines
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;Subroutine Name: decryptMessage
;Author: Matt Bergstedt
;Function: Decrypts a string of bytes and stores the result in memory.  Accepts
;           the address of the encrypted message, address of the key, and address
;           of the decrypted message (pass-by-reference).  Accepts the length of
;           the message by value.  Uses the decryptCharacter subroutine to decrypt
;           each byte of the message.  Stores the results to the decrypted message
;           location.
;Inputs:
;Outputs:
;Registers destroyed:
;-------------------------------------------------------------------------------

decryptMessage:
			push.w	r10
			push.w	r8
			push.w	r6
characterFinder:
			push.w	r11
			push.w	r7
multiByteDecrypt:
			mov.b	0(r6),		r4
			mov.b	0(r7),		r5
			call	#decryptCharacter
			mov.b	r4,			0(r8)
			inc		r6
			inc		r8
			inc		r7

			dec		r10
			dec		r11
			tst		r10							; without it returns to 0x0000 and continuously runs
			jz		popOut
			tst		r11
			jnz		multiByteDecrypt

			pop		r7
			pop		r11
			tst		r10
			jnz		characterFinder
popOut:
			pop		r7							; add these to account for not running them the last time
			pop		r11
			pop		r6
			pop		r8
			pop		r10

            ret

;-------------------------------------------------------------------------------
;Subroutine Name: decryptCharacter
;Author: Matt Bergstedt
;Function: Decrypts a byte of data by XORing it with a key byte.  Returns the
;           decrypted byte in the same register the encrypted byte was passed in.
;           Expects both the encrypted data and key to be passed by value.
;Inputs:
;Outputs:
;Registers destroyed:
;-------------------------------------------------------------------------------

decryptCharacter:
			xor		r5,			r4
            ret

;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
