# LEDS
.equ LED  256
.equ LED8 257
.equ LED9 258

# Displays
.equ UNIT_DISPLAY             288
.equ TEN_DISPLAY              289
.equ HUNDRED_DISPLAY          290
.equ THOUSAND_DISPLAY         291
.equ TEN_THOUSAND_DISPLAY     292
.equ HUNDRED_THOUSAND_DISPLAY 293

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

# Memory Addresses

# Counters
.equ UNIT             10
.equ TEN              11
.equ HUNDRED          12
.equ THOUSAND         13
.equ TEN_THOUSAND     14
.equ HUNDRED_THOUSAND 15

# LIMITE
.equ MAX_UNIT             21
.equ MAX_TEN              22
.equ MAX_HUNDRED          23
.equ MAX_THOUSAND         24
.equ MAX_TEN_THOUSAND     25
.equ MAX_HUNDRED_THOUSAND 26

# LOOKUP TABLES
.equ ACTIVE_SETUP            30
.equ UNIT_LOOKUP             31
.equ TEN_LOOKUP              32
.equ HUNDRED_LOOKUP          33
.equ THOUSAND_LOOKUP         34
.equ TEN_THOUSAND_LOOKUP     35
.equ HUNDRED_THOUSAND_LOOKUP 36

# Flags
.equ FLAG_LIMIT_REACHED   40

STORERT_SETUP:
    # Inicializa os LIMITES dos displays
    LOADI $9
    STORE @MAX_UNIT
    STORE @MAX_TEN
    STORE @MAX_HUNDRED
    STORE @MAX_THOUSAND
    STORE @MAX_TEN_THOUSAND
    STORE @MAX_HUNDRED_THOUSAND

    # Inicializa os valores da lookup table
    LOADI $1
    STORE @UNIT_LOOKUP
    LOADI $3
    STORE @TEN_LOOKUP
    LOADI $7
    STORE @HUNDRED_LOOKUP
    LOADI $15
    STORE @THOUSAND_LOOKUP
    LOADI $31
    STORE @TEN_THOUSAND_LOOKUP
    LOADI $63
    STORE @HUNDRED_THOUSAND_LOOKUP

    # Reseta os displays
    JMP @RESET

MAIN:
    # Verifica se o botão de incremento foi pressionado e vai para a sub-rotina de incremento
    LOAD @INCREMENT_KEY
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
    JEQ @STORERT_SETUP

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

    # Reseta a flag de limite atingido
    STORE @FLAG_LIMIT_REACHED

    # Verifica se eSTORE invertido e se sim, reseta o contador para o valor máximo
    LOAD @INVERT_SWITH
    ANDI $1
    CEQI $1
    JEQ @SET_MAX

    # Zera o contador
    LOADI $0
    STORE @UNIT
    STORE @TEN
    STORE @HUNDRED
    STORE @THOUSAND
    STORE @TEN_THOUSAND
    STORE @HUNDRED_THOUSAND

    # Reseta o display
    JMP @DISPLAYS

SET_MAX:
    # Configura o contador para o valor máximo
    LOAD @MAX_UNIT
    STORE @UNIT

    LOAD @MAX_TEN
    STORE @TEN

    LOAD @MAX_HUNDRED
    STORE @HUNDRED

    LOAD @MAX_THOUSAND
    STORE @THOUSAND

    LOAD @MAX_TEN_THOUSAND
    STORE @TEN_THOUSAND

    LOAD @MAX_HUNDRED_THOUSAND
    STORE @HUNDRED_THOUSAND

    JMP @DISPLAYS

STORERT_SETUP:
    STORE @CLEAR_KEYS
    
    LOADI $1
    STORE @ACTIVE_SETUP

    # Liga o LED de setup da unidade
    LOAD @UNIT_LOOKUP
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
    JEQ @CONTINUE_SETUP

    JMP @SETUP

