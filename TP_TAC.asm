.8086
.model small
.stack 2048h

dseg    segment para public 'data'		
	gamaze1 				db		'########     ###     ####   ####     ###     ###### ######$'
	gamaze2 				db		'##          ## ##    ## ## ## ##    ## ##       ##  ##    $'
	gamaze3 				db		'##  ####   ##   ##   ##  ###  ##   ##   ##     ##   ######$'
	gamaze4 				db		'##    ##  #########  ##       ##  #########   ##    ##    $'
	gamaze5 				db		'######## ##       ## ##       ## ##       ## ###### ######$'
	
	Op_jogo 				db		'1) Jogar$'
	Op_sair 				db		'2) Sair$'
	
	Op_msg					db		'Escolha o numero da opcao que pretende!$'
	
	Op_msg_sair				db		'Tem a certeza que quer sair? (s/n)$'
		
	msg_final 				db		'Chegou ao final do labirinto! Parabens! Demorou:$'
	msg_erro_jogo 			db		'[ERRO] Deve conter _ na posicao 20, 18 para ser possivel jogar!$'

    Erro_Open       		db      'Erro ao tentar abrir o ficheiro$'
    Erro_Ler_Msg    		db      'Erro ao tentar ler do ficheiro$'
    Erro_Close      		db      'Erro ao tentar fechar o ficheiro$'
    Fich         			db      'default.txt',0
	fname					db		'ultimotempo.txt',0
    HandleFich     			dw      0
    car_fich      		    db      ?
	
	Car						db		32 
	POSy					db		?	
	POSx					db		?		
	POSya					db		?	
	POSxa					db		?	
	
	Horas_inicio			dw		?
	Minutos_inicio			dw		?
	Segundos_inicio			dw		?
	Horas_fim				dw		?
	Minutos_fim				dw		?
	Segundos_fim			dw		?
	strHoras				db		"            "
	
dseg    ends

cseg    segment para public 'code'
	assume  cs:cseg, ds:dseg
;********************************************************************************
;********************************************************************************
; HORAS  - LE Hora DO SISTEMA E COLOCA em tres variaveis (Horas, Minutos, Segundos)
; CH - Horas, CL - Minutos, DH - Segundos
;********************************************************************************	
Ler_TEMPO_Inicio PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos_inicio, AX		; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos_inicio, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas_inicio,AX			; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPO_Inicio   ENDP 

Ler_tempo_fim PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos_fim, AX		; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos_fim, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas_fim,AX			; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_tempo_fim   ENDP 

;########################################################################
goto_xy	macro	POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

mostra MACRO STR 
	MOV AH,09H
	LEA DX,STR 
	INT 21H
ENDM

;########################################################################
;ROTINA PARA APAGAR ECRAN
limpa_tela	proc
		xor		bx,bx
		mov		cx,25*80
		
apaga:			mov	byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 		bx
		loop		apaga
		ret
limpa_tela	endp


;########################################################################
; LE UMA TECLA PARA O JOGO	
LE_TECLA	PROC
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp

;########################################################################
;ROTINA PARA LER E IMPRIMIR UM FICHEIRO NO ECRAN
IMPRIME_FICHEIRO PROC
	call limpa_tela
	
	goto_xy 0, 0

    mov     ah,3dh			; vamos abrir ficheiro para leitura 
    mov     al,0			; tipo de ficheiro	
	lea     dx,Fich			; nome do ficheiro
	int     21h			    ; abre para leitura 
	jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
	mov     HandleFich,ax	; ax devolve o Handle para o ficheiro 
	jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 
	
erro_abrir:
	mostra 	Erro_Open
	jmp     sair_imprime

ler_ciclo:
	mov     ah,3fh			; indica que vai ser lido um ficheiro 
	mov     bx,HandleFich	; bx deve conter o Handle do ficheiro previamente aberto 
	mov     cx,1			; numero de bytes a ler 
	lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
	int     21h				; faz efectivamente a leitura
	jc	    erro_ler		; se carry é porque aconteceu um erro
	cmp	    ax,0			; EOF?	verifica se já estamos no fim do ficheiro 
	je	    fecha_ficheiro	; se EOF fecha o ficheiro 
	mov     ah,02h			; coloca o caracter no ecran
	mov	    dl,car_fich		; este é o caracter a enviar para o ecran
	int	    21h				; imprime no ecran
	jmp	    ler_ciclo		; continua a ler o ficheiro

erro_ler:
	mostra Erro_Ler_Msg

fecha_ficheiro:				; vamos fechar o ficheiro 
	mov     ah,3eh
	mov     bx,HandleFich
	int     21h
	jnc     sair_imprime
	call 	limpa_tela	
	mostra 	Erro_Close ; o ficheiro pode não fechar correctamente
	
sair_imprime:
	ret
IMPRIME_FICHEIRO ENDP

;########################################################################
;ROTINA PARA JOGAR
JOGO PROC
	CALL Ler_TEMPO_Inicio
POS_INICIAL:
	mov 	al, 20
	mov 	POSxa, al
	mov 	POSx, al
	
	mov 	al, 18
	mov 	POSya, al
	mov 	POSy, al
	
	goto_xy	POSx,POSy		; Vai para nova possição
	mov 	ah, 08h			; Guarda o Caracter que está na posição do Cursor
	mov		bh,0			; numero da página
	int		10h			
	mov		Car, al			; Guarda o Caracter que está na posição do Cursor

