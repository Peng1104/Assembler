"""
Main module for the assembler package.
"""

import sys
from assembler.assembler import Assembler
from assembler.enums import Mnemonicos, Registers
from assembler.functions import write_to_file

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python -m assembler <ASM_FILE> [MIF_FILE]")
        sys.exit(1)

    MIF_FILE = "initROM.mif"

    if len(sys.argv) > 2:
        if not sys.argv[2].endswith(".mif"):
            sys.argv[2] += ".mif"

        MIF_FILE = sys.argv[2]

    assembler = Assembler({mne.name: mne.value for mne in Mnemonicos}, {
                          register.name: register.value for register in Registers})

    write_to_file(MIF_FILE, assembler.build(sys.argv[1]))
