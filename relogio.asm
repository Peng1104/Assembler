# LEDS
.equ LED0to7 256
.equ AM_LED  257
.equ PM_LED  258

# Displays
.equ UNIT_SECOND_DISPLAY 288
.equ TEN_SECOND_DISPLAY  289
.equ UNIT_MINUTE_DISPLAY 290
.equ TEN_MINUTE_DISPLAY  291
.equ UNIT_HOUR_DISPLAY   292
.equ TEN_HOUR_DISPLAY    293

# Chaves
.equ SETUP_SWITH  320
.equ SWITH8       321
.equ SWITH9       322

# Botoes
.equ SETUP_KEY          352
.equ AM_OR_24_KEY       353
.equ TIMER_KEY          354
.equ KEY_3              355
.equ KEY_4              356

.equ CLEAR_KEYS         511

# Temporizador
.equ READ_TIME            384
.equ SET_TIMER_TO_SECONDS 385
.equ SET_TIMER_TO_FAST    386

.equ CLEAR_TIME           447

# Memory Addresses

# Variaveis do tempo
.equ secondsVar   0
.equ minutesVar   1
.equ hoursVar     2

# Flags de software

# 0 = 24h mode, 1 = 12h mode
.equ modeFlag     10
# 0 = normal, 1 = fast
.equ speedFlag    11

START:
    LOADI R0, 0

    # Inicializa as variaveis de tempo
    STORE R0, secondsVar
    STORE R0, minutesVar
    STORE R0, hoursVar

    # Define flags como false
    STORE R0, modeFlag
    STORE R0, speedFlag

    # Define o timer como 1 segundo
    STORE @SET_TIMER_TO_SECONDS

    # Limpa o temporizador
    STORE @CLEAR_TIME

    LOADI R1, 1
    STORE R1, LED0to7

WAIT_TICK:
    # Verifica se o botão de setup foi pressionado
    JSR   @HANDLE_INPUTS

    # Limpa os botões pressionados
    STORE @CLEAR_KEYS

    # Atualiza o display
    JSR   @UPDATE_DISPLAY

    # Fica em loop até passo 1 unidade de tempo
    LOAD  R0, READ_TIME
    ANDI  R0, 1
    CEQI  R0, 0

    # Unidade de tempo não passou, volta para o loop
    JEQ   @WAIT_TICK
    
    # Chama as sub-rotinas para atualizar o tempo
    STORE @CLEAR_TIME
    JSR   @INCREMENTA_TEMPO

    # Volta para o loop principal
    JMP   @WAIT_TICK

# ==============================================================================
#                               ROTINAS DE TEMPO
# ==============================================================================

INCREMENTA_TEMPO:
    # Incrementa os segundos
    LOAD  R3, secondsVar
    ADDI  R3, 1

    # Verifca se é menor que 60 segundos
    CLTI  R3, 60
    JLT@SALVA_SEGUNDOS

    # Se não, incrementa os minutos
    LOADI R0, 0
    STORE R0, secondsVar
    JSR@INCREMENTA_MINUTOS
    RET

SALVA_SEGUNDOS:
    STORE R3, secondsVar
    RET

INCREMENTA_MINUTOS:
    # Incrementa os minutos
    LOAD  R3, minutesVar
    ADDI  R3, 1

    # Verifica se é menor que 60 minutos
    CLTI  R3, 60
    JLT@SALVA_MINUTOS

    # Se não, incrementa as horas
    LOADI R3, 0
    STORE R3, minutesVar
    JSR@INCREMENTA_HORAS
    RET

SALVA_MINUTOS:
    STORE R3, minutesVar
    RET

INCREMENTA_HORAS:
    # Incrementa as horas
    LOAD  R3, hoursVar
    ADDI  R3, 1

    # Verifica se é menor que 24 horas
    CLTI  R3, 24
    JLT@SALVA_HORA

    # Se não, volta para 0 horas
    LOADI R3, 0
    STORE R3, hoursVar
    RET                              