CICLO:	
	goto_xy	POSxa,POSya		; Vai para a posição anterior do cursor
	mov		ah, 02h
	mov		dl, Car			; Repoe Caracter guardado 
	int		21H		
		
	goto_xy	POSx,POSy		; Vai para nova possição
	mov 	ah, 08h
	mov		bh,0			; numero da página
	int		10h		
	mov		Car, al			; Guarda o Caracter que está na posição do Cursor
	
	cmp Car, '#'
	JE POS_INICIAL
	cmp Car, '-'
	JE GANHOU
	
IMPRIME:	
	mov		ah, 02h
	mov		dl, 190			; Coloca AVATAR
	int		21H	
	goto_xy	POSx,POSy		; Vai para posição do cursor
			
	mov		al, POSx		; Guarda a posição do cursor
	mov		POSxa, al
	mov		al, POSy		; Guarda a posição do cursor
	mov 	POSya, al
		
LER_SETA:	
	call 	LE_TECLA
	cmp		ah, 1
	je		ESTEND
	CMP 	AL, 27			; ESCAPE
	JE		SAI_JOGO
	jmp		LER_SETA
		
ESTEND:	
	cmp 	al,48h
	jne		BAIXO
	dec		POSy			;cima
	jmp		CICLO

BAIXO:	
	cmp		al,50h
	jne		ESQUERDA
	inc 	POSy			;Baixo
	jmp		CICLO

ESQUERDA:
	cmp		al,4Bh
	jne		DIREITA
	dec		POSx			;Esquerda
	jmp		CICLO

DIREITA:
	cmp		al,4Dh
	jne		LER_SETA 
	inc		POSx			;Direita
	jmp		CICLO
	
GANHOU:
	CALL 	limpa_tela
	CALL 	Ler_tempo_fim
	
	mov 	ax, Horas_inicio
	sub 	Horas_fim, ax
	mov 	ax, Minutos_inicio
	sub 	Minutos_fim, ax
	mov 	ax, Segundos_inicio
	sub 	Segundos_fim, ax
	
	goto_xy 1, 1
	mostra 	msg_final
	
	MOV 	ax,Horas_fim
	MOV 	bl, 10     
	div 	bl
	add 	al, 30h				; Caracter Correspondente às dezenas
	add		ah,	30h				; Caracter Correspondente às unidades
	MOV 	strHoras[0],al			; 
	MOV 	strHoras[1],ah
	MOV 	strHoras[2],'h'		
	MOV 	strHoras[3],'$'
	goto_xy 50, 1
	mostra 	strHoras
	
	MOV		ax,Minutos_fim
	MOV 	bl, 10     
	div 	bl
	add 	al, 30h				; Caracter Correspondente às dezenas
	add		ah,	30h				; Caracter Correspondente às unidades
	MOV 	strHoras[0],al			; 
	MOV 	strHoras[1],ah
	MOV 	strHoras[2],'m'		
	MOV 	strHoras[3],'$'
	goto_xy 54, 1
	mostra 	strHoras
	
	MOV 	ax,Segundos_fim
	MOV 	bl, 10     
	div 	bl
	add 	al, 30h				; Caracter Correspondente às dezenas
	add		ah,	30h				; Caracter Correspondente às unidades
	MOV 	strHoras[0],al			; 
	MOV 	strHoras[1],ah
	MOV 	strHoras[2],'s'		
	MOV 	strHoras[3],'$'
	goto_xy 58, 1
	mostra 	strHoras
	
	call 	LE_TECLA
	
SAI_JOGO:
	ret
JOGO ENDP

VERIFICA_POS PROC
	goto_xy 20, 18
	mov 	ah, 08h			
	mov		bh,0
	int		10h			
	mov		Car, al
	cmp 	Car, '_'
	JNE 	ERRO
SUCESSO:
	CALL 	JOGO
	JMP 	SAI
ERRO:
	call 	limpa_tela
	goto_xy 1, 1
	mostra 	msg_erro_jogo
	goto_xy 64, 1
	call 	LE_TECLA
SAI:
	ret
VERIFICA_POS ENDP

MENU PROC
MENU_INT:
	CALL 	limpa_tela
	goto_xy 1, 1
	mostra 	gamaze1
	goto_xy 1, 2
	mostra 	gamaze2
	goto_xy 1, 3
	mostra 	gamaze3
	goto_xy 1, 4
	mostra 	gamaze4
	goto_xy 1, 5
	mostra 	gamaze5
	
	goto_xy 1, 7
	mostra 	Op_jogo
	goto_xy 1, 8
	mostra 	Op_sair
	
	goto_xy 1, 10
	mostra 	Op_msg
	
	goto_xy -1, -1
	
	CALL 	LE_TECLA
	cmp 	al, '1'
	JE 		LJOGO
	cmp 	al, '2'
	JE 		SAI
	JMP 	MENU_INT

LJOGO:
	CALL 	IMPRIME_FICHEIRO
	CALL 	VERIFICA_POS
	JMP 	MENU_INT
SAI:
	CALL limpa_tela
	goto_xy 1, 1
	mostra Op_msg_sair
	CALL LE_TECLA
	cmp al, 's'
	JE GOREP
	cmp al, 'n'
	JE MENU_INT
	JMP SAI
GOREP:
	ret
MENU ENDP

Main    Proc
	
	mov 	ax, dseg
	mov 	ds, ax

	mov 	ax, 0b800h
	mov 	es, ax
	
	CALL 	MENU

sai:
	call 	limpa_tela
	goto_xy 0, 0
	mov     ah,4ch
	int     21h	
Main    endp
cseg	ends
end     Main           

