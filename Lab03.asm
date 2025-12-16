section .data
    numbers times 1024 db 0     ; Массив 1024 байта (512 чисел по 2 байта)
    count_even db 0             ; Количество четных
    count_odd db 0              ; Количество нечетных  
    count_big db 0              ; Количество больших чисел
    count_small db 0            ; Количество маленьких чисел
    
    newline db 10
    space db " "

    before_msg db "Массив ДО выполнения программы:",10
    before_len equ $ - before_msg

    after_msg db "Массив ПОСЛЕ выполнения программы:",10
    after_len equ $ - after_msg

    result_msg db "Результаты распределения:",10
    result_len equ $ - result_msg

    even_msg db "Четные числа: "
    even_len equ $ - even_msg
    odd_msg db "Нечетные числа: "
    odd_len equ $ - odd_msg
    high_msg db "Числа >= 50000: "
    high_len equ $ - high_msg
    low_msg db "Числа < 10000: "
    low_len equ $ - low_msg
   
    separator db "-------------------",10
    separator_len equ $ - separator

    elements_per_line db 16     ; Количество элементов в строке

section .bss
    seed resd 1
    num_buf resb 12

section .text
    global _start

_start:
    ; Выводим массив ДО выполнения программы
    mov eax, 4
    mov ebx, 1
    mov ecx, before_msg
    mov edx, before_len
    int 0x80
    
    call print_array_full
    call print_newline
    
    ; Инициализация генератора случайных чисел через системное время
    mov eax, 13
    xor ebx, ebx
    int 0x80
    mov [seed], eax

generate_numbers:
    ; Генерация псевдослучайного числа
    mov eax, [seed]
    mov ecx, 1103515245
    mul ecx
    add eax, 12345
    mov [seed], eax
    and eax, 0FFFFh
    
    ; Сохраняем сгенерированное число
    mov [seed], ax
    
    ; Восстанавливаем число
    mov ax, [seed]
    
    ; Проверяем условия и распределяем числа
    test ax, 1
    jnz not_even
    
    ; Четное число
    movzx ecx, byte [count_even]
    mov [numbers + ecx*2], ax
    inc byte [count_even]
    jmp check_high_low
    
not_even:
    ; Нечетное число
    movzx ecx, byte [count_odd]
    mov [numbers + 256 + ecx*2], ax
    inc byte [count_odd]
    
check_high_low:
    ; Проверка на число >= 50000
    cmp ax, 50000
    jb check_low
    
    ; Число >= 50000
    movzx ecx, byte [count_big]
    mov [numbers + 512 + ecx*2], ax
    inc byte [count_big]
    jmp check_continue
    
check_low:
    ; Проверка на число < 10000
    cmp ax, 10000
    jae check_continue
    
    ; Число < 10000
    movzx ecx, byte [count_small]
    mov [numbers + 768 + ecx*2], ax
    inc byte [count_small]
    
check_continue:
    ; Проверяем, не превысил ли какой-либо счетчик 127
    cmp byte [count_even], 127
    ja finish
    cmp byte [count_odd], 127  
    ja finish
    cmp byte [count_big], 127
    ja finish
    cmp byte [count_small], 127
    ja finish
    
    jmp generate_numbers
    
finish:
    ; Вывод массива ПОСЛЕ выполнения программы
    mov eax, 4
    mov ebx, 1
    mov ecx, after_msg
    mov edx, after_len
    int 0x80
    
    call print_array_with_separators
    call print_newline
    
    ; Вывод результатов
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, result_len
    int 0x80
    
    ; Вывод количества четных чисел
    mov eax, 4
    mov ebx, 1
    mov ecx, even_msg
    mov edx, even_len
    int 0x80
    movzx eax, byte [count_even]
    call print_number
    call print_newline
    
    ; Вывод количества нечетных чисел
    mov eax, 4
    mov ebx, 1
    mov ecx, odd_msg
    mov edx, odd_len
    int 0x80
    movzx eax, byte [count_odd]
    call print_number
    call print_newline
    
    ; Вывод количества чисел >= 50000
    mov eax, 4
    mov ebx, 1
    mov ecx, high_msg
    mov edx, high_len
    int 0x80
    movzx eax, byte [count_big]
    call print_number
    call print_newline
    
    ; Вывод количества чисел < 10000
    mov eax, 4
    mov ebx, 1
    mov ecx, low_msg
    mov edx, low_len
    int 0x80
    movzx eax, byte [count_small]
    call print_number
    call print_newline
    
    ; Завершение программы
    mov eax, 1
    xor ebx, ebx
    int 0x80

