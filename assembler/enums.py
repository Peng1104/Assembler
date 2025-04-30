"""
Module containing the standard Mnemonicos and Registers enumerations.
"""

from enum import Enum

class Mnemonicos(Enum):
    """
    Enum class representing the mnemonicos and their corresponding decimal values.
    """
    NOP  = 0x0
    LDA  = 0x1
    ADD  = 0x2
    SUB  = 0x3
    LDI  = 0x4
    STA  = 0x5
    JMP  = 0x6
    JEQ  = 0x7
    CEQ  = 0x8
    JSR  = 0x9
    RET  = 0xA
    ADDI = 0xB
    SUBI = 0xC
    CEQI = 0xD
    ANDI = 0xE

class Registers(Enum):
    """
    Enum class representing the registers and their corresponding decimal values.
    """
    R0 = 0x0
    R1 = 0x1
    R2 = 0x2
    R3 = 0x3
    R4 = 0x4
    R5 = 0x5
    R6 = 0x6
    R7 = 0x7
    R8 = 0x8