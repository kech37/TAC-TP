;Filipe Rainho 21210375
;Paulo Costa 21210849

.8086
.model small
.stack 2048

dseg	segment
    guru1 db '### # # ### # #   # # ### ### ### # # #'
	guru2 db '#   # # # # # #   ### # #  #  # # # # #'
	guru3 db '# # # # ### # #   # # ###  #  ### #  # '
	guru4 db '# # # # ##  # #   # # # #  #  ##  # # #'
	guru5 db '### ### # # ###   # # # #  #  # # # # #'



	menu1 db '         Classificacao De Matrizes         '
	menu2 db '         Operacoes Sobre Matrizes          '
	menu3 db '                   Sair                    '
	menu_sair db 'Tem a certeza que quer sair? (s/n): '
	num_lin db 'Qual e o numero de linhas da matriz?';36
	num_col db 'Qual e o numero de colunas da matriz?';37
	pedir_escalar db '   Qual e o escalar que pretende?    ';37
	pedir_matriz db 'Insira uma matriz: ';19
	
	;------------Matrizes-----------------
	tipo db ?
	tipoRS db 'Rectangular Sim';15
	tipoRN db 'Rectangular Nao';15
	tipoQS db 'Quadrada Sim';12
	tipoQN db 'Quadrada Nao';12
	tipoTSS db 'Triangular superior Sim';23
	tipoTSN db 'Triangular superior Nao';23
	tipoTIS db 'Triangular inferior Sim';23
	tipoTIN db 'Triangular inferior Nao';23
	tipoDS db 'Diagonal Sim';12
	tipoDN db 'Diagonal Nao';12
	tipoES db 'Escalar Sim';11
	tipoEN db 'Escalar Nao';11
	pedirMatriz db 'Insira a matriz: ';17
	;-------------------------------------
	
	vector db 67
	vector_seg db 67
	vectorfinal dw 67
	tab db '-------------------------------------';37
	tab2 db '| - | - | - | - | - | - | - | - | - |';37
	msgEnter db 'Clique a tecla Enter para terminar';34
	
	tot_lin db ?
	tot_col db ?
	aux dw 0
	aux2 dw 0
	count_i dw 0
	divisor db 4
	total db ?
	count_lin db ?
	count_col db ?
	posy db ?
	posx db ?
	valory dw ?
	valorx dw ?
	vectory dw ?
	vectorx dw ?
	limy db ?
	limx db ?
	valorAux db ?
	verdade db 0
	tecla db ?
	teclasair db 0
	escalar db ?

	;--------------Operaçoes----------------
	menuSoma db       '- Soma                   ';7
	menuSubtracao db  '- Subtracao              ';12
	menuProdutoE db   '- Produto por um escalar ';25
	menuProduto db    '- Produto                ';10
	menuTransposta db '- Transposta             ';13
	;---------------------------------------

dseg    ends

cseg	segment para public 'code'
	assume  cs:cseg ,ds:dseg

;--------------------------------------------------------INICIO DO CODIGO-----------------------------------------------------------------------------------------------
Main  proc

inicio:	mov ax,dseg
	mov ds,ax

	mov   ax,0b800h
	mov   es,ax

	call limpa_tela

	call guru

	call primeiro_menu

	call set_cursor

	call cmp_tecla
	
	cmp teclasair,1
	jne inicio

	mov ah,4ch
	int 21h
main endp

;----------------------------------------imprime uma tela toda preta-------------
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

;-------------------------------------imprime O titulo---------------------------
guru proc
	xor si,si
	mov bx,680;4*160=640 20*2=40 640+40=680 o que da linha4 coluna 20
	mov al,00000010b;verde
	mov cx,39
ciclo:	
	mov ah,guru1[si]
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,guru2[si]
	mov es:[bx+160],ah
	mov es:[bx+161],al
	mov ah,guru3[si]
	mov es:[bx+320],ah
	mov es:[bx+321],al
	mov ah,guru4[si]
	mov es:[bx+480],ah
	mov es:[bx+481],al
	mov ah,guru5[si]
	mov es:[bx+640],ah
	mov es:[bx+641],al
	add bx,2
	inc si	
	loop ciclo
ret
guru endp
;--------------------------------------------------------------------------------

;---------------------------------imprime o menu principal-----------------------
primeiro_menu proc

	xor si,si
	mov bx,1796;11*160=1760 18*2=36 1760+40=1796 o que da linha 11 coluna18
	mov al,00000010b;verde
	mov cx,43
ciclo:
	mov ah,menu1[si]
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,menu2[si]
	mov es:[bx+160],ah
	mov es:[bx+161],al;                                      
	mov ah,menu3[si]
	mov es:[bx+320],ah
	mov es:[bx+321],al
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
	mov dl,21
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
	mov posy,13;                  VE SE A TECLA E UM ENTER, PARA CIMA OU PARA BAIXO
	jmp escreve
	
baixo:
	cmp tecla,'P'
	jne ciclo
	inc posy
	cmp posy,13
	jng escreve
	mov posy,11
	jmp escreve
	
escreve:    
	mov ah,02h
	mov bh,00h
	mov dh,posy;            ESCREVE O CURSOR CASO A TECLA TANHA SIDO PARA CIMA OU PARA BAIXO
	mov dl,21
	int 10h         
	jmp ciclo
fim:	
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
	call menu_cla;----->Menu classificacao
	jmp FIM
opcao2:
	cmp posy,12
	jne opcao3
	call menu_ope;------>Menu operacao
	jmp FIM
opcao3:
	cmp posy,13
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

;-------------------------------Sair do programa---------------------------------------------------
sair proc
	call limpa_tela

	call guru
	
	xor si,si
	mov bx,2120;13*160=2080 20*2=40 40+2080=2120 linha13 coluna 20
	mov al,00000010b;verde
	mov cx,36
ciclo:
	mov ah,menu_sair[si];------->Imprime a mensagem
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

;-------------------------------Actualizar posiçao na tabela---------------------------------------
calc_pos_array proc
	cima:
	cmp tecla, 'H'
	jne baixo
	dec posy
	dec vectory
	cmp posy, 2 
	jae actualizarPos
	mov posy, 8
	mov vectory, 6
	jmp actualizarPos