SALVA_HORA:
    STORE R3, hoursVar
    RET

# ==============================================================================
#                              ROTINAS DE DISPLAY
# ==============================================================================

UPDATE_DISPLAY:
    JSR@DISPLAY_SECONDS
    JSR@DISPLAY_MINUTES
    JSR@DISPLAY_HOURS
    RET

DISPLAY_SECONDS:
    LOAD  R0, secondsVar
    LOADI R1, 0

    JSR@SPLIT_SEC
    RET

DISPLAY_MINUTES:
    LOAD  R0, minutesVar
    LOADI R1, 0
    
    JSR@SPLIT_MIN
    RET

DISPLAY_HOURS:
    # Carrega o valor das horas
    LOAD  R0, hoursVar
    LOADI R1, 0

    # Verifica se o modo é 12h
    LOAD  R2, modeFlag
    CEQ   R2, 1
    JEQ@DISP_HOURS_12
    
    # Modo 24h
    LOADI R2, 0
    STORE R2, AM_LED
    STORE R2, PM_LED

    JSR@SPLIT_HOUR
    RET

DISP_HOURS_12:
    # Caso especial para o modo 12h
    CEQI  R0, 0
    JEQ@AM_FIX

    # Verifica se é menor que 12h
    CLTI  R0, 12
    JEQ@AM_DISPLAY

    # Converte para 12h
    SUBI R0, 12

    # Caso especial para o modo 12h
    CEQI  R0, 0
    JEQ@PM_FIX

    JMP@PM_DISPLAY

AM_FIX:
    ADDI R0, 12
AM_DISPLAY:
    LOADI R2, 0
    STORE R2, PM_LED
    LOADI R2, 1
    STORE R2, AM_LED

    JSR@SPLIT_HOUR

PM_FIX:
    ADDI R0, 12
PM_DISPLAY:
    LOADI R2, 1
    STORE R2, PM_LED
    LOADI R2, 0
    STORE R2, AM_LED

    JSR@SPLIT_HOUR

SPLIT_SEC:
    CLTI  R0, 10
    JLT@SPLIT_SEC_END

    # Conta os decimos de segundo
    SUBI  R0, 10
    ADDI  R1, 1
    JMP@SPLIT_SEC

SPLIT_SEC_END:
    STORE R0, UNIT_SECOND_DISPLAY
    STORE R1, TEN_SECOND_DISPLAY
    RET

SPLIT_MIN:
    CLTI  R0, 10
    JLT@SPLIT_MIN

    # Conta os decimos de minuto
    SUBI  R0, 10
    ADDI  R1, 1
    JMP@SPLIT_MIN_END

SPLIT_MIN_END:
    STORE R0, UNIT_MINUTE_DISPLAY
    STORE R1, TEN_MINUTE_DISPLAY
    RET

SPLIT_HOUR:
    CLTI  R0, 10
    JLT@SPLIT_HOUR_END

    # Conta os decimos de hora
    SUBI  R0, 10
    ADDI  R1, 1
    JMP@SPLIT_HOUR

SPLIT_HOUR_END:
    STORE R0, UNIT_HOUR_DISPLAY
    STORE R1, TEN_HOUR_DISPLAY
    RET

# ==============================================================================
#                             ROTINAS DE CONFIGURAÇÃO
# ==============================================================================

HANDLE_INPUTS:
    # toggle 24/12 mode
    LOAD  R0, AM_OR_24_KEY
    ANDI  R0, 1
    CEQI  R0, 1
    JEQ@TOGGLE_MODE

    # toggle setup mode
    LOAD R0, SETUP_KEY
    ANDI R0, 1
    CEQI R0, 1
    JEQ@SETUP_MODE

    RET

# ==============================================================================
#                            ROTINAS DA CONFIGURAÇÃO AM/PM
# ==============================================================================

