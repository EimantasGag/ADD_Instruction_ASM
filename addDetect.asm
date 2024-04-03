LOCALS @@

.MODEL small
.STACK 100h

.DATA
	senasIP dw ?
	senasCS dw ?
	
	regAX dw ?
	regBX dw ?
	regCX dw ?
	regDX dw ?
	regSP dw ?
	regBP dw ?
	regSI dw ?
	regDI dw ?
	
	baitas1 db ?
	baitas2 db ?
	baitas3 db ?
	baitas4 db ?
	baitas5 db ?
	baitas6 db ?
	
	zingsn_pranesimas db "Zingsninio rezimo pertraukimas! $"

	addKomanda db "add $"
	alKomanda db "al$"
	clKomanda db "cl$"
	dlKomanda db "dl$"
	blKomanda db "bl$"
	ahKomanda db "ah$"
	chKomanda db "ch$"
	dhKomanda db "dh$"
	bhKomanda db "bh$"
	axKomanda db "ax$"
	cxKomanda db "cx$"
	dxKomanda db "dx$"
	bxKomanda db "bx$"
	spKomanda db "sp$"
	bpKomanda db "bp$"
	siKomanda db "si$"
	diKomanda db "di$"
	testas db "testas$"

	op1ad dw 0
	op2ad dw 0
	op3ad dw 0
	op1 dw ?
	op2 dw ?
	op3 dw ?

	aprasymas DB "Autorius: Eimantas Gagilas. Programa aptinkanti ADD reg + r\m komanda", 10, 13, '$' 
.CODE
Start:	
	mov ax, @data
	mov ds, ax

	mov dx, offset aprasymas
	call Printinti
	
	mov ax, 0
	mov es, ax 
	
	;; mov ax, es:[4]		
	;; mov bx, es:[6]
	;; mov senasCS, bx
	;; mov senasIP, ax 

	mov ax, cs
	mov bx, offset AtpazintiAdd
	
	mov es:[4], bx
	mov es:[6], ax

	;; aktuvuoja zingsnio rezima
	pushf 
	pop ax
	or ax, 100h ;0000 0001 0000 0000 (TF=1, kiti lieka kokie buvo)
	push ax
	popf  

	;; belekokios testavimo komandos
	nop
	mov ax, 8414h
	mov bx, 89h
	add ax, bx
	add al, [bx+si+1243h]
	add [si+12h], bp
	mov bx, 7897h
	inc bx
	mov bx, 9854h

	;; isjungiame zingsnini rezima
	pushf
	pop  ax
	and  ax, 0FEFFh ;1111 1110 1111 1111
	push ax
	popf 

	;; mov bx, senasCS		
	;; mov es:[4], ax		
	;; mov es:[6], bx	

Exit:
	mov ah, 4Ch
	int 21h

PROC AtpazintiAdd

@@InformacijosIssaugojimas:
	mov [op1ad], 0
	mov [op2ad], 0
	mov [op3ad], 0

	mov regAX, ax				
	mov regBX, bx
	mov regCX, cx
	mov regDX, dx
	mov regSP, sp
	mov regBP, bp
	mov regSI, si
	mov regDI, di

	;; gauname komandos adresus (di:si)
	pop si 
	pop di 
	push di 
	push si 

	mov ax, cs:[si]
	mov bx, cs:[si+2]
	mov cx, cs:[si+4]
	
	mov baitas1, al
	mov baitas2, ah
	mov baitas3, bl
	mov baitas4, bh
	mov baitas5, cl
	mov baitas6, ch

	jmp @@Atpazinimas

@@Atpazinimas:	
	;; tikriname pagal pirmus 6 bitus ar jie visi 0000 00xx
	and al, 0FCh
	cmp al, 0
	je @@AddKomanda

	jmp @@Exit

