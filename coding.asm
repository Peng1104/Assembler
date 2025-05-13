# Variaveis de controle do sistema
.equ RESPOSTA                 241

.equ VALOR_NA_CENTENA_DE_MILHAR 0
.equ VALOR_NA_DEZENA_DE_MILHAR  0
.equ VALOR_NO_MILHAR            0
.equ VALOR_NA_CENTENA           1
.equ VALOR_NA_DEZENA            6
.equ VALOR_NA_UNIDADE           0

# Endereço dos perifericos
.equ RESET_KEY                352

.equ UNIT_DISPLAY             288
.equ TEN_DISPLAY              289
.equ HUNDRED_DISPLAY          290
.equ THOUSAND_DISPLAY         291
.equ TEN_THOUSAND_DISPLAY     292
.equ HUNDRED_THOUSAND_DISPLAY 293

# SWITCH
.equ KEY_SWITH  320

RESET:
    # Inicializa o display com 0
    LOADI R0, 0
    STORE R0, UNIT_DISPLAY
    STORE R0, TEN_DISPLAY
    STORE R0, HUNDRED_DISPLAY
    STORE R0, THOUSAND_DISPLAY
    STORE R0, TEN_THOUSAND_DISPLAY
    STORE R0, HUNDRED_THOUSAND_DISPLAY

MAIN_LOOP:
    # Lê o valor do switch
    LOAD @KEY_SWITH

    # Verifica se o valor do switch é igual a primera resposta
    CEQI $RESPOSTA
    JEQ  @END_LOOP

    # Fica em loop ate a resposta ser igual
    JMP  @MAIN_LOOP

END_LOOP:
    JSR @DISPLAYS
    JMP @CHECK_RESET_KEY

# Rotina para verificar se o botão de reset foi precionado
CHECK_RESET_KEY:
    # Verifica se foi precionado
    LOAD @RESET_KEY
    ANDI $1
    CEQI $1

    # Se foi vai para reset
    JEQ @RESET

    # Se não volta para o loop de fim
    JMP @END_LOOP

# Rotina para escrever a resposta nos Displays
DISPLAYS:
    LOADI R1, VALOR_NA_CENTENA_DE_MILHAR
    STORE R1, HUNDRED_THOUSAND_DISPLAY

    LOADI R1, VALOR_NA_DEZENA_DE_MILHAR
    STORE R1, TEN_THOUSAND_DISPLAY

    LOADI R1, VALOR_NO_MILHAR
    STORE R1, THOUSAND_DISPLAY

    LOADI R1, VALOR_NA_CENTENA
    STORE R1, HUNDRED_DISPLAY

    LOADI R1, VALOR_NA_DEZENA
    STORE R1, TEN_DISPLAY

    LOADI R1, VALOR_NA_UNIDADE
    STORE R1, UNIT_DISPLAY

    RET