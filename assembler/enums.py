"""
Module containing the standard Mnemonicos enum.
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