@@AddKomanda:
	;; zingsninio pranesimo atspausdinimas
	mov dx, offset zingsn_pranesimas
	call Printinti

	;; cs:ip adreso atspausdinimas
	mov ax, di
	call PrintHex

	mov ah, 2
	mov dl, ':'
	int 21h

	mov ax, si
	call PrintHex

	call PrintintiTarpa

	;; registro atpazinimas

	mov ah, [baitas1]
	;; 0000 00x0 - bitas irasomas; d
	and ah, 2h 		
	shr ah, 1

	mov al, [baitas1]
	;; 0000 000x - bitas irasomas; w
	and al, 1h

	mov bh, [baitas2]
	;; xx00 0000 - bitai irasomi; mod
	and bh, 0C0h
	shr bh, 6

	mov bl, [baitas2]
	;; 00xx x000 - bitai irasomi; reg
	and bl, 038h
	shr bl, 3

	mov ch, [baitas2]
	;; 0000 0xxx - bitai irasomi; r/m
	and ch, 7h

	;; POSLINKIS DX REGISTRE
	mov dh, [baitas4]
	mov dl, [baitas3]

	;; bytu printinimas
	push ax
	push bx
	push cx
	push dx

	mov ah, [baitas1]
	mov al, [baitas2]

	call PrintHex

	cmp bh, 1
	je @@Poslinkis1

	cmp bh, 2
	je @@Poslinkis2

	jmp @@BaigePoslinki

@@Poslinkis1:
	mov al, [baitas3]

	call PrintintiHexByte

	jmp @@BaigePoslinki

@@Poslinkis2:
	mov ah, [baitas3]
	mov al, [baitas4]

	call PrintHex

	jmp @@BaigePoslinki

@@BaigePoslinki:
	call PrintintiTarpa

	;; add komandos printinimas
	mov dx, offset addKomanda
	call Printinti

	pop dx
	pop cx
	pop bx
	pop ax

	mov [op1ad], 0
	mov [op2ad], 0
	mov [op3ad], 0

	;; jeigu d - 0, tai pirma r/m rezultatas
	cmp ah, 0
	je @@PrintintiRM

	jmp @@PrintintiRegistra

@@PrintintiRM:
	call PrintintiRM

	push ax
	push dx

	mov ah, 2
	mov dl, ','
	int 21h

	push dx
	pop ax

	call PrintintiRegistra

	jmp @@Testi

@@PrintintiRegistra:
	call PrintintiRegistra
	
	push ax
	push bx
	push dx

	mov ah, 2
	mov dl, ','
	int 21h

	pop dx
	pop bx
	pop ax

	call PrintintiRM

	jmp @@Testi

@@Testi:
	call PrintintiOperandus

	;; pabaigos zenklai
	mov ah, 2
	mov dl, 10
	int 21h

	mov ah, 2
	mov dl, 13
	int 21h

	jmp @@Exit
@@Exit:
	mov ax, regAX
	mov bx, regBX
	mov cx, regCX
	mov dx, regDX
	mov sp, regSP
	mov bp, regBP
	mov si, regSI
	mov di, regDI

	iret
ENDP

;;; AL REGISTRE - w
;;; BH REGISTRE - mod
;;; CH REGISTRE - r/m
PROC PrintintiRM
	push ax
	push bx
	push cx
	push dx

	cmp bh, 3
	je @@Registras

	call PrintintiGrot

	cmp bh, 0
	je @@Mod00

	cmp bh, 1
	je @@Mod00

	cmp bh, 2
	je @@Mod00

	jmp @@Exit

@@Registras:
	push ax
	push bx
	push cx
	push dx

	mov al, al
	mov bl, ch

	mov cx, [op1ad]
	mov dx, [op1]

	call PrintintiRegistra

	mov ax, [op1]
	mov [op2], ax

	mov ax, [op1ad]
	mov [op2ad], ax

	mov [op1ad], cx
	mov [op1], dx

	pop dx
	pop cx
	pop bx
	pop ax

	jmp @@FinalExit

@@Mod00:
	call PrintintiMOD
	jmp @@Exit

@@Exit:
	cmp bh, 0
	je @@FinalExit1

	cmp bh, 3
	je @@FinalExit1

	;; sicia poslinkis pridedamas
	call PrintintiPlus

	cmp bh, 1
	je @@Poslinkis1

	jmp @@Poslinkis2

@@Poslinkis1:
	mov al, [baitas3]
	shr al, 4
	call PrintHexChar

	mov al, [baitas3]
	call PrintHexChar

	jmp @@BaigtiPoslinki

@@Poslinkis2:
	mov ah, [baitas4]
	mov al, [baitas3]

	call PrintHex

	jmp @@BaigtiPoslinki

