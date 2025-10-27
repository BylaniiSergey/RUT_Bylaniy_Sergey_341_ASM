section .data
buffer db 10 dup(0)     ; буфер для строки
newline db 0xA          ; символ новой строки

section .text
global _start
_start:

; вносим числа в регистры
mov ecx, 0x56A735 ; число a
mov edi, 0x679794 ; число b
mov esi, 0x7864CB ; число c
mov edx, 0x87D272 ; число d

; высчитываем числитель
add  esi, esi ;    умножение на 2 = esi + esi

; d/3
mov eax, edx 
mov ebx, 0x3 ; вносим делитель - 3
push edx  ; переносим d в стэк, что бы не потерять его
mov edx, 0  ; очищаем регистр для остатка
div ebx  ; число после d/3 лежит в eax, остаток сохранили в edx
pop ebx  ; достаем d из стэка   


; 2*с - d/3
sub esi, eax ; расчитанный числитель находится в esi

; высчитываем знаменатель
; a/4
mov eax, ecx
mov ebx, 0x4
mov edx, 0
div ebx

; b - a/4
sub edi, eax; расчитанный знаменатель находится в edi


; финальное деление ч/з
mov eax, esi
mov ebx, edi
mov edx, 0
div ebx

; результат деления в eax
; целочисленный остаток в edx

push eax        ; сохраняем результат в стек

; Преобразование числа в строку
mov ebx, 10     ; основание системы
lea ecx, [buffer + 9]  ; указатель на конец буфера
mov byte [ecx], 0      ; завершающий нуль

convert_loop:
    dec ecx             ; двигаемся назад по буферу
    xor edx, edx        ; обнуляем edx для деления
    div ebx             ; делим eax на 10
    add dl, '0'         ; преобразуем цифру в символ
    mov [ecx], dl       ; сохраняем символ
    test eax, eax       ; проверяем, осталось ли число
    jnz convert_loop    ; если да, продолжаем

; Вывод строки
mov eax, 4              ; sys_write
mov ebx, 1              ; stdout
mov edx, buffer + 10    ; конец буфера
sub edx, ecx            ; вычисляем длину строки
int 0x80

; Вывод символа новой строки
mov eax, 4
mov ebx, 1
mov ecx, newline
mov edx, 1
int 0x80

pop eax         ; восстанавливаем результат

; Завершение программы
mov eax, 1
xor ebx, ebx 
int 0x80
