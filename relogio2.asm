# LEDS
.equ LED  256
.equ LED8 257
.equ LED9 258

# Displays
.equ SECOND_UNIT_DISPLAY 288
.equ SECOND_TEN_DISPLAY  289
.equ MINUTE_UNIT_DISPLAY 290
.equ MINUTE_TEN_DISPLAY  291
.equ HOUR_UNIT_DISPLAY   292
.equ HOUR_TEN_DISPLAY    293

# Buttons
.equ INCREMENT_KEY 352
.equ SETUP_KEY     353
.equ RESET_KEY     354
.equ KEY3          355
.equ FPGA_RESET    356

.equ CLEAR_KEYS    511

# Chaves
.equ LIMIT_SWITH  320
.equ SET_SWITH    321
.equ INVERT_SWITH 322

# Temporizador
.equ READ_TIME            384
.equ SET_TIMER_TO_SECONDS 385
.equ SET_TIMER_TO_FAST    386

.equ CLEAR_TIME           447

# Memory Addresses

# Counters
.equ SECONDS  10
.equ MINUTES  12
.equ HOURS    13

START_SETUP:
    # Reseta os displays
    JMP @RESET

MAIN:
    # Verifica se o botão de incremento foi pressionado e vai para a sub-rotina de incremento
    LOAD @READ_TIME
    ANDI $1
    CEQI $1
    JEQ @UPDATE_COUTER

    # Verifica se o botão de reset foi pressionado e vai para a sub-rotina de reset
    LOAD @RESET_KEY
    ANDI $1
    CEQI $1
    JEQ @RESET

    # Verifica se o botão de setup foi pressionado e vai para a sub-rotina de setup
    LOAD @SETUP_KEY
    ANDI $1
    CEQI $1
    JEQ @START_SETUP

    # Volta para o loop principal, se não pressionou nenhum botão
    JMP @MAIN

RESET:
    # Reseta os botões pressionados
    STORE @CLEAR_KEYS
    
    # Reseta o LED de overflow
    LOADI $0
    STORE @LED
    STORE @LED8
    STORE @LED9

    # Verifica se eSTORE invertido e se sim, reseta o contador para o valor máximo
    LOAD @INVERT_SWITH
    ANDI $1
    CEQI $1
    JEQ @SET_MAX

    # Zera o contador
    LOADI $0
    STORE @SECONDS
    STORE @MINUTES
    STORE @HOURS

    # Reseta o display
    JMP @DISPLAYS

SET_MAX:
    # Configura o contador para o valor máximo
    LOADI $59
    STORE @SECONDS

    LOADI $59
    STORE @MINUTES

    LOADI $23
    STORE @HOURS

    JMP @DISPLAYS

START_SETUP:
    STORE @CLEAR_KEYS
    
    # Liga o LED de setup da unidade
    LOADI $1
    STORE @LED
    LOADI $0
    STORE @LED8
    STORE @LED9

    JMP @SETUP

SETUP:
    # Verifica se o botão de setup foi pressionado
    LOAD @SETUP_KEY
    ANDI $1
    CEQI $1
    JEQ @SETUP_NEXT

    JSR @SETUP_DISPLAYS

    # Fica em loop de setup
    JMP @SETUP

SETUP_NEXT:
    # Limpa os botões pressionados
    STORE @CLEAR_KEYS

    # Verifica se o novo limite é maior que 15
    LOAD @LIMIT_SWITH
    ANDI $240 # (0b11110000)
    CEQI $0
    JEQ @FINISH_SET_UP

    JMP @SETUP

FINISH_SET_UP:
    # Desliga todos os LEDs para indicar que o setup foi finalizado
    LOADI $0
    STORE @LED
    STORE @LED8
    STORE @LED9

    # Reseta a contagem
    JMP @RESET

    # Desvia para atualizar os displays
    JMP @DISPLAYS

UPDATE_COUTER:
    STORE @CLEAR_TIME

    LOAD @INVERT_SWITH
    ANDI $1
    CEQI $1
    JEQ @DECREMENT_SECONDS

    JMP @INCREMENT_SECONDS

INCREMENT_SECONDS:
    # Incrementa a unidade
    LOAD @SECONDS
    ADDI $1

    # Se for maior que 9, incrementa a dezena
    CEQI $60
    JEQ @INCREMENT_MINUTES

    STORE @SECONDS
    JMP @CHECK_FOR_OVERFLOW