baixo:
	cmp tecla, 'P'
	jne direita
	inc posy 
	inc vectory
	cmp posy, 8 
	jbe actualizarPos
	mov posy, 2
	mov vectory, 0
	jmp actualizarPos

direita: 
	cmp tecla, 'M'
	jne esquerda
	add posx, 4
	inc vectorx
	cmp posx, 39
	jbe actualizarPos
	mov posx, 7
	mov vectorx, 0
	jmp actualizarPos

esquerda:
	cmp tecla, 'K'
	jne fim
	sub posx, 4
	dec vectorx
	cmp posx, 7 
	jae actualizarPos
	mov posx, 39
	mov vectorx, 8
	jmp actualizarPos

actualizarPos:
	mov ah,02h
	mov bh,00h
	mov dh,posy;            situar cursor
	mov dl,posx
	int 10h
	;jmp cicloLervalores

fim:
ret
calc_pos_array endp
;--------------------------------------------------------------------------------------------------

ler_linhas proc
ciclo2:	
	cmp tecla, 31h
	je umY
	cmp tecla, 32h
	je doisY
	cmp tecla, 33h
	je tresY
	cmp tecla, 34h
	je quatroY
	cmp tecla, 35h
	je cincoY
	cmp tecla, 36h
	je seisY
	cmp tecla, 37h
	je seteY
umY:
	mov limy, 1
	jmp ennn
doisY:
	mov limy, 2
	jmp ennn
tresY:
	mov limy, 3
	jmp ennn
quatroY:
	mov limy, 4
	jmp ennn
cincoY:
	mov limy, 5
	jmp ennn
seisY:
	mov limy, 6
	jmp ennn
seteY:
	mov limy, 7
	jmp ennn
ennn:
ret
ler_linhas endp

ler_colunas proc
ciclo4:
	cmp tecla, 31h
	je umX
	cmp tecla, 32h
	je doisX
	cmp tecla, 33h
	je tresX
	cmp tecla, 34h
	je quatroX
	cmp tecla, 35h
	je cincoX
	cmp tecla, 36h
	je seisX
	cmp tecla, 37h
	je seteX
	cmp tecla, 38h
	je oitoX
	cmp tecla, 39h
	je noveX
umX:
	mov limx, 1
	jmp enn
doisX:
	mov limX, 2
	jmp enn
tresX:
	mov limx, 3
	jmp enn
quatroX:
	mov limx, 4
	jmp enn
cincoX:
	mov limx, 5
	jmp enn
seisX:
	mov limx, 6
	jmp enn
seteX:
	mov limx, 7
	jmp enn
oitoX:
	mov limx, 8
	jmp enn
noveX:
	mov limx, 9
	jmp enn
enn:	
ret
ler_colunas endp

;-------------------------------Menu da classificacao----------------------------------------------
menu_cla proc
	;------------num lin-------
	call limpa_tela
	call guru
	
	xor si,si
	mov bx,2120;13*160=2080 20*2=40 40+2080=2120 linha13 coluna 20
	mov al,00000010b;verde
	mov cx,36
ciclo:
	mov ah,num_lin[si];------->Imprime a mensagem
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop ciclo
	
	mov ah,02h
	mov bh,00h
	mov dh,13;            situar cursor
	mov dl,56
	int 10h 

 
ciclo2:
	call le_tecla
	cmp tecla, 37h
	ja ciclo2
	cmp tecla, 31h
	jb ciclo2
	mov ah, tecla
	mov tot_lin, ah
	
	call ler_linhas
	
	;------------num col-------
	call limpa_tela
	call guru
	
	xor si,si
	mov bx,2120;13*160=2080 20*2=40 40+2080=2120 linha13 coluna 20
	mov al,00000010b;verde
	mov cx,37
ciclo3:
	mov ah,num_col[si];------->Imprime a mensagem
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop ciclo3
	
	mov ah,02h
	mov bh,00h
	mov dh,13;            situar cursor
	mov dl,57
	int 10h 