@@BaigtiPoslinki:
	call PrintintiUzdGrot
	
	jmp @@FinalExit

@@FinalExit1:
	call PrintintiUzdGrot
	jmp @@FinalExit

@@FinalExit:

	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

;;; AL REGISTRE - w
;;; BL REGISTRE - reg
;;; BH REGISTRE - mod
;;; CH REGISTRE - r/m
PROC PrintintiOperandus
	push ax
	push bx
	push cx
	push dx
	
	cmp [op1ad], 0
	jne @@Op1

@@Op1:
	call PrintintiTarpa

	mov dx, [op1ad]
	call Printinti
	call PrintintiLygybe

	cmp al, 0
	je @@Op1Byte

	jmp @@Op1Word

@@Op1Byte:
	cmp bl, 4
	jb @@Op1Byte1

	jmp @@Op1Byte2

@@Op1Byte1:
	push ax

	mov ax, [op1]
	call PrintintiHexByte

	pop ax
	jmp @@Op2

@@Op1Byte2:
	push ax

	mov ax, [op1]
	mov al, ah
	call PrintintiHexByte

	pop ax
	jmp @@Op2

@@Op1Word:
	push ax

	mov ax, [op1]
	call PrintHex

	pop ax
	
	jmp @@Op2
@@Op2:
	call PrintintiTarpa

	cmp [op2ad], 0
	je @@Op3

	mov dx, [op2ad]
	call Printinti
	call PrintintiLygybe

	cmp bh, 3
	je @@Op2Mod11

	jmp @@Op2Word

@@Op2Mod11:
	cmp al, 0
	je @@Op2Byte

	jmp @@Op2Word

@@Op2Byte:
	cmp ch, 4
	jb @@Op2Byte1

	jmp @@Op2Byte2

@@Op2Byte1:
	push ax

	mov ax, [op2]
	call PrintintiHexByte

	pop ax
	jmp @@Op3

@@Op2Byte2:
	push ax

	mov ax, [op2]
	mov al, ah
	call PrintintiHexByte
	
	pop ax
	jmp @@Op3

@@Op2Word:
	push ax

	mov ax, [op2]
	call PrintHex

	pop ax
	jmp @@Op3

@@Op3:
	call PrintintiTarpa

	cmp [op3ad], 0
	je @@Exit

	mov dx, [op3ad]
	call Printinti
	call PrintintiLygybe

	push ax
	
	mov ax, [op3]
	call PrintHex

	pop ax
	jmp @@Exit

@@Exit:
	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

PROC PrintintiLygybe
	push ax
	push bx
	push cx
	push dx

	mov ah, 2
	mov dl, '='
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

;;; NAUDOJA AL REGISTRA
PROC PrintintiHexByte
	push ax
	push bx
	push cx
	push dx
	
	call PrintHexChar
	shr al, 4

	call PrintHexChar

	pop dx
	pop cx
	pop bx
	pop ax
	
	ret
ENDP

;;; NAUDOJA AL REGISTRA
PROC PrintHexChar

printHexSkaitmuo:
	push ax
	push dx
	
	and al, 0Fh 
	cmp al, 9
	jbe PrintHexSkaitmuo_0_9
	jmp PrintHexSkaitmuo_A_F
	
PrintHexSkaitmuo_A_F: 
	sub al, 10 
	add al, 41h
	mov dl, al
	mov ah, 2
	int 21h
	jmp PrintHexSkaitmuo_grizti
	
	
PrintHexSkaitmuo_0_9: 
	mov dl, al
	add dl, 30h
	mov ah, 2 
	int 21h
	jmp printHexSkaitmuo_grizti
	
printHexSkaitmuo_grizti:
	pop dx
	pop ax
	
	ret
ENDP

PROC PrintintiMOD
	push ax
	push bx
	push cx
	push dx

@@Mod00:
	cmp ch, 4
	jb @@Mod1

	jmp @@Mod2

@@Mod1:
	call PrintintiMOD1
	jmp @@Exit

@@Mod2:
	call PrintintiMOD2
	jmp @@Exit

@@Exit:
	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

PROC PrintintiMOD1
	push ax
	push bx
	push cx
	push dx

