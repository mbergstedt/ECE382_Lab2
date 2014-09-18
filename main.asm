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
encrypted:	.byte	0x35,0xdf,0x00,0xca,0x5d,0x9e,0x3d,0xdb,0x12,0xca,0x5d,0x9e,0x32
			.byte	0xc8,0x16,0xcc,0x12,0xd9,0x16,0x90,0x53,0xf8,0x01,0xd7,0x16,0xd0
			.byte	0x17,0xd2,0x0a,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90,0x53,0xf9,0x1c
			.byte	0xd1,0x17,0x90
end:		.byte	0x00,0x00
key:		.byte	0x73,0xbe
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