; ===========================
; Печать всего массива с разделителями между категориями
print_array_with_separators:
    ; Вывод четных чисел
    mov eax, 4
    mov ebx, 1
    mov ecx, even_msg
    mov edx, even_len
    int 0x80
    call print_newline
   
    mov esi, numbers       ; Начало раздела четных
    movzx ecx, byte [count_even]  ; Кол-во элементов
    call print_section
    call print_separator

    ; Вывод нечетных чисел
    mov eax, 4
    mov ebx, 1
    mov ecx, odd_msg
    mov edx, odd_len
    int 0x80
    call print_newline
   
    mov esi, numbers
    add esi, 256           ; смещение для нечетных
    movzx ecx, byte [count_odd]
    call print_section
    call print_separator

    ; Вывод чисел >= 50000
    mov eax, 4
    mov ebx, 1
    mov ecx, high_msg
    mov edx, high_len
    int 0x80
    call print_newline
   
    mov esi, numbers
    add esi, 512           ; смещение для >= 50000
    movzx ecx, byte [count_big]
    call print_section
    call print_separator

    ; Вывод чисел < 10000
    mov eax, 4
    mov ebx, 1
    mov ecx, low_msg
    mov edx, low_len
    int 0x80
    call print_newline
   
    mov esi, numbers
    add esi, 768           ; смещение для чисел < 10000
    movzx ecx, byte [count_small]
    call print_section
   
    ret

; Печать секции массива
print_section:
    test ecx, ecx
    jz .end
   
    xor ebx, ebx           ; счетчик элементов в строке

.print_loop:
    ; Печатаем число
    mov ax, [esi]
    call print_number
   
    ; Печатаем пробел после числа
    call print_space
   
    ; Переходим к следующему элементу
    add esi, 2
    inc ebx
   
    ; Проверяем, нужно ли переходить на новую строку
    cmp ebx, [elements_per_line]
    jl .same_line
   
    ; Переход на новую строку
    call print_newline
    xor ebx, ebx

.same_line:
    loop .print_loop
   
    ; Если последняя строка была неполной, добавляем перевод строки
    cmp ebx, 0
    je .end
    call print_newline
   
.end:
    ret

; Печать разделителя
print_separator:
    push eax
    push ebx
    push ecx
    push edx
    mov eax, 4
    mov ebx, 1
    mov ecx, separator
    mov edx, separator_len
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; ===========================
; Печать всего массива (для начального вывода)
print_array_full:
    mov esi, numbers
    mov ecx, 512
    xor ebx, ebx
    
.print_loop:
    mov ax, [esi]
    call print_number
    call print_space
    
    add esi, 2
    inc ebx
    cmp ebx, [elements_per_line]
    jl .same_line
    
    call print_newline
    xor ebx, 0
    
.same_line:
    loop .print_loop
    
    cmp ebx, 0
    je .done
    call print_newline
    
.done:
    ret

; Функция для вывода числа в AX
print_number:
    push eax
    push ebx
    push ecx
    push edx
    push edi
    
    mov edi, num_buf + 11
    mov byte [edi], 0
    mov ecx, 10
    movzx eax, ax
    
.convert_loop:
    dec edi
    xor edx, edx
    div ecx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz .convert_loop
    
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, num_buf + 12
    sub edx, ecx
    int 0x80
    
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Функция для вывода пробела
print_space:
    push eax
    push ebx
    push ecx
    push edx
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Функция для вывода новой строки
print_newline:
    push eax
    push ebx
    push ecx
    push edx
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