@@Mod00:
	cmp ch, 0
	je @@Mod0Rm000

	cmp ch, 1
	je @@Mod0Rm001

	cmp ch, 2
	je @@Mod0Rm010

	cmp ch, 3
	je @@Mod0Rm011

	jmp @@Exit

@@Mod0Rm000:
	mov dx, offset bxKomanda
	call Printinti

	mov [op2ad], dx
	mov ax, [regBX]
	mov [op2], ax

	call PrintintiPlus

	mov dx, offset siKomanda
	call Printinti

	mov [op3ad], dx
	mov ax, [regSI]
	mov [op3], ax

	jmp @@Exit

@@Mod0Rm001:
	mov dx, offset bxKomanda
	call Printinti

	mov [op2ad], dx
	mov ax, [regBX]
	mov [op2], ax

	call PrintintiPlus

	mov dx, offset diKomanda
	call Printinti

	mov [op3ad], dx
	mov ax, [regDI]
	mov [op3], ax

	jmp @@Exit

@@Mod0Rm010:
	mov dx, offset bpKomanda
	call Printinti

	mov [op2ad], dx
	mov ax, [regBP]
	mov [op2], ax

	call PrintintiPlus

	mov dx, offset siKomanda
	call Printinti

	mov [op3ad], dx
	mov ax, [regSI]
	mov [op3], ax

	jmp @@Exit

@@Mod0Rm011:
	mov dx, offset bpKomanda
	call Printinti

	mov [op2ad], dx
	mov ax, [regBP]
	mov [op2], ax

	call PrintintiPlus

	mov dx, offset diKomanda
	call Printinti

	mov [op3ad], dx
	mov ax, [regDI]
	mov [op3], ax

	jmp @@Exit

@@Exit:
	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

PROC PrintintiMOD2
	push ax
	push bx
	push cx
	push dx

@@Mod00:
	cmp ch, 4
	je @@Mod0Rm100

	cmp ch, 5
	je @@Mod0Rm101

	cmp ch, 6
	je @@Mod0Rm110

	cmp ch, 7
	je @@Mod0Rm111

	jmp @@Exit

@@Mod0Rm100:
	mov dx, offset siKomanda
	call Printinti
	
	mov [op2ad], dx
	mov ax, [regSI]
	mov [op2], ax

	jmp @@Exit

@@Mod0Rm101:
	mov dx, offset diKomanda
	call Printinti

	mov [op2ad], dx
	mov ax, [regDI]
	mov [op2], ax

	jmp @@Exit

@@Mod0Rm110:
	mov dx, offset diKomanda
	call Printinti

	mov [op2ad], dx
	mov ax, [regDI]
	mov [op2], ax

	jmp @@Exit

@@Mod0Rm111:
	mov dx, offset bxKomanda
	call Printinti

	mov [op2ad], dx
	mov ax, [regBX]
	mov [op2], ax

	jmp @@Exit

@@Exit:
	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

;;; BL REGISTRE - reg
;;; AL REGISTRE - w
PROC PrintintiRegistra
	push ax
	push bx
	push cx
	push dx

	cmp al, 0
	je @@ByteIlgio

	jmp @@WordIlgio

@@ByteIlgio:
	call PrintintiRegistraByte
	jmp @@Exit

@@WordIlgio:
	call PrintintiRegistraWord
	jmp @@Exit
		
@@Exit:
	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

;;; BL REGISTRE - reg
PROC PrintintiRegistraByte
	push ax
	push bx
	push cx
	push dx

	cmp bl, 0
	je @@al
	
	cmp bl, 1
	je @@cl

	cmp bl, 2
	je @@dl

	cmp bl, 3
	je @@bl

	cmp bl, 4
	je @@ah

	cmp bl, 5
	je @@ch

	cmp bl, 6
	je @@dh

	cmp bl, 7
	je @@bh

	jmp @@Exit

@@al:
	mov dx, offset alKomanda
	call Printinti

	mov ax, [regAX]
	mov [op1], ax

	jmp @@Exit
@@cl:
	mov dx, offset clKomanda
	call Printinti

	mov ax, [regCX]
	mov [op1], ax
	
	jmp @@Exit