INCREMENT_MINUTES:
    # Reseta a unidade
    LOADI $0
    STORE @SECONDS

    # Incrementa a dezena
    LOAD @MINUTES
    ADDI $1

    # Se a dezena for maior que 9, incrementa a centena
    CEQI $60
    JEQ @INCREMENT_HOURS

    STORE @MINUTES
    JMP @CHECK_FOR_OVERFLOW

INCREMENT_HOURS:
    # Reseta a dezena
    LOADI $0
    STORE @MINUTES

    # Incrementa a centena
    LOAD @HOURS
    ADDI $1

    # Se a centena for maior que 9, incrementa o milhar
    CEQI $24
    JEQ @RESET_TIMER

    STORE @HOURS
    JMP @CHECK_FOR_OVERFLOW

RESET_TIMER:
    # Reseta a centena
    LOADI $0
    STORE @HOURS

    JMP @CHECK_FOR_OVERFLOW

CHECK_FOR_OVERFLOW:
    # Se não atingiu nenhum limite, retorna para o loop principal
    JMP @DISPLAYS

UNDERFLOW:
    # Escreve valor minimo
    LOADI $0
    STORE @SECONDS
    STORE @MINUTES
    STORE @HOURS

    # Liga o LED de overflow
    LOADI $255
    STORE @LED
    STORE @LED8
    STORE @LED9

    # Retrorna para a sub-rotina de decremento da unidade
    JMP @DISPLAYS

DECREMENT_SECONDS:
    # Verifica se a unidade é zero e se for, decrementa a próxima casa
    LOAD @SECONDS
    CEQI $0
    JEQ @DECREMENT_MINUTES

    # Decrementa a unidade
    SUBI $1
    STORE @SECONDS
    JMP @DISPLAYS

DECREMENT_MINUTES:
    # Reseta a unidade para o valor máximo
    LOADI $9
    STORE @SECONDS

    # Verifica se a dezena é zero e se for, decrementa a próxima casa
    LOAD @MINUTES
    CEQI $0
    JEQ @DECREMENT_HOURS

    # Decrementa a dezena
    SUBI $1
    STORE @MINUTES
    JMP @DISPLAYS

DECREMENT_HOURS:
    # Reseta a dezena para o valor máximo
    LOADI $9
    STORE @MINUTES

    # Verifica se a centena é zero e se for, decrementa a próxima casa
    LOAD @HOURS
    CEQI $0
    JEQ @UNDERFLOW

    # Decrementa a centena
    SUBI $1
    STORE @HOURS
    JMP @DISPLAYS

SETUP_DISPLAYS:
    # Escreve valor maximo nos displays
    LOADI $9
    STORE @SECOND_UNIT_DISPLAY

    LOADI $5
    STORE @SECOND_TEN_DISPLAY

    LOADI $9
    STORE @MINUTE_UNIT_DISPLAY

    LOADI $5
    STORE @MINUTE_TEN_DISPLAY

    LOADI $3
    STORE @HOUR_UNIT_DISPLAY

    LOADI $2
    STORE @HOUR_TEN_DISPLAY

    RET

DISPLAYS:
    # Escreve os valores nos displays
    JSR @SPLIT_SECONDS
    JSR @SPLIT_MINUTES
    JSR @SPLIT_HOURS

    # Volta para o loop principal
    JMP @MAIN

SPLIT_SECONDS:
    LOAD R0, SECONDS

    CLTI R0, 10
    JLT @END_SECONDS_SPLIT

    ADDI R1, 1
    SUBI R0, 10
    JMP @SPLIT_SECONDS

END_SECONDS_SPLIT:
    STORE R0, SECOND_UNIT_DISPLAY
    STORE R1, SECOND_TEN_DISPLAY
    RET

SPLIT_MINUTES:
    LOAD R0, MINUTES

    CLTI R0, 10
    JLT @END_MINUTES_SPLIT

    ADDI R1, 1
    SUBI R0, 10
    JMP @SPLIT_MINUTES

END_MINUTES_SPLIT:
    STORE R0, MINUTE_UNIT_DISPLAY
    STORE R1, MINUTE_TEN_DISPLAY
    RET

SPLIT_HOURS:
    LOAD R0, HOURS

    CLTI R0, 10
    JLT @END_HOURS_SPLIT

    ADDI R1, 1
    SUBI R0, 10
    JMP @SPLIT_HOURS

END_HOURS_SPLIT:
    STORE R0, HOUR_UNIT_DISPLAY
    STORE R1, HOUR_TEN_DISPLAY
    RET