.8086
.MODEL SMALL
.STACK 2048

DADOS	SEGMENT PARA 'DATA'

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

 labOmisso1 db '███░████████████░███████████░███████████'
 labOmisso2 db '█   ██         █ █           █         █'
 labOmisso3 db '█ ██████ ███████ █ █████ █      ████ █ █'
 labOmisso4 db '█ █    █ ██      █ █     ██████    █ ███'
 labOmisso5 db '█ █ █  █ ███████████ █ █      ██ ███   █'
 labOmisso6 db '█ █ ████       █   ███ █ ████ █    ██ ██'
 labOmisso7 db '█ █   ██ ███████ █   █ █   ███████  █  █'
 labOmisso8 db '█ █ █ █   █  █   ███ █ █ ███   █    █  █'
 labOmisso9 db '█ █ █ █   █  █ ███ █ ███ █ █ █   █ █████'
labOmisso10 db '█ ███ ███ ████     █ █ ███ ███████     █'
labOmisso11 db '█     █      █████ █ █     █       ███ █'
labOmisso12 db '█ ██████████     █ █ █ █████████     █ █'
labOmisso13 db '█ █    █   █████ █ █ █ █   █   █ ███ █ █'
labOmisso14 db '█ ████ █ █     █ █ █   ███ █ █     █ █ █'
labOmisso15 db '█    █   █████ █ █ ███   █   ████  █ █ █'
labOmisso16 db '█ █  █████   █ █ █ █   █ █  ██ █   █ █ █'
labOmisso17 db '█ █       █    █ █ █ █ █       █   █ █ █'
labOmisso18 db '█ ███████ █ ████   █ █ ███████ █ █ ███ █'
labOmisso19 db '█ █       █ █    █ █ █  █        █     █'
labOmisso20 db '████████████████████▓███████████████████' 
teclasair db 0
posy db ?
posx db ?
tecla db ?


DADOS	ENDS

CODIGO	SEGMENT PARA 'CODE'
	ASSUME CS:CODIGO, DS:DADOS

INICIO:
	MOV ax, DADOS
	MOV ds, ax

	MOV ax, 0b800h
	MOV es, ax
	
	CALL limpa_tela
	
	CALL gamaze
	
	CALL primeiro_menu
	
	CALL set_cursor
	
	CALL cmp_tecla
	
	cmp teclasair, 1
	jne INICIO
	
	MOV	AH,4Ch
	INT	21h
	
;--------------------------- Função para "limpar" o ecra -------------------------
limpa_tela proc
	mov al,0h
	mov ah,' '
	mov bx,0
	mov cx,25*80
ciclo:
	mov es:[bx],ah                               
	mov es:[bx+1],al
	add bx,2
	loop ciclo

ret
limpa_tela endp
;--------------------------------------------------------------------------------

;--------------- Função para imprimir na consola o logotipo ---------------------
gamaze proc
	xor si,si
	mov bx,662;4*160=640 11*2=22 640+22=662 o que da linha 4 coluna11
	mov al,00000010b;verde
	mov cx, 58
ciclo:	
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
	loop ciclo
ret
gamaze endp
;--------------------------------------------------------------------------------

;---------------------------------imprime o menu principal-----------------------
primeiro_menu proc

	xor si,si
	mov bx,1782;11*160=1782 11*2=22 1760+22=1782 o que da linha 11 coluna11
	mov al,00000010b;verde
	mov cx, 58
ciclo:
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
	loop ciclo
ret
primeiro_menu endp
;------------------------------------------------------------------------------- 

;--------------------------------INICIALIZA O CURSOR----------------------------
set_cursor proc
	mov posy,11
	mov ah,2
	mov bh,0
	mov dh,posy               
	mov dl,25
	int 10h;                      
	
	
ciclo:
	call le_tecla
	
	cmp tecla,0dh
	jne cima
	jmp fim

cima:	
	cmp tecla,'H'
	jne baixo
	dec posy
	cmp posy,11
	jnb escreve
	mov posy,14;                  VE SE A TECLA E UM ENTER, PARA CIMA OU PARA BAIXO
	jmp escreve
	
baixo:
	cmp tecla,'P'
	jne ciclo
	inc posy
	cmp posy,14
	jng escreve
	mov posy,11
	jmp escreve
	
escreve:    
	mov ah,02h
	mov bh,00h
	mov dh,posy;            ESCREVE O CURSOR CASO A TECLA TANHA SIDO PARA CIMA OU PARA BAIXO
	mov dl,25
	int 10h         
	jmp ciclo
FIM:	
ret
set_cursor endp
;-----------------------------------------------------------------------------------------------

;--------------------------RECEBE UMA TECLA DO TECLADO E GUARDA NA VARIAVEL TECLA---------------
le_tecla proc    
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
le_tecla endp
;--------------------------------------------------------------------------------------------------

;---COMPARA O SITIO ONDE ESTA O CURSOR QUANDO SE CARREGA NO ENTER E CHAMA A FUNÇAO CONRESPONDENTE--
cmp_tecla proc

	cmp posy,11
	jne opcao2
	call f_menu_jogar
	jmp FIM
opcao2:
	cmp posy,12
	jne opcao3
	call f_menu_jogar
	jmp FIM
opcao3:
	cmp posy,13
	jne opcao4
	call f_menu_jogar
	jmp FIM
opcao4:
	cmp posy,14
	call sair;------>Sair do programa
	jmp FIM

FIM: ;-------MOVE O CURSOR PARA FORA DO  ECRA PARA NAO SER VISTO---------
	mov ah,02h
	mov bh,00h
	mov dh,25                                      
	mov dl,80
	int 10h
	
ret
cmp_tecla endp
;--------------------------------------------------------------------------------------------------

;------------------------------- F_menu_jogar   ---------------------------------------------------
f_menu_jogar proc
	call limpa_tela
	call gamaze
	xor si,si
	mov bx,1782;11*160=1782 11*2=22 1760+22=1782 o que da linha 11 coluna11
	mov al,00000010b;verde
	mov cx, 40
ciclo:
	mov ah,labOmisso1[si]
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,labOmisso2[si]
	mov es:[bx+160],ah
	mov es:[bx+161],al;                                      
	mov ah,labOmisso3[si]
	mov es:[bx+320],ah
	mov es:[bx+321],al
	mov ah,labOmisso4[si]
	mov es:[bx+480],ah
	mov es:[bx+481],al; 
	mov ah,labOmisso5[si]
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,labOmisso6[si]
	mov es:[bx+640],ah
	mov es:[bx+641],al;                                      
	mov ah,labOmisso7[si]
	mov es:[bx+800],ah
	mov es:[bx+801],al
	mov ah,labOmisso8[si]
	mov es:[bx+960],ah
	mov es:[bx+961],al; 
	mov ah,labOmisso9[si]
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,labOmisso10[si]
	mov es:[bx+1020],ah
	mov es:[bx+1021],al;                                      
	mov ah,labOmisso11[si]
	mov es:[bx+1280],ah
	mov es:[bx+1281],al
	mov ah,labOmisso12[si]
	mov es:[bx+1440],ah
	mov es:[bx+1441],al; 
	mov ah,labOmisso13[si]
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,labOmisso14[si]
	mov es:[bx+1600],ah
	mov es:[bx+1601],al;                                      
	mov ah,labOmisso15[si]
	mov es:[bx+1760],ah
	mov es:[bx+1761],al
	mov ah,labOmisso16[si]
	mov es:[bx+1920],ah
	mov es:[bx+1921],al; 
	mov ah,labOmisso17[si]
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,labOmisso18[si]
	mov es:[bx+2080],ah
	mov es:[bx+2081],al;                                      
	mov ah,labOmisso19[si]
	mov es:[bx+2240],ah
	mov es:[bx+2241],al
	mov ah,labOmisso20[si]
	mov es:[bx+2400],ah
	mov es:[bx+2401],al; 	
	add bx,2
	inc si	
	dec cx
	jne ciclo
	call le_tecla
ret
f_menu_jogar endp
;--------------------------------------------------------------------------------------------------

;-------------------------------Sair do programa---------------------------------------------------
sair proc
	call limpa_tela

	call gamaze
	
	xor si,si
	mov bx,2120;13*160=2080 20*2=40 40+2080=2120 linha13 coluna 20
	mov al,00000010b;verde
	mov cx,36
ciclo:
	mov ah,menu_sair_confirmacao[si];------->Imprime a mensagem
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop ciclo

	call le_tecla
	cmp tecla,'s';----->verifica se a tecla foi 's'
	jne fim
	mov teclasair,1
fim:
ret
sair endp
;--------------------------------------------------------------------------------------------------

CODIGO	ENDS
END	INICIO