@@dl:
	mov dx, offset dlKomanda
	call Printinti

	mov ax, [regDX]
	mov [op1], ax

	jmp @@Exit
@@bl:
	mov dx, offset blKomanda
	call Printinti

	mov ax, [regBX]
	mov [op1], ax

	jmp @@Exit
@@ah:
	mov dx, offset ahKomanda
	call Printinti

	mov ax, [regAX]
	mov [op1], ax

	jmp @@Exit
@@ch:
	mov dx, offset chKomanda
	call Printinti

	mov ax, [regCX]
	mov [op1], ax

	jmp @@Exit
@@dh:
	mov dx, offset dhKomanda
	call Printinti

	mov ax, [regDX]
	mov [op1], ax

	jmp @@Exit
@@bh:
	mov dx, offset bhKomanda
	call Printinti

	mov ax, [regBX]
	mov [op1], ax

	jmp @@Exit

@@Exit:
	mov [op1ad], dx
	
	pop dx
	pop cx
	pop bx
	pop ax

	ret	
ENDP

PROC PrintintiRegistraWord
	push ax
	push bx
	push cx
	push dx

	cmp bl, 0
	je @@ax
	
	cmp bl, 1
	je @@cx

	cmp bl, 2
	je @@dx

	cmp bl, 3
	je @@bx

	cmp bl, 4
	je @@sp

	cmp bl, 5
	je @@bp

	cmp bl, 6
	je @@si

	cmp bl, 7
	je @@di

	jmp @@Exit

@@ax:
	mov dx, offset axKomanda
	call Printinti

	mov ax, [regAX]
	mov [op1], ax

	jmp @@Exit
@@cx:
	mov dx, offset cxKomanda
	call Printinti

	mov ax, [regCX]
	mov [op1], ax

	jmp @@Exit
@@dx:
	mov dx, offset dxKomanda
	call Printinti

	mov ax, [regDX]
	mov [op1], ax

	jmp @@Exit
@@bx:
	mov dx, offset bxKomanda
	call Printinti

	mov ax, [regBX]
	mov [op1], ax

	jmp @@Exit
@@sp:
	mov dx, offset spKomanda
	call Printinti

	mov ax, [regSP]
	mov [op1], ax

	jmp @@Exit
@@bp:
	mov dx, offset bpKomanda
	call Printinti

	mov ax, [regBP]
	mov [op1], ax

	jmp @@Exit
@@si:
	mov dx, offset siKomanda
	call Printinti

	mov ax, [regSI]
	mov [op1], ax

	jmp @@Exit
@@di:
	mov dx, offset diKomanda
	call Printinti

	mov ax, [regDI]
	mov [op1], ax

	jmp @@Exit
		
@@Exit:
	mov [op1ad], dx

	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

PROC PrintintiGrot
	push ax
	push bx
	push cx
	push dx
	
	mov ah, 2
	mov dl, '['
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

PROC PrintintiUzdGrot
	push ax
	push bx
	push cx
	push dx
	
	mov ah, 2
	mov dl, ']'
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

PROC PrintintiPlus
	push ax
	push bx
	push cx
	push dx

	mov ah, 2
	mov dl, '+'
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

PROC PrintintiTarpa
	push ax
	push bx
	push cx
	push dx
	
	mov ah, 2
	mov dl, ' '
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

PROC PrintHex
	push cx
	push dx 
	push bx

	mov cx, 0        
	mov dx, 0

@@label1: 
	cmp ax, 0
	je @@check_count 

	mov bx, 16
	div bx 

	push dx            
	inc cx             

	xor dx, dx
	jmp @@label1

@@check_count:
	cmp cx, 4
	jge @@print1        

	mov dx, 0
	push dx
	inc cx
	jmp @@check_count    

@@print1:
	cmp cx, 0
	je @@exit           

	pop dx           

	cmp dx, 9
	jle @@print_digit   

	add dx, 7          

@@print_digit:
	add dx, 48         
	mov ah, 02h
	int 21h            

	dec cx             
	jmp @@print1         

@@exit:
	pop bx
	pop dx
	pop cx

	ret

ENDP

PROC Printinti
	push ax
	push bx
	push cx
	push dx

	mov ah, 9h
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax

	ret
ENDP

END Start
