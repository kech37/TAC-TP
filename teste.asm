.8086
.model small
.stack 2048h

dseg    segment para public 'data'
              gamaze1 db '########     ###     ####   ####     ###     ###### ######'
              gamaze2 db '##          ## ##    ## ## ## ##    ## ##       ##  ##    '
              gamaze3 db '##  ####   ##   ##   ##  ###  ##   ##   ##     ##   ######'
              gamaze4 db '##    ##  #########  ##       ##  #########   ##    ##    '
              gamaze5 db '######## ##       ## ##       ## ##       ## ###### ######'

           menu_jogar db '               > Jogar                                    '
           menu_top10 db '               > Top 10                                   '
          menu_config db '               > Configuracao do Labirinto                '
            menu_sair db '               > Sair                                     '
menu_sair_confirmacao db ' Tem a certeza que quer sair? (s/n) '
	            tecla db ?

    Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
    Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
    Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
    Fich         	db      'default.txt',0
    HandleFich      dw      0
    car_fich        db      ?
	
	Car				db		32	; Guarda um caracter do Ecran 
	Cor				db		7	; Guarda os atributos de cor do caracter
	POSy			db		?	; a linha pode ir de [1 .. 25]
	POSx			db		?	; POSx pode ir [1..80]	
	POSya			db		?	; Posição anterior de y
	POSyInt			db		?
	POSxInt			db		?
	POSxa			db		?	; Posição anterior de x
dseg    ends

cseg    segment para public 'code'
	assume  cs:cseg, ds:dseg

;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

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
; LE UMA TECLA PARA O MENU	
LE_TECLA_MENU proc    
ciclo:
        mov   ah,0bh            ;funcao que verifica o buffer do teclado
        int   21h
        cmp   al,0ffh           ;Ve se tem Tecla no Buffer
        jne   ciclo         	;Enquanto não tem tem tecla no buffer,espera
        mov   ah,08h            ;Funcao para ler do teclado/buffer
        int   21h            
        cmp   al,0              ;Ve se a tecla lida=0 (estendida)
        jne   tecla_simples     ;Se nao era estendida trata tecla                                  
        mov   ah,08h            ;sendo estendida volta a ler codigo
        int   21h
	
tecla_simples:
	mov   tecla,al

ret
LE_TECLA_MENU endp

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
	mov     ah,09h
	lea     dx,Erro_Open
	int     21h
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
	mov     ah,09h
	lea     dx,Erro_Ler_Msg
	int     21h

fecha_ficheiro:				; vamos fechar o ficheiro 
	mov     ah,3eh
	mov     bx,HandleFich
	int     21h
	jnc     sair_imprime
	call 	limpa_tela
	mov     ah,09h			; o ficheiro pode não fechar correctamente
	lea     dx,Erro_Close
	Int     21h

sair_imprime:
	ret
IMPRIME_FICHEIRO ENDP

;########################################################################
;ROTINA PARA ENCONTRA _
PROCURA_INICIO PROC
	mov POSxInt, 20
	mov POSyInt, 18
PROCURA_INICIO ENDP

;########################################################################
;ROTINA PARA JOGAR
JOGO PROC

POS_INICIAL:
	mov POSxInt, 20
	mov al, POSxInt
	mov POSxa, al
	mov POSx, al
	
	mov POSyInt, 18
	mov al, POSyInt
	mov POSya, al
	mov POSy, al
	
	goto_xy	POSx,POSy		; Vai para nova possição
	mov 	ah, 08h			; Guarda o Caracter que está na posição do Cursor
	mov		bh,0			; numero da página
	int		10h			
	mov		Car, al			; Guarda o Caracter que está na posição do Cursor
	mov		Cor, ah			; Guarda a cor que está na posição do Cursor

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
	mov		Cor, ah			; Guarda a cor que está na posição do Cursor
	
	cmp Car, '+'
	JE POS_INICIAL
	
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

SAI_JOGO:
	ret
JOGO ENDP

;########################################################################
;ROTINA PARA MENU
MENU PROC
	call limpa_tela
	xor si,si
	mov bx,662;4*160=640 11*2=22 640+22=662 o que da linha 4 coluna11
	mov al,00000010b;verde
	mov cx, 58
ciclo_gamaze:	
	mov ah,gamaze1[si]
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,gamaze2[si]
	mov es:[bx+160],ah
	mov es:[bx+161],al
	mov ah,gamaze3[si]
	mov es:[bx+320],ah
	mov es:[bx+321],al
	mov ah,gamaze4[si]
	mov es:[bx+480],ah
	mov es:[bx+481],al
	mov ah,gamaze5[si]
	mov es:[bx+640],ah
	mov es:[bx+641],al
	add bx,2
	inc si	
	loop ciclo_gamaze
	
	xor si,si
	mov bx,1782;11*160=1782 11*2=22 1760+22=1782 o que da linha 11 coluna11
	mov cx, 58
ciclo_ops:
	mov ah,menu_jogar[si]
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,menu_top10[si]
	mov es:[bx+160],ah
	mov es:[bx+161],al;                                      
	mov ah,menu_config[si]
	mov es:[bx+320],ah
	mov es:[bx+321],al
	mov ah,menu_sair[si]
	mov es:[bx+480],ah
	mov es:[bx+481],al;  
	add bx,2
	inc si	
	loop ciclo_ops
	
	mov posy,11
	mov ah,2
	mov bh,0
	mov dh,posy               
	mov dl,25
	int 10h;                      
	
ciclo_upDown:
	call LE_TECLA_MENU
	
	cmp tecla,0dh
	jne cima
	jmp SAI_MENU

cima:	
	cmp tecla,'H'
	jne baixo
	dec POSy
	cmp POSy,11
	jnb escreve
	mov POSy,14;                  VE SE A TECLA E UM ENTER, PARA CIMA OU PARA BAIXO
	jmp escreve
	
baixo:
	cmp tecla,'P'
	jne ciclo_upDown
	inc POSy
	cmp POSy,14
	jng escreve
	mov POSy,11
	jmp escreve
	
escreve:    
	mov ah,02h
	mov bh,00h
	mov dh,POSy;            ESCREVE O CURSOR CASO A TECLA TANHA SIDO PARA CIMA OU PARA BAIXO
	mov dl,25
	int 10h         
	jmp ciclo_upDown
	
	cmp posy,11
	jne opcao2
	CALL IMPRIME_FICHEIRO
	CALL JOGO
	jmp SAI_MENU
opcao2:
	cmp posy,12
	jne opcao3
	;call f_menu_jogar
	jmp SAI_MENU
opcao3:
	cmp posy,13
	jne opcao4
	;call f_menu_jogar
	jmp SAI_MENU
opcao4:
	cmp posy,14
	jmp SAI_MENU
	
SAI_MENU:
	ret
MENU ENDP

Main    Proc
	
	mov ax, dseg
	mov ds, ax

	mov ax, 0b800h
	mov es, ax
	
	CALL IMPRIME_FICHEIRO
	CALL JOGO	

sai:
	mov     ah,4ch
	int     21h	
Main    endp
cseg	ends
end     Main           

