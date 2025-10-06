section .bss
buf_1 resd 1
buf_2 resq 1
buf_3 resw 1
section .text
global _start
_start:

     ;пункты с 1 по 6
mov esi, 0xF0769D1A   ;  1 число в еsi
mov edi, 0x1769B22E   ;  2 число в edi
mov ax,  0x8916   ;  3 число в ax
mov bx,  0x2E23   ;  4 число в bx
mov ch,  0x89   ;  5 число в dl
mov cl,  0x7   ;  6 число в cl
     ; регристр edx - пустой
     
     ;пункт 7 (перестановка 1-го и 2-го числа)
mov edx, esi   ;  1 способ через mov
mov esi, edi
mov edi, edx

push esi    ;  2 способ через стэк
push edi
pop esi
pop edi

xchg esi, edi   ;  3 способ через xchg

lea edx, buf_1   ;  4 способ через lea
mov [edx], edi
mov edi, esi
mov esi, dword [edx]

     ;пункт 8 (перестановка 3-го и 4-го числа)
mov dx, ax    ;  1 способ через mov
mov ax, bx
mov bx, dx

push ax    ;  2 способ через стэк
push bx
pop ax
pop bx

xchg ax, bx    ;  3 способ через xchg 

lea edx, buf_2   ;  4 способ через lea
mov [edx], bx
mov bx, ax
mov ax, word [edx]

 
     ;пункт 9 (перестановка 5-го и 6-го числа)
     
mov dl, bl    ; 1 способ через mov
mov bl, cl
mov cl, dl

push edx    ; 2 способ через стэк
push ecx
pop edx
pop ecx

xchg dl, cl    ; 3 способ через xchg

lea edx, buf_3   ;  4 способ через lea
mov [edx], dl
mov dl, cl
mov cl, byte [edx]

     ;пункт 10 (запись 3 и 4 числа в 16 битные РОН)
movsx ax, bl  
movsx cx, al
     ;пункт 11 (запись 3 и 4 числа в 32 битные РОН)
movzx eax, dx
movzx edx, bx 


mov eax, 1
xor ebx, ebx 
int 0x80
 
 