TOGGLE_MODE:
    LOAD  R1, modeFlag
    CEQ   R1, 0
    JEQ@SET_12H

SET_12H:
    LOADI R1, 1
    STORE R1, modeFlag
    RET

SET_24H:
    LOADI R1, 0
    STORE R1, modeFlag
    RET

# ==============================================================================
#                         ROTINAS DE CONFIGURAÇÃO DO RELÓGIO
# ==============================================================================

SETUP_MODE:
    STORE@CLEAR_KEYS
    # Inicializa o estado do setup
    LOADI R0, 0
    PUSH R0, 0

SETUP_LOOP:
    # Verifica se a tecla de setup foi pressionada novamente
    LOAD R1, SETUP_KEY
    ANDI R1, 1
    CEQI R1, 1
    JEQ@APLLY_AJUST

    POP R0, 0
    PUSH R0, 0

    CEQI R0, 0
    JEQ@SETUP_SECONDS

    CEQI R0, 1
    JEQ@SETUP_MINUTES

    CEQI R0, 2
    JEQ@SETUP_HOURS

    JMP@SETUP_LOOP

SETUP_SECONDS:
    # Mostra no display dos segundos os segundos que estao sendo ajustados
    LOAD R0, SETUP_SWITH
    LOADI R1, 0
    JSR@SPLIT_SEC
    JMP@SETUP_LOOP

SETUP_MINUTES:
    # Mostra no display dos minutos os minutos que estao sendo ajustados
    LOAD R0, SETUP_SWITH
    LOADI R1, 0
    JSR@SPLIT_MIN
    JMP@SETUP_LOOP

SETUP_HOURS:
    # Mostra no display das horas os minutos que estao sendo ajustados
    LOAD R0, SETUP_SWITH
    LOADI R1, 0
    JSR@SPLIT_HOUR
    JMP@SETUP_LOOP

APLLY_AJUST:
    POP R0, 0
    PUSH R0, 0

    # Verifica se está ajustando os segundos
    CEQI R0, 0
    JEQ@ADJUST_SECONDS

    # Verifica se está ajustando os minutos
    CEQI R0, 1
    JEQ@ADJUST_MINUTES
    
    # Verifica se está ajustando as horas
    CEQI R0, 2
    JEQ@ADJUST_HOURS

FINISH_AJUST:
    POP R0, 0

    # Vai para o proximo modo de setup
    ADDI R0, 1

    PUSH R0, 0
    
    CEQI R3, 3
    JEQ@EXIT_SETUP

    JMP@SETUP_LOOP

ADJUST_SECONDS:
    # Verifica se esta dentro do limite
    LOAD R2, SETUP_SWITH
    CLTI R2, 60
    JLT@DO_SECONDS_ADJUST

    # Se nao volta para o loop
    JMP@SETUP_LOOP

DO_SECONDS_ADJUST:
    # Aplica e ajusta do display
    STORE R2, secondsVar
    JSR@DISPLAY_SECONDS

    JMP@FINISH_AJUST

ADJUST_MINUTES:
    # Verifica se esta dentro do limite
    LOAD R2, SETUP_SWITH
    CLTI R2, 60
    JLT@DO_MINUTES_ADJUST

    JMP@SETUP_LOOP

DO_MINUTES_ADJUST:
    # Aplica e ajusta do display
    STORE R2, minutesVar
    JSR@DISPLAY_MINUTES

    JMP@FINISH_AJUST

ADJUST_HOURS:
    # Verifica se esta dentro do limite
    LOAD R2, SETUP_SWITH
    CLTI R2, 24
    JLT@DO_HOURS_ADJUST

    JMP@SETUP_LOOP

DO_HOURS_ADJUST:
    # Aplica e ajusta do display
    STORE R2, hoursVar
    JSR@DISPLAY_HOURS

    JMP@FINISH_AJUST

EXIT_SETUP:
    RET