ciclo4:
	call le_tecla
	cmp tecla, 39h;'9'
	ja ciclo4
	cmp tecla, 31h
	jb ciclo4
	mov ah, tecla
	mov tot_col, ah

	call ler_colunas
	
	mov count_lin, 30h
	
	mov count_col, 30h
	xor di, di
	call limpa_tela
	
	xor si,si	
	mov bx,170;1*160=160 5*2=10 10+160=340 linha1 coluna 5		
	mov al,00000010b;verde
	mov cx,37
	ciclotab:
		mov ah,tab[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotab

	mov count_lin, 30h
	add aux, 170
ciclo5:	
	inc count_lin
	add aux, 160
	mov bx,aux
	xor si,si	
	mov al,00000010b;verde
	mov cx,37
	ciclotab2:
		mov ah,tab2[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotab2
	cmp count_lin, 37h
	jne ciclo5
	
	xor si,si	
	mov bx,1450	
	mov al,00000010b;verde
	mov cx,37
	ciclotabFundo:
		mov ah,tab[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotabFundo
	
	xor si,si	
	mov bx,1780	
	mov al,00000010b;verde
	mov cx,34
	ciclomsgenter:
		mov ah,msgEnter[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclomsgenter
	
	mov ah,02h
	mov bh,00h
	mov dh,2;            situar cursor
	mov dl,7
	int 10h
	mov posy, 2
	mov posx, 7
	mov vectory, 0
	mov vectorx, 0

cicloLervalores:
	call le_tecla	
	
	call calc_pos_array

valoress:
	cmp tecla, 0dh
	je terminar
	cmp tecla, 30h
	jb cicloLervalores
	cmp tecla, 39h
	ja cicloLervalores	
	
	;-------------calcular valory-------------
	mov bx, vectory
	mov valory, bx
	
	mov ah, 0
	mov al, limy
	dec al

	cmp valory, ax
	ja cicloLervalores
	;-----------------------------------------
	;-------------calcular valorx-------------
	mov bx, vectorx
	mov valorx, bx
	
	mov ah, 0
	mov al, limx
	dec al
	
	cmp valorx, ax
	ja cicloLervalores
	;-----------------------------------------
	
	;-----------guardar no vector-------------
	xor si, si
	mov ah, 0
	mov al, limx
	mul vectory 
	add ax, vectorx
	mov si, ax
	
	mov ah, tecla
	mov vector[si], ah
	;-----------------------------------------
	;-----------actualizar ecrã---------------
	mov aux, 160
	mov aux2, 2
	
	mov bh, 0
	mov bl, posy	
	mov ax, bx;      calcular a linha
	mul aux
	mov aux, ax
	
	mov bh, 0
	mov bl, posx
	mov ax, bx;      calcular a coluna
	mul aux2
	add aux, ax
	mov bx, aux
	
	mov ah, es:[bx]
	cmp ah, '-'
	jne imprimirTeclaN
	inc count_i
	
imprimirTeclaN:
	mov ah, tecla	
	mov es:[bx],ah;  alterar no ecrã
	mov al,00000010b;verde
	mov es:[bx+1],al
	;-----------------------------------------
	jmp cicloLervalores
	
terminar:
	mov ah, 0
	mov al, limy
	mul limx	
	
	cmp count_i, ax
	jne cicloLervalores	
	
	;------------fazer a classificacao------------
class:	
	call limpa_tela
	mov ah, tot_lin
	cmp tot_col, ah
	jne diferente
	je igual
	

diferente:
	xor si,si
	mov bx,340
	mov al,00000010b;verde
	mov cx,15
cicloA:
	mov ah,tipoRS[si];------->Imprime a mensagem Rectangular
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloA

	xor si,si
	mov bx,500
	mov al,00000010b;verde
	mov cx,12
cicloB:
	mov ah,tipoQN[si];------->Imprime a mensagem Quadrada
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloB

	xor si,si
	mov bx,680
	mov al,00000010b;verde
	mov cx,23
cicloC:
	mov ah,tipoTSN[si];------->Imprime a mensagem Triangular superior
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloC

	xor si,si
	mov bx,840
	mov al,00000010b;verde
	mov cx,23
cicloD:
	mov ah,tipoTIN[si];------->Imprime a mensagem Triangular inferior
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloD

	xor si,si
	mov bx,1000
	mov al,00000010b;verde
	mov cx,12
cicloE:
	mov ah,tipoDN[si];------->Imprime a mensagem Diagonal
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloE

	xor si,si
	mov bx,1160
	mov al,00000010b;verde
	mov cx,11
cicloF:
	mov ah,tipoEN[si];------->Imprime a mensagem Escalar
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloF
	

	jmp conti; saltar fora

igual:
	
	xor si,si
	mov bx,660
	mov al,00000010b;verde
	mov cx,15
cicloZ:
	mov ah,tipoRN[si];------->Imprime a mensagem RETANGULAR NAO
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloZ

	xor si,si
	mov bx,820
	mov al,00000010b;verde
	mov cx,12
cicloX:
	mov ah,tipoQS[si];------->Imprime a mensagem QUADRADO SIM
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloX

	;--------------iniciar variaveis----
	mov vectory, 1
	mov vectorx, 0
	mov valorx, 0
	mov verdade, 0
	;-----------------------------------
	;----------ver primeiro elemento----
	xor si, si
	mov ah, 0
	mov al, limx
	mul vectory 
	add ax, vectorx
	mov si, ax
	
	mov ah, vector[si]
	cmp ah, 30h 
	jne fora
	;-----------------------------------

trinSup:              ;-----------Verificar se é triangular superior 
	inc vectory
	inc vectorx
	mov valorx, 0
	mov ah, 0
	mov al, limy
	cmp vectory, ax
	je continuar
	trinSup2:
		xor si, si
		mov ah, 0
		mov al, limx
		mul vectory 
		add ax, valorx
		mov si, ax
				
		mov ah, vector[si]
		cmp ah, 30h 
		jne fora		
		mov ax, valorx
		inc valorx
		cmp vectorX, ax		
		jne trinSup2
		je trinSup

continuar:    ;--------------Mostrar Triangular Superior SIM---------
	xor si,si
	mov bx,1000
	mov al,00000010b;verde
	mov cx,23
cicloTSS:
	mov ah,tipoTSS[si];------->Imprime a mensagem triangular superior sim
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloTSS
	mov verdade, 1;----------------------------------->verdade = 1
	jmp verificacao2
;--------------------------------------------------------------------
	

fora:    ;--------------Mostrar Triangular Superior NAO---------	
	xor si,si
	mov bx,1000;3*160=480 10*2=20 20+480=500 linha3 coluna 10
	mov al,00000010b;verde
	mov cx,23
cicloTSN:
	mov ah,tipoTSN[si];------->Imprime a mensagem
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloTSN
;--------------------------------------------------------------------

verificacao2: ;-----------Verificar se é triangular inferior
	;--------------iniciar variaveis----
	mov ah, 0
	mov al, limy
	sub al, 2
	mov vectory, ax
	
	mov al, limx
	dec al
	mov vectorx, ax
	mov valorx, ax
	;-----------------------------------
	xor si, si
	mov ah, 0
	mov al, limx
	mul vectory 
	add ax, vectorx
	mov si, ax
	
	mov ah, vector[si]
	cmp ah, 30h
	jne fora2

trinInf:              ;-----------Verificar se é triangular inferior 
	
	mov ah, 0
	mov al, limx
	dec al
	mov valorx, ax
	mov ax, 0
	cmp vectory, ax
	je continuar2
	dec vectory
	dec vectorx
	trinInf2:
		xor si, si
		mov ah, 0
		mov al, limx
		mul vectory 
		add ax, valorx
		mov si, ax		
		
		mov ah, vector[si]	

		cmp ah, 30h 
		jne fora2		
		mov ax, valorx
		dec valorx
		cmp vectorX, ax		
		jne trinInf2
		je trinInf
	
	

continuar2:
	xor si,si
	mov bx,1160
	mov al,00000010b;verde
	mov cx,23
cicloTIS:
	mov ah,tipoTIS[si];------->Imprime a mensagem triangular inferior sim
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloTIS
	;---------------|---->ver se passa para escalar e diagonal
	cmp verdade, 1
	jne fora3
	je continuar3
	jmp conti

fora2:
	xor si,si
	mov bx,1160
	mov al,00000010b;verde
	mov cx,23
cicloTIN:
	mov ah,tipoTIN[si];------->Imprime a mensagem triangular inferior nao
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloTIN
	jmp fora3

continuar3:     ;--------------------Verificar Escalar

	;------------iniciar pos------------
	mov vectory, 0
	mov vectorx, 0
	;-----------------------------------
	;------------ver pos 0,0------------
	xor si, si
	mov ah, 0
	mov al, limx
	mul vectory 
	add ax, vectorx
	mov si, ax		
	
	mov ah, vector[si]
	mov valorAux, ah
	;-----------------------------------
cicloEscalar:
	inc vectory
	inc vectorx
	xor si, si
	mov ah, 0
	mov al, limx
	mul vectory 
	add ax, vectorx
	mov si, ax		
	
	mov ah, vector[si]
	
	cmp valorAux, ah
	jne DiagonalNao
	mov ah, 0
	mov al, limy
	dec al
	cmp vectory, ax
	je EscalarSim
	jne cicloEscalar

EscalarSim:
	xor si,si
	mov bx,1320
	mov al,00000010b;verde
	mov cx,11
cicloEscalarSim:
	mov ah,tipoES[si];------->Imprime a mensagem escalar sim
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloEscalarSim
	
	xor si,si
	mov bx,1480
	mov al,00000010b;verde
	mov cx,12
cicloDiagonalNao:
	mov ah,tipoDN[si];------->Imprime a mensagem diagonal nao
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloDiagonalNao
	jmp conti


DiagonalNao:
	xor si,si
	mov bx,1320
	mov al,00000010b;verde
	mov cx,11
cicloEscalarNao:
	mov ah,tipoEN[si];------->Imprime a mensagem escalar nao
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloEscalarNao
	
	xor si,si
	mov bx,1480
	mov al,00000010b;verde
	mov cx,12
cicloDiagonalSim:
	mov ah,tipoDS[si];------->Imprime a mensagem diagonal sim
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloDiagonalSim
	jmp conti
	


fora3:
	xor si,si
	mov bx,1320
	mov al,00000010b;verde
	mov cx,11
cicloEN:
	mov ah,tipoEN[si];------->Imprime a mensagem escalar nao
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloEN

	xor si,si
	mov bx,1480
	mov al,00000010b;verde
	mov cx,12
cicloDN:
	mov ah,tipoDN[si];------->Imprime a mensagem diagonal nao
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop cicloDN
	
	
conti:
	
call le_tecla
ret
menu_cla endp
;--------------------------------------------------------------------------------------------------

;-------------------------------Menu das operações-------------------------------------------------
menu_ope proc
	call limpa_tela
	call guru

;--------------------Apresentar Menu---------------------	
	xor si,si
	mov bx, 1806
	mov al,00000010b;verde
	mov cx,25
ciclo1:
	mov ah,menuSoma[si]
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,menuSubtracao[si]
	mov es:[bx+160],ah
	mov es:[bx+161],al;                                      
	mov ah,menuProdutoE[si]
	mov es:[bx+320],ah
	mov es:[bx+321],al
	mov ah,menuProduto[si]
	mov es:[bx+480],ah
	mov es:[bx+481],al
	mov ah,menuTransposta[si]
	mov es:[bx+640],ah
	mov es:[bx+641],al
	add bx,2
	inc si
	loop ciclo1
;--------------------------------------------------------
;--------------------Escolher operacao-------------------
Teclas:
	mov posy,11
	mov ah,2
	mov bh,0
	mov dh,posy               
	mov dl,21
	int 10h;                      
	
	
ciclo:
	call le_tecla
	
	cmp tecla,0dh
	jne cima
	jmp escolherOpe

cima:	
	cmp tecla,'H'
	jne baixo
	dec posy
	cmp posy,11
	jnb escreve
	mov posy,15;                  VE SE A TECLA E UM ENTER, PARA CIMA OU PARA BAIXO
	jmp escreve
	
baixo:
	cmp tecla,'P'
	jne ciclo
	inc posy
	cmp posy,15
	jng escreve
	mov posy,11
	jmp escreve
	
escreve:    
	mov ah,02h
	mov bh,00h
	mov dh,posy;            ESCREVE O CURSOR CASO A TECLA TANHA SIDO PARA CIMA OU PARA BAIXO
	mov dl,21
	int 10h         
	jmp ciclo
escolherOpe:
	cmp posy, 11
	jne opecao2
	call fazer_soma
opecao2:
	cmp posy, 12
	jne opecao3
	call fazer_sub
opecao3:
	cmp posy, 13
	jne opecao4
	call fazer_produtoE
opecao4:
	cmp posy, 14
	jne opecao5
	;call fazer_produto
opecao5:
	;call fazer_trans

ret	
menu_ope endp
;--------------------------------------------------------------------------------------------------

;---------------------------------------Fazer Soma-------------------------------------------------
fazer_soma proc
inicio111:
	;------------num lin-------
	call limpa_tela
	call guru
	
	xor si,si
	mov bx,2120;13*160=2080 20*2=40 40+2080=2120 linha13 coluna 20
	mov al,00000010b;verde
	mov cx,36
ciclo:
	mov ah,num_lin[si];------->Imprime a mensagem
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop ciclo
	
	mov ah,02h
	mov bh,00h
	mov dh,13;            situar cursor
	mov dl,56
	int 10h 
ciclo1:
	call le_tecla
	cmp tecla, 39h;'9'
	ja ciclo1
	cmp tecla, 31h
	jb ciclo1
	mov ah, tecla
	mov tot_col, ah
 
	call ler_linhas

	
	;------------num col-------
	call limpa_tela
	call guru
	
	xor si,si
	mov bx,2120;13*160=2080 20*2=40 40+2080=2120 linha13 coluna 20
	mov al,00000010b;verde
	mov cx,37
ciclo3:
	mov ah,num_col[si];------->Imprime a mensagem
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop ciclo3
	
	mov ah,02h
	mov bh,00h
	mov dh,13;            situar cursor
	mov dl,57
	int 10h 

ciclo2:
	call le_tecla
	cmp tecla, 39h;'9'
	ja ciclo2
	cmp tecla, 31h
	jb ciclo2
	mov ah, tecla
	mov tot_col, ah

	call ler_colunas
	
	mov al, limx;-------------------verificar se lin e col são iguais
	cmp limy, al
	jne inicio111


	mov count_lin, 30h
	
	mov count_col, 30h
	
	mov count_i, 0

	;------------------------------------Criar tabela--------------------------
	call limpa_tela
	
	xor si,si
	xor bx, bx
	mov aux, 0	
	mov bx,170;1*160=160 5*2=10 10+160=340 linha1 coluna 5		
	mov al,00000010b;verde
	mov cx,37
	ciclotab:
		mov ah,tab[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotab
	mov count_lin, 30h
	add aux, 170
ciclo5:	
	inc count_lin
	add aux, 160
	mov bx,aux
	xor si,si	
	mov al,00000010b;verde
	mov cx,37
	ciclotab2:
		mov ah,tab2[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotab2
	cmp count_lin, 37h
	jne ciclo5
	
	xor si,si	
	mov bx,1450	
	mov al,00000010b;verde
	mov cx,37
	ciclotabFundo:
		mov ah,tab[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotabFundo
	
	xor si,si	
	mov bx,1780	
	mov al,00000010b;verde
	mov cx,34
	ciclomsgenter:
		mov ah,msgEnter[si];------->Imprime Mensagem
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclomsgenter

	mov ah,02h
	mov bh,00h
	mov dh,2;            situar cursor
	mov dl,7
	int 10h

	;-------------------------------------Inicia leitura dos valores da tabela 1---------------------
	mov posy, 2
	mov posx, 7
	mov vectory, 0
	mov vectorx, 0

cicloLervalores:
	call le_tecla	
	
	call calc_pos_array	
	
valoress:
	cmp tecla, 0dh
	je terminar
	cmp tecla, 30h
	jb cicloLervalores
	cmp tecla, 39h
	ja cicloLervalores
	
	;-------------calcular valory-------------
	mov bx, vectory
	mov valory, bx
	
	mov ah, 0
	mov al, limy
	dec al

	cmp valory, ax
	ja cicloLervalores
	;-----------------------------------------
	;-------------calcular valorx-------------
	mov bx, vectorx
	mov valorx, bx
	
	mov ah, 0
	mov al, limx
	dec al
	
	cmp valorx, ax
	ja cicloLervalores
	;-----------------------------------------
	
	;-----------guardar no vector-------------
	xor si, si
	mov ah, 0
	mov al, limx
	mul vectory 
	add ax, vectorx
	mov si, ax
	
	mov ah, tecla
	mov vector[si], ah
	;-----------------------------------------
	;-----------actualizar ecrã---------------
	mov aux, 160
	mov aux2, 2
	
	mov bh, 0
	mov bl, posy	
	mov ax, bx;      calcular a linha
	mul aux
	mov aux, ax
	
	mov bh, 0
	mov bl, posx
	mov ax, bx;      calcular a coluna
	mul aux2
	add aux, ax
	mov bx, aux
	
	mov ah, es:[bx]
	cmp ah, '-'
	jne imprimirTeclaN
	inc count_i
	
imprimirTeclaN:
	mov ah, tecla	
	mov es:[bx],ah;  alterar no ecrã
	mov al,00000010b;verde
	mov es:[bx+1],al
	;-----------------------------------------
	jmp cicloLervalores
	
terminar:
	mov ah, 0
	mov al, limy
	mul limx	
	
	cmp count_i, ax
	jne cicloLervalores	

	;---------------------------------Segunda Tabela---------------------------------------------
	mov count_lin, 0
	mov count_col, 1
	mov bx, 6
ciclo52:                 ;-------------este ciclo inicializa a tabela
	inc count_lin
	add bx,160
	mov count_col, 1
	ciclo53:
		inc count_col
		add bx, 8
		mov ah, '-'
		mov es:[bx],ah;  alterar no ecrã
		mov al,00000010b;verde
		mov es:[bx+1],al		
		cmp count_col, 9
		jne ciclo53
	sub bx, 64
	cmp count_lin, 7
	jne ciclo52
	
	mov ah,02h
	mov bh,00h
	mov dh,2;            situar cursor
	mov dl,7
	int 10h

	mov posy, 2
	mov posx, 7
	mov vectory, 0
	mov vectorx, 0
	mov count_i, 0
cicloLervalores2:
	call le_tecla	
	
	call calc_pos_array	
	
	
valoress2:
	cmp tecla, 0dh
	je terminar2
	cmp tecla, 30h
	jb cicloLervalores2
	cmp tecla, 39h
	ja cicloLervalores2
	
	;-------------calcular valory-------------
	mov bx, vectory
	mov valory, bx
	
	mov ah, 0
	mov al, limy
	dec al
	
	cmp valory, ax
	ja cicloLervalores2
	;-----------------------------------------
	;-------------calcular valorx-------------
	mov bx, vectorx
	mov valorx, bx
	
	mov ah, 0
	mov al, limx
	dec al
	
	cmp valorx, ax
	ja cicloLervalores2
	;-----------------------------------------
	
	;-----------guardar no vector-------------
	xor si, si
	mov ah, 0
	mov al, limx
	mul vectory 
	add ax, vectorx
	mov si, ax
	
	mov ah, tecla
	mov vector_seg[si], ah ;----------> problema a guardar
	
	;-----------------------------------------
	;-----------actualizar ecrã---------------
	mov aux, 160
	mov aux2, 2
	
	mov bh, 0
	mov bl, posy	
	mov ax, bx;      calcular a linha5
	mul aux
	mov aux, ax
	
	mov bh, 0
	mov bl, posx
	mov ax, bx;      calcular a coluna
	mul aux2
	add aux, ax
	mov bx, aux
	
	mov ah, es:[bx]
	cmp ah, '-'
	jne imprimirTeclaN2
	inc count_i
	
imprimirTeclaN2:
	mov ah, tecla	
	mov es:[bx],ah;  alterar no ecrã
	mov al,00000010b;verde
	mov es:[bx+1],al
	;-----------------------------------------
	jmp cicloLervalores2
	
terminar2:
	mov ah, 0
	mov al, limy
	mul limx	
	
	cmp count_i, ax
	jne cicloLervalores2	
	
	call limpa_tela
	
	mov vectory, 0
	mov count_lin, 0
	
	mov bx, 170
cicloCorreY:	
	inc count_lin
	mov vectorx, 0
	mov count_col, 0
	cicloCorreX:		
		xor si, si
		mov ah, 0
		mov al, limx
		mul vectory 
		add ax, vectorx
		mov si, ax
		
		mov al,vector[si]
		add al,vector_seg[si]
		adc ah,0
		mov vectorfinal[si],ax

		inc vectorx
		inc count_col
		mov al, count_col
		cmp limx, al
		jne cicloCorreX
	inc vectory
	mov al, count_lin
	cmp limy, al
	jne cicloCorreY
	
	mov vectory, 0
	mov count_lin, 0
	mov bx, 170
cicloCorreY2:	
	inc count_lin
	mov vectorx, 0
	mov count_col, 0
	cicloCorreX2:		
		xor si, si
		mov ah, 0
		mov al, limx
		mul vectory 
		add ax, vectorx
		mov si, ax
		
		mov ax,vectorfinal[si]
		mov es:[bx],ax;  alterar no ecrã
		mov al,00000010b;verde
		mov es:[bx+1],al
		add bx, 8

		inc vectorx
		inc count_col
		mov al, count_col
		cmp limx, al
		jne cicloCorreX2
	inc vectory
	mov al, count_lin
	cmp limy, al
	jne cicloCorreY2
	
	call le_tecla
ret
fazer_soma endp
;--------------------------------------------------------------------------------------------------

;---------------------------------------Fazer Subtração--------------------------------------------
fazer_sub proc
inicio111:
	;------------num lin-------
	call limpa_tela
	call guru
	
	xor si,si
	mov bx,2120;13*160=2080 20*2=40 40+2080=2120 linha13 coluna 20
	mov al,00000010b;verde
	mov cx,36
ciclo:
	mov ah,num_lin[si];------->Imprime a mensagem
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop ciclo
	
	mov ah,02h
	mov bh,00h
	mov dh,13;            situar cursor
	mov dl,56
	int 10h 
ciclo1:
	call le_tecla
	cmp tecla, 39h;'9'
	ja ciclo1
	cmp tecla, 31h
	jb ciclo1
	mov ah, tecla
	mov tot_col, ah
 
	call ler_linhas

	
	;------------num col-------
	call limpa_tela
	call guru
	
	xor si,si
	mov bx,2120;13*160=2080 20*2=40 40+2080=2120 linha13 coluna 20
	mov al,00000010b;verde
	mov cx,37
ciclo3:
	mov ah,num_col[si];------->Imprime a mensagem
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop ciclo3
	
	mov ah,02h
	mov bh,00h
	mov dh,13;            situar cursor
	mov dl,57
	int 10h 

ciclo2:
	call le_tecla
	cmp tecla, 39h;'9'
	ja ciclo2
	cmp tecla, 31h
	jb ciclo2
	mov ah, tecla
	mov tot_col, ah

	call ler_colunas
	
	mov al, limx;-------------------verificar se lin e col são iguais
	cmp limy, al
	jne inicio111


	mov count_lin, 30h
	
	mov count_col, 30h
	
	mov count_i, 0

	;------------------------------------Criar tabela--------------------------
	call limpa_tela
	
	xor si,si
	xor bx, bx
	mov aux, 0	
	mov bx,170;1*160=160 5*2=10 10+160=340 linha1 coluna 5		
	mov al,00000010b;verde
	mov cx,37
	ciclotab:
		mov ah,tab[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotab
	mov count_lin, 30h
	add aux, 170
ciclo5:	
	inc count_lin
	add aux, 160
	mov bx,aux
	xor si,si	
	mov al,00000010b;verde
	mov cx,37
	ciclotab2:
		mov ah,tab2[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotab2
	cmp count_lin, 37h
	jne ciclo5
	
	xor si,si	
	mov bx,1450	
	mov al,00000010b;verde
	mov cx,37
	ciclotabFundo:
		mov ah,tab[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotabFundo
	
	xor si,si	
	mov bx,1780	
	mov al,00000010b;verde
	mov cx,34
	ciclomsgenter:
		mov ah,msgEnter[si];------->Imprime Mensagem
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclomsgenter

	mov ah,02h
	mov bh,00h
	mov dh,2;            situar cursor
	mov dl,7
	int 10h

	;-------------------------------------Inicia leitura dos valores da tabela 1---------------------
	mov posy, 2
	mov posx, 7
	mov vectory, 0
	mov vectorx, 0

cicloLervalores:
	call le_tecla	
	
	call calc_pos_array	
	
valoress:
	cmp tecla, 0dh
	je terminar
	cmp tecla, 30h
	jb cicloLervalores
	cmp tecla, 39h
	ja cicloLervalores
	
	;-------------calcular valory-------------
	mov bx, vectory
	mov valory, bx
	
	mov ah, 0
	mov al, limy
	dec al

	cmp valory, ax
	ja cicloLervalores
	;-----------------------------------------
	;-------------calcular valorx-------------
	mov bx, vectorx
	mov valorx, bx
	
	mov ah, 0
	mov al, limx
	dec al
	
	cmp valorx, ax
	ja cicloLervalores
	;-----------------------------------------
	
	;-----------guardar no vector-------------
	xor si, si
	mov ah, 0
	mov al, limx
	mul vectory 
	add ax, vectorx
	mov si, ax
	
	mov ah, tecla
	mov vector[si], ah
	;-----------------------------------------
	;-----------actualizar ecrã---------------
	mov aux, 160
	mov aux2, 2
	
	mov bh, 0
	mov bl, posy	
	mov ax, bx;      calcular a linha
	mul aux
	mov aux, ax
	
	mov bh, 0
	mov bl, posx
	mov ax, bx;      calcular a coluna
	mul aux2
	add aux, ax
	mov bx, aux
	
	mov ah, es:[bx]
	cmp ah, '-'
	jne imprimirTeclaN
	inc count_i
	
imprimirTeclaN:
	mov ah, tecla	
	mov es:[bx],ah;  alterar no ecrã
	mov al,00000010b;verde
	mov es:[bx+1],al
	;-----------------------------------------
	jmp cicloLervalores
	
terminar:
	mov ah, 0
	mov al, limy
	mul limx	
	
	cmp count_i, ax
	jne cicloLervalores	

	;---------------------------------Segunda Tabela---------------------------------------------
	mov count_lin, 0
	mov count_col, 1
	mov bx, 6
ciclo52:                 ;-------------este ciclo inicializa a tabela
	inc count_lin
	add bx,160
	mov count_col, 1
	ciclo53:
		inc count_col
		add bx, 8
		mov ah, '-'
		mov es:[bx],ah;  alterar no ecrã
		mov al,00000010b;verde
		mov es:[bx+1],al		
		cmp count_col, 9
		jne ciclo53
	sub bx, 64
	cmp count_lin, 7
	jne ciclo52
	
	mov ah,02h
	mov bh,00h
	mov dh,2;            situar cursor
	mov dl,7
	int 10h

	mov posy, 2
	mov posx, 7
	mov vectory, 0
	mov vectorx, 0
	mov count_i, 0
cicloLervalores2:
	call le_tecla	
	
	call calc_pos_array	
	
	
valoress2:
	cmp tecla, 0dh
	je terminar2
	cmp tecla, 30h
	jb cicloLervalores2
	cmp tecla, 39h
	ja cicloLervalores2
	
	;-------------calcular valory-------------
	mov bx, vectory
	mov valory, bx
	
	mov ah, 0
	mov al, limy
	dec al
	
	cmp valory, ax
	ja cicloLervalores2
	;-----------------------------------------
	;-------------calcular valorx-------------
	mov bx, vectorx
	mov valorx, bx
	
	mov ah, 0
	mov al, limx
	dec al
	
	cmp valorx, ax
	ja cicloLervalores2
	;-----------------------------------------
	
	;-----------guardar no vector-------------
	xor si, si
	mov ah, 0
	mov al, limx
	mul vectory 
	add ax, vectorx
	mov si, ax
	
	mov ah, tecla
	mov vector_seg[si], ah ;----------> problema a guardar
	
	;-----------------------------------------
	;-----------actualizar ecrã---------------
	mov aux, 160
	mov aux2, 2
	
	mov bh, 0
	mov bl, posy	
	mov ax, bx;      calcular a linha5
	mul aux
	mov aux, ax
	
	mov bh, 0
	mov bl, posx
	mov ax, bx;      calcular a coluna
	mul aux2
	add aux, ax
	mov bx, aux
	
	mov ah, es:[bx]
	cmp ah, '-'
	jne imprimirTeclaN2
	inc count_i
	
imprimirTeclaN2:
	mov ah, tecla	
	mov es:[bx],ah;  alterar no ecrã
	mov al,00000010b;verde
	mov es:[bx+1],al
	;-----------------------------------------
	jmp cicloLervalores2
	
terminar2:
	mov ah, 0
	mov al, limy
	mul limx	
	
	cmp count_i, ax
	jne cicloLervalores2	
	
	call limpa_tela
	
	mov vectory, 0
	mov count_lin, 0
	
	mov bx, 170
cicloCorreY:	
	inc count_lin
	mov vectorx, 0
	mov count_col, 0
	cicloCorreX:		
		xor si, si
		mov ah, 0
		mov al, limx
		mul vectory 
		add ax, vectorx
		mov si, ax
		
		mov al,vector[si]
		sub al,vector_seg[si]
		adc ah,0
		mov vectorfinal[si],ax

		inc vectorx
		inc count_col
		mov al, count_col
		cmp limx, al
		jne cicloCorreX
	inc vectory
	mov al, count_lin
	cmp limy, al
	jne cicloCorreY
	
	mov vectory, 0
	mov count_lin, 0
	mov bx, 170
cicloCorreY2:	
	inc count_lin
	mov vectorx, 0
	mov count_col, 0
	cicloCorreX2:		
		xor si, si
		mov ah, 0
		mov al, limx
		mul vectory 
		add ax, vectorx
		mov si, ax
		
		mov ax,vectorfinal[si]
		mov es:[bx],ax;  alterar no ecrã
		mov al,00000010b;verde
		mov es:[bx+1],al
		add bx, 8

		inc vectorx
		inc count_col
		mov al, count_col
		cmp limx, al
		jne cicloCorreX2
	inc vectory
	mov al, count_lin
	cmp limy, al
	jne cicloCorreY2
	
	call le_tecla
ret
fazer_sub endp
;--------------------------------------------------------------------------------------------------

;---------------------------------------Fazer Produto Escalar--------------------------------------
fazer_produtoE proc
inicio111:
	;------------num lin-------
	call limpa_tela
	call guru
	
	xor si,si
	mov bx,2120;13*160=2080 20*2=40 40+2080=2120 linha13 coluna 20
	mov al,00000010b;verde
	mov cx,36
ciclo:
	mov ah,num_lin[si];------->Imprime a mensagem
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop ciclo
	
	mov ah,02h
	mov bh,00h
	mov dh,13;            situar cursor
	mov dl,56
	int 10h 
ciclo1:
	call le_tecla
	cmp tecla, 39h;'9'
	ja ciclo1
	cmp tecla, 31h
	jb ciclo1
	mov ah, tecla
	mov tot_col, ah
 
	call ler_linhas

	
	;------------num col-------
	call limpa_tela
	call guru
	
	xor si,si
	mov bx,2120;13*160=2080 20*2=40 40+2080=2120 linha13 coluna 20
	mov al,00000010b;verde
	mov cx,37
ciclo3:
	mov ah,num_col[si];------->Imprime a mensagem
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop ciclo3
	
	mov ah,02h
	mov bh,00h
	mov dh,13;            situar cursor
	mov dl,57
	int 10h 

ciclo2:
	call le_tecla
	cmp tecla, 39h;'9'
	ja ciclo2
	cmp tecla, 31h
	jb ciclo2
	mov ah, tecla
	mov tot_col, ah

	call ler_colunas
	
	mov al, limx;-------------------verificar se lin e col são iguais
	cmp limy, al
	jne inicio111

	;------------pedir escalar-------
	call limpa_tela
	call guru
	
	xor si,si
	mov bx,2120;13*160=2080 20*2=40 40+2080=2120 linha13 coluna 20
	mov al,00000010b;verde
	mov cx,37
ciclo1000:
	mov ah,pedir_escalar[si];------->Imprime a mensagem
	mov es:[bx],ah
	mov es:[bx+1],al
	add bx,2
	inc si
	loop ciclo1000
	
	mov ah,02h
	mov bh,00h
	mov dh,13;            situar cursor
	mov dl,57
	int 10h 
	call le_tecla
	mov ah, tecla
	mov escalar, ah

	mov count_lin, 30h
	
	mov count_col, 30h
	
	mov count_i, 0

	;------------------------------------Criar tabela--------------------------
	call limpa_tela
	
	xor si,si
	xor bx, bx
	mov aux, 0	
	mov bx,170;1*160=160 5*2=10 10+160=340 linha1 coluna 5		
	mov al,00000010b;verde
	mov cx,37
	ciclotab:
		mov ah,tab[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotab
	mov count_lin, 30h
	add aux, 170
ciclo5:	
	inc count_lin
	add aux, 160
	mov bx,aux
	xor si,si	
	mov al,00000010b;verde
	mov cx,37
	ciclotab2:
		mov ah,tab2[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotab2
	cmp count_lin, 37h
	jne ciclo5
	
	xor si,si	
	mov bx,1450	
	mov al,00000010b;verde
	mov cx,37
	ciclotabFundo:
		mov ah,tab[si];------->Imprime tab
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclotabFundo
	
	xor si,si	
	mov bx,1780	
	mov al,00000010b;verde
	mov cx,34
	ciclomsgenter:
		mov ah,msgEnter[si];------->Imprime Mensagem
		mov es:[bx],ah
		mov es:[bx+1],al
		add bx,2
		inc si
		loop ciclomsgenter

	mov ah,02h
	mov bh,00h
	mov dh,2;            situar cursor
	mov dl,7
	int 10h

	;-------------------------------------Inicia leitura dos valores da tabela 1---------------------
	mov posy, 2
	mov posx, 7
	mov vectory, 0
	mov vectorx, 0

cicloLervalores:
	call le_tecla	
	
	call calc_pos_array	
	
valoress:
	cmp tecla, 0dh
	je terminar
	cmp tecla, 30h
	jb cicloLervalores
	cmp tecla, 39h
	ja cicloLervalores
	
	;-------------calcular valory-------------
	mov bx, vectory
	mov valory, bx
	
	mov ah, 0
	mov al, limy
	dec al

	cmp valory, ax
	ja cicloLervalores
	;-----------------------------------------
	;-------------calcular valorx-------------
	mov bx, vectorx
	mov valorx, bx
	
	mov ah, 0
	mov al, limx
	dec al
	
	cmp valorx, ax
	ja cicloLervalores
	;-----------------------------------------
	
	;-----------guardar no vector-------------
	xor si, si
	mov ah, 0
	mov al, limx
	mul vectory 
	add ax, vectorx
	mov si, ax
	
	mov ah, tecla
	mov vector[si], ah
	;-----------------------------------------
	;-----------actualizar ecrã---------------
	mov aux, 160
	mov aux2, 2
	
	mov bh, 0
	mov bl, posy	
	mov ax, bx;      calcular a linha
	mul aux
	mov aux, ax
	
	mov bh, 0
	mov bl, posx
	mov ax, bx;      calcular a coluna
	mul aux2
	add aux, ax
	mov bx, aux
	
	mov ah, es:[bx]
	cmp ah, '-'
	jne imprimirTeclaN
	inc count_i
	
imprimirTeclaN:
	mov ah, tecla	
	mov es:[bx],ah;  alterar no ecrã
	mov al,00000010b;verde
	mov es:[bx+1],al
	;-----------------------------------------
	jmp cicloLervalores
	
terminar:
	mov ah, 0
	mov al, limy
	mul limx	
	
	cmp count_i, ax
	jne cicloLervalores	
	
	call limpa_tela
	
	mov vectory, 0
	mov count_lin, 0
	
	mov bx, 170
cicloCorreY:	
	inc count_lin
	mov vectorx, 0
	mov count_col, 0
	cicloCorreX:		
		xor si, si
		mov ah, 0
		mov al, limx
		mul vectory 
		add ax, vectorx
		mov si, ax
		
		mov al,vector[si]
		mul escalar
		adc ah,0
		mov vectorfinal[si],ax

		inc vectorx
		inc count_col
		mov al, count_col
		cmp limx, al
		jne cicloCorreX
	inc vectory
	mov al, count_lin
	cmp limy, al
	jne cicloCorreY

	mov vectory, 0
	mov count_lin, 0
	mov bx, 170
cicloCorreY2:	
	inc count_lin
	mov vectorx, 0
	mov count_col, 0
	cicloCorreX2:		
		xor si, si
		mov ah, 0
		mov al, limx
		mul vectory 
		add ax, vectorx
		mov si, ax
		
		mov ax,vectorfinal[si]
		mov es:[bx],ax;  alterar no ecrã
		mov al,00000010b;verde
		mov es:[bx+1],al
		add bx, 8

		inc vectorx
		inc count_col
		mov al, count_col
		cmp limx, al
		jne cicloCorreX2
	inc vectory
	mov al, count_lin
	cmp limy, al
	jne cicloCorreY2
	
	call le_tecla
ret
fazer_produtoE endp
;--------------------------------------------------------------------------------------------------

;-------------------------------FIM DO CODIGO---------------------------------------------------------------------------------------------------------------------------
cseg ends
end main