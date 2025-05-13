"""
Module containing the standard Mnemonicos and Registers enumerations.
"""

from enum import Enum


class Mnemonicos(Enum):
    """
    Enum class representing the mnemonicos and their corresponding decimal values.
    """
    NOP   = 0x00
    LOAD  = 0x01
    LOADI = 0x02
    STORE = 0x03
    CEQ   = 0x04
    CEQI  = 0x05
    JEQ   = 0x06
    JMP   = 0x07
    JSR   = 0x08
    RET   = 0x09
    CLT   = 0x0A
    CLTI  = 0x0C
    JLT   = 0x0D
    PUSH  = 0x0E
    POP   = 0x0F
    ADD   = 0x11
    ADDI  = 0x12
    SUB   = 0x14
    SUBI  = 0x15
    AND   = 0x16
    ANDI  = 0x17
    OR    = 0x18
    ORI   = 0x19


class Registers(Enum):
    """
    Enum class representing the registers and their corresponding decimal values.
    """
    R0 = 0x0
    R1 = 0x1
    R2 = 0x2
    R3 = 0x3
