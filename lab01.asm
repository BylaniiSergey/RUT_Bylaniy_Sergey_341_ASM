section .text
global _start
_start:

     ;пункты с 1 по 6
mov esi, 0xF0769D1A   ;  1 число в еsi
mov edi, 0x1769B22E   ;  2 число в edi
mov ax,  0x8916   ;  3 число в ax
mov bx,  0x2E23   ;  4 число в bx
mov ch,  0x89   ;  5 число в ch
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

lea edx, [esi]   ;  4 способ через lea
mov esi, edi
lea edi, [edx]

     ;пункт 8 (перестановка 3-го и 4-го числа)
mov dx, ax    ;  1 способ через mov
mov ax, bx
mov bx, dx

push ax    ;  2 способ через стэк
push bx
pop ax
pop bx

xchg ax, bx    ;  3 способ через xchg 

lea edx, [eax]   ;  4 способ через lea
mov ax, bx
lea ebx, [edx]
 
     ;пункт 9 (перестановка 5-го и 6-го числа)
shl eax, 16    ; разгружаем регистр ebx путем переноса числа ax в старшие 16 бит eax
mov ax, bx
mov bl, ch

mov dl, bl    ; 1 способ через mov
mov bl, cl
mov cl, dl

push ebx    ; 2 способ через стэк
push ecx
pop ebx
pop ecx

xchg bx, cx    ; 3 способ через xchg

lea edx, [ebx]   ; 4 способ через lea
mov bx, cx
lea ecx, [edx]

     ;пункт 10 (запись 3 и 4 числа в 16 битные РОН)
mov ch, bl
mov bx, ax
shr eax, 16

mov dx, bx
mov bx, ax

     ;пункт 11 (запись 3 и 4 числа в 32 битные РОН)
movzx eax, dx
movzx edx, bx 


mov eax, 1
xor ebx, ebx 
int 0x80
