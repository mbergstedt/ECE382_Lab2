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
encrypted:	.byte	0xef,0xc3,0xc2,0xcb,0xde,0xcd,0xd8,0xd9,0xc0,0xcd,0xd8,0xc5,0xc3,0xc2,0xdf
			.byte	0x8d,0x8c,0x8c,0xf5,0xc3,0xd9,0x8c,0xc8,0xc9,0xcf,0xde,0xd5,0xdc,0xd8,0xc9
			.byte	0xc8,0x8c,0xd8,0xc4,0xc9,0x8c,0xe9,0xef,0xe9,0x9f,0x94,0x9e,0x8c,0xc4,0xc5
			.byte	0xc8,0xc8,0xc9,0xc2,0x8c,0xc1,0xc9,0xdf,0xdf,0xcd,0xcb,0xc9,0x8c,0xcd,0xc2
			.byte	0xc8,0x8c,0xcd,0xcf,0xc4,0xc5,0xc9,0xda,0xc9,0xc8,0x8c,0xde,0xc9,0xdd,0xd9
			.byte	0xc5,0xde,0xc9,0xc8,0x8c,0xca,0xd9,0xc2,0xcf,0xd8,0xc5,0xc3,0xc2,0xcd,0xc0
			.byte	0xc5,0xd8,0xd5,0x8f
end:		.byte	0x00,0x00
key:		.byte	0xac
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

			push.w	r6
lengthFinder:								; use a loop to find the length of the message
			inc		r10
			inc		r6
			cmp		r6,			r9
			jhs		lengthFinder
			pop		r6

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
			mov.b	0(r7),		r5
characterFinder:
			mov.b	0(r6),		r4
			call	#decryptCharacter
			mov.b	r4,			0(r8)
			inc		r6
			inc		r8

			dec		r10
			tst		r10
			jnz		characterFinder

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