CONTINUE_SETUP:
    # Verifica se está configurando a unidade
    LOAD @ACTIVE_SETUP
    CEQI $1
    JEQ @SET_UNIT_LIMIT

    # Verifica se está configurando a dezena
    CEQI $2
    JEQ @SET_TEN_LIMIT

    # Verifica se está configurando a centena
    CEQI $3
    JEQ @SET_HUNDRED_LIMIT

    # Verifica se está configurando o milhar
    CEQI $4
    JEQ @SET_THOUSAND_LIMIT

    # Verifica se está configurando a dezena de milhar
    CEQI $5
    JEQ @SET_TEN_THOUSAND_LIMIT

    # Verifica se está configurando a centena de milhar
    CEQI $6
    JEQ @SET_HUNDRED_THOUSAND_LIMIT

INCREMENT_SETUP:
    # Passa para o próximo setup
    LOAD @ACTIVE_SETUP
    ADDI $1
    STORE @ACTIVE_SETUP

    # Verifica se o setup chegou ao fim
    CEQI $7
    JEQ @FINISH_SET_UP    

    # Volta para o loop de setup
    JMP @SETUP

SET_UNIT_LIMIT:
    # Aplica o novo limite na unidade
    LOAD @LIMIT_SWITH
    STORE @MAX_UNIT

    # Liga o LED de setup da dezena
    LOAD @TEN_LOOKUP
    STORE @LED
    JMP @INCREMENT_SETUP

SET_TEN_LIMIT:
    # Aplica o novo limite na dezena
    LOAD @LIMIT_SWITH
    STORE @MAX_TEN

    # Liga o LED de setup da centena
    LOAD @HUNDRED_LOOKUP
    STORE @LED
    JMP @INCREMENT_SETUP

SET_HUNDRED_LIMIT:
    # Aplica o novo limite na centena
    LOAD @LIMIT_SWITH
    STORE @MAX_HUNDRED

    # Liga o LED de setup do milhar
    LOAD @THOUSAND_LOOKUP
    STORE @LED
    JMP @INCREMENT_SETUP

SET_THOUSAND_LIMIT:
    # Aplica o novo limite no milhar
    LOAD @LIMIT_SWITH
    STORE @MAX_THOUSAND

    # Liga o LED de setup da dezena de milhar
    LOAD @TEN_THOUSAND_LOOKUP
    STORE @LED
    JMP @INCREMENT_SETUP

SET_TEN_THOUSAND_LIMIT:
    # Aplica o novo limite na dezena de milhar
    LOAD @LIMIT_SWITH
    STORE @MAX_TEN_THOUSAND

    # Liga o LED de setup da centena de milhar
    LOAD @HUNDRED_THOUSAND_LOOKUP
    STORE @LED
    JMP @INCREMENT_SETUP

SET_HUNDRED_THOUSAND_LIMIT:
    # Aplica o novo limite na centena de milhar
    LOAD @LIMIT_SWITH
    STORE @MAX_HUNDRED_THOUSAND
    JMP @FINISH_SET_UP

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
    STORE @CLEAR_KEYS

    # Verifica se a flag de limite atingido foi ativada
    LOAD @FLAG_LIMIT_REACHED
    CEQI $1
    JEQ @MAIN

    LOAD @INVERT_SWITH
    ANDI $1
    CEQI $1
    JEQ @DECREMENT_UNIT

    JMP @INCREMENT_UNIT

INCREMENT_UNIT:
    # Incrementa a unidade
    LOAD @UNIT
    ADDI $1

    # Se for maior que 9, incrementa a dezena
    CEQI $10
    JEQ @INCREMENT_TEN

    STORE @UNIT
    JMP @CHECK_FOR_OVERFLOW

INCREMENT_TEN:
    # Reseta a unidade
    LOADI $0
    STORE @UNIT

    # Incrementa a dezena
    LOAD @TEN
    ADDI $1

    # Se a dezena for maior que 9, incrementa a centena
    CEQI $10
    JEQ @INCREMENT_HUNDRED

    STORE @TEN
    JMP @CHECK_FOR_OVERFLOW

INCREMENT_HUNDRED:
    # Reseta a dezena
    LOADI $0
    STORE @TEN

    # Incrementa a centena
    LOAD @HUNDRED
    ADDI $1

    # Se a centena for maior que 9, incrementa o milhar
    CEQI $10
    JEQ @INCREMENT_THOUSAND

    STORE @HUNDRED
    JMP @CHECK_FOR_OVERFLOW

INCREMENT_THOUSAND:
    # Reseta a centena
    LOADI $0
    STORE @HUNDRED

    # Incrementa o milhar
    LOAD @THOUSAND
    ADDI $1

    # Se o milhar for maior que 9, incrementa a dezena de milhar
    CEQI $10
    JEQ @INCREMENT_TEN_THOUSAND

    STORE @THOUSAND
    JMP @CHECK_FOR_OVERFLOW

INCREMENT_TEN_THOUSAND:
    # Reseta o milhar
    LOADI $0
    STORE @THOUSAND

    # Incrementa a dezena de milhar
    LOAD @TEN_THOUSAND
    ADDI $1

    # Se a dezena de milhar for maior que 9, incrementa a centena de milhar
    CEQI $10
    JEQ @INCREMENT_HUNDRED_THOUSAND

    STORE @TEN_THOUSAND
    JMP @CHECK_FOR_OVERFLOW

INCREMENT_HUNDRED_THOUSAND:
    # Reseta a dezena de milhar
    LOADI $0
    STORE @TEN_THOUSAND

    # Incrementa a centena de milhar
    LOAD @HUNDRED_THOUSAND
    ADDI $1

    # Se a centena de milhar for maior que 9, chama o overflow
    CEQI $10
    JEQ @OVERFLOW

    STORE @HUNDRED_THOUSAND
    JMP @DISPLAYS

CHECK_FOR_OVERFLOW:
    # Verifica se a centena de milhar atingiu o limite
    LOAD @HUNDRED_THOUSAND
    CEQ @MAX_HUNDRED_THOUSAND
    JEQ @TEN_THOUSAND_CHECK

    # Se não atingiu nenhum limite, retorna para o loop principal
    JMP @DISPLAYS

TEN_THOUSAND_CHECK:
    # Verifica se a dezena de milhar atingiu o limite
    LOAD @TEN_THOUSAND
    CEQ @MAX_TEN_THOUSAND
    JEQ @THOUSAND_CHECK

    # Se não atingiu nenhum limite, retorna para o loop principal
    JMP @DISPLAYS

THOUSAND_CHECK:
    # Verifica se o milhar atingiu o limite
    LOAD @THOUSAND
    CEQ @MAX_THOUSAND
    JEQ @HUNDRED_CHECK

    # Se não atingiu nenhum limite, retorna para o loop principal
    JMP @DISPLAYS

HUNDRED_CHECK:
    # Verifica se a centena atingiu o limite
    LOAD @HUNDRED
    CEQ @MAX_HUNDRED
    JEQ @TEN_CHECK

    # Se não atingiu nenhum limite, retorna para o loop principal
    JMP @DISPLAYS

TEN_CHECK:
    # Verifica se a dezena atingiu o limite
    LOAD @TEN
    CEQ @MAX_TEN
    JEQ @UNIT_CHECK

    # Se não atingiu nenhum limite, retorna para o loop principal
    JMP @DISPLAYS

UNIT_CHECK:
    # Verifica se a unidade atingiu o limite
    LOAD @UNIT
    CEQ @MAX_UNIT
    JEQ @OVERFLOW

    # Se não atingiu nenhum limite, retorna para o loop principal
    JMP @DISPLAYS

OVERFLOW:
    # Ativa a flag de limite atingido
    LOADI $1
    STORE @FLAG_LIMIT_REACHED

    # Liga o LED de overflow
    LOADI $255
    STORE @LED
    STORE @LED8
    STORE @LED9

    JMP @SET_MAX

UNDERFLOW:
    # Escreve valor minimo
    LOADI $0
    STORE @UNIT
    STORE @TEN
    STORE @HUNDRED
    STORE @THOUSAND
    STORE @TEN_THOUSAND
    STORE @HUNDRED_THOUSAND

    # Ativa a flag de limite atingido
    LOADI $1
    STORE @FLAG_LIMIT_REACHED

    # Liga o LED de overflow
    LOADI $255
    STORE @LED
    STORE @LED8
    STORE @LED9

    # Retrorna para a sub-rotina de decremento da unidade
    JMP @DISPLAYS

DECREMENT_UNIT:
    # Verifica se a unidade é zero e se for, decrementa a próxima casa
    LOAD @UNIT
    CEQI $0
    JEQ @DECREMENT_TEN

    # Decrementa a unidade
    SUBI $1
    STORE @UNIT
    JMP @DISPLAYS

DECREMENT_TEN:
    # Reseta a unidade para o valor máximo
    LOADI $9
    STORE @UNIT

    # Verifica se a dezena é zero e se for, decrementa a próxima casa
    LOAD @TEN
    CEQI $0
    JEQ @DECREMENT_HUNDRED

    # Decrementa a dezena
    SUBI $1
    STORE @TEN
    JMP @DISPLAYS

DECREMENT_HUNDRED:
    # Reseta a dezena para o valor máximo
    LOADI $9
    STORE @TEN

    # Verifica se a centena é zero e se for, decrementa a próxima casa
    LOAD @HUNDRED
    CEQI $0
    JEQ @DECREMENT_THOUSAND

    # Decrementa a centena
    SUBI $1
    STORE @HUNDRED
    JMP @DISPLAYS

DECREMENT_THOUSAND:
    # Reseta a centena para o valor máximo
    LOADI $9
    STORE @HUNDRED

    # Verifica se o milhar é zero e se for, decrementa a próxima casa
    LOAD @THOUSAND
    CEQI $0
    JEQ @DECREMENT_TEN_THOUSAND

    # Decrementa o milhar
    SUBI $1
    STORE @THOUSAND
    JMP @DISPLAYS

DECREMENT_TEN_THOUSAND:
    # Reseta o milhar para o valor máximo
    LOADI $9
    STORE @THOUSAND

    # Verifica se a dezena de milhar é zero e se for, decrementa a próxima casa
    LOAD @TEN_THOUSAND
    CEQI $0
    JEQ @DECREMENT_HUNDRED_THOUSAND

    # Decrementa a dezena de milhar
    SUBI $1
    STORE @TEN_THOUSAND
    JMP @DISPLAYS

DECREMENT_HUNDRED_THOUSAND:
    # Reseta a dezena de milhar para o valor máximo
    LOADI $9
    STORE @TEN_THOUSAND

    # Verifica se a centena de milhar é zero e se for, chama o underflow
    LOAD @HUNDRED_THOUSAND
    CEQI $0
    JEQ @UNDERFLOW

    # Decrementa a centena de milhar
    SUBI $1
    STORE @HUNDRED_THOUSAND
    JMP @DISPLAYS

SETUP_DISPLAYS:
    # Escreve valor maximo nos displays
    LOAD @MAX_UNIT
    STORE @UNIT_DISPLAY

    LOAD @MAX_TEN
    STORE @TEN_DISPLAY

    LOAD @MAX_HUNDRED
    STORE @HUNDRED_DISPLAY

    LOAD @MAX_THOUSAND
    STORE @THOUSAND_DISPLAY

    LOAD @MAX_TEN_THOUSAND
    STORE @TEN_THOUSAND_DISPLAY

    LOAD @MAX_HUNDRED_THOUSAND
    STORE @HUNDRED_THOUSAND_DISPLAY

    RET

DISPLAYS:
    # Escreve os valores nos displays
    LOAD @UNIT
    STORE @UNIT_DISPLAY

    LOAD @TEN
    STORE @TEN_DISPLAY

    LOAD @HUNDRED
    STORE @HUNDRED_DISPLAY

    LOAD @THOUSAND
    STORE @THOUSAND_DISPLAY

    LOAD @TEN_THOUSAND
    STORE @TEN_THOUSAND_DISPLAY

    LOAD @HUNDRED_THOUSAND
    STORE @HUNDRED_THOUSAND_DISPLAY

    # Volta para o loop principal
    JMP @MAIN