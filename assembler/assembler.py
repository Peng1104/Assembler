"""
Module containing the Assembler class.
"""

from assembler.functions import read_file, retrive_constants, retrive_labels, \
    handle_empty_line, retrive_comment, retrive_instrution_blocks


class Assembler:  # pylint: disable=too-few-public-methods
    """
    Class to assemble assembly code into binary instructions.
    """

    def __init__(
        self,
        mne_map: dict[str, int],
        register_map: dict[str, int] = None,
        opcode_length: int = 5,
        register_length: int = 2,
        imediate_length: int = 9
    ):  # pylint: disable=too-many-arguments, too-many-positional-arguments
        """
        Initialize the Assembler class.

        Parameters
            mne_map : dict[str, int]
                The mapping of mnemonics to their decimal values.
            register_map : dict[str, int], optional
                The mapping of registers to their decimal values (default is empty).
            opcode_length : int, optional
                The length of the opcode in bits (default is 4).
            register_length : int, optional
                The length of the register in bits (default is 3).
            imediate_length : int, optional
                The length of the immediate value in bits (default is 9).
        """

        self.mne_map = mne_map
        self.regester_map = register_map or {}
        self.__opcode_length = opcode_length
        self.__register_length = register_length
        self.__imediate_length = imediate_length

    def build(self, asm_file: str) -> list[str]:
        """
        Build the binary instructions from the assembly file.

        Parameters
            asm_file : str
                The path to the assembly file.

        Returns
            list[str]
                The content of the MIF file, including the header and instructions.
        """

        # Retrive the assembly file lines
        lines = read_file(asm_file)

        # Get the constants and labels
        constants = retrive_constants(lines)
        max_memory_address, labels = retrive_labels(lines)

        # Get the MIF file header
        content: list[str] = self.__get_mif_configurations(
            max_memory_address, constants, labels)

        labels.update(constants)

        # Encode the ASM Instructions to binary
        content.extend(self.__encode(
            lines, labels, len(str(max_memory_address))))

        # END tag of the MIF file
        content.append("END;")

        return content

    def __encode(
        self,
        lines: list[str],
        labels: dict[str, int],
        address_width: int
    ) -> list[str]:
        """
        Encode the assembly instructions into binary format.

        Parameters
            lines : list[str]
                The lines of assembly code.
            labels : dict[str, int]
                The labels defined in the assembly code.
            address_width : int
                The width of the memory address.

        Returns
            list[str]
                The binary instructions.
        """

        memory_address = 0
        instructions = []

        for line in lines:
            line, comment = retrive_comment(line)

            if ".equ" in line or ":" in line:
                continue

            if not line.strip():
                handle_empty_line(memory_address, instructions, comment)
                continue

            mne, register, imediate = retrive_instrution_blocks(line)

            if register:
                binary_instruction = self.__mne_to_binary(mne) + \
                    self.__register_to_binary(register) + \
                    self.__imediate_to_binary(imediate, labels)

            elif len(self.regester_map) > 0:
                binary_instruction = self.__mne_to_binary(mne) + \
                    "0" * self.__register_length + \
                    self.__imediate_to_binary(imediate, labels)

            else:
                binary_instruction = self.__mne_to_binary(mne) + \
                    self.__imediate_to_binary(imediate, labels)

            address_str = f"{memory_address}".ljust(address_width)

            if comment:
                instructions.append(
                    f"\t{address_str} : {binary_instruction}; -- {line} # {comment}")

            else:
                instructions.append(
                    f"\t{address_str} : {binary_instruction}; -- {line}")

            memory_address += 1

        return instructions

    def __get_mif_configurations(
        self,
        max_memory_address: int,
        constants: dict[str, int],
        labels: dict[str, int]
    ) -> list[str]:
        """
        Get the MIF configurations for the memory file.

        Parameters:
            max_memory_address (int): The maximum memory address, used to calculate the 
                                      depth of the memory.
            constants (dict[str, int]): The constants defined in the assembly file.
            labels (dict[str, int]): The labels defined in the assembly file.

        Returns:
            list[str]: The MIF configuration instructions.
        """

        width = self.__opcode_length + self.__imediate_length

        if len(self.regester_map) > 0:
            width += self.__register_length

        instructions = []

        instructions.append("-- -------------------------------------")
        instructions.append("--               MIF File")
        instructions.append("-- -------------------------------------")
        instructions.append("")
        instructions.append(f"WIDTH={width};")
        instructions.append(
            f"DEPTH={2 ** (max_memory_address + 1).bit_length()};")
        instructions.append("")
        instructions.append("ADDRESS_RADIX=DEC;")
        instructions.append("DATA_RADIX=BIN;")
        instructions.append("")
        instructions.append("CONTENT BEGIN")
        instructions.append("")

        if len(constants) > 0:
            instructions.append("-- -------------------------------------")
            instructions.append("--               Constants")
            instructions.append("-- -------------------------------------")
            instructions.append("")

            for name, value in constants.items():
                instructions.append(f"-- {name}={value}")

            instructions.append("")

        if len(labels) > 0:
            instructions.append("-- -------------------------------------")
            instructions.append("--                 Labels")
            instructions.append("-- -------------------------------------")
            instructions.append("")

            for name, value in labels.items():
                instructions.append(f"-- {name}={value}")

            instructions.append("")

        instructions.append("-- -------------------------------------")
        instructions.append("--            Memory Content")
        instructions.append("-- -------------------------------------")
        instructions.append("")

        return instructions

    def __register_to_binary(self, register: str) -> str:
        """
        Get the register value in binary format.

        Parameters:
            register (str): The register name.

        Returns:
            str: The register value in binary format, padded with zeros.
        """

        if register in self.regester_map:
            value = self.regester_map[register]

            if value.bit_length() > self.__register_length:
                print(
                    f"WARNING: Register '{register}' is too large for the register field.")

                value = value & ((1 << self.__register_length) - 1)

            return bin(value)[2:].zfill(self.__register_length)

        print(f"ERROR: Unknown register: {register}")
        return "0" * self.__register_length

    def __imediate_to_binary(self, imediate: str, labels: dict[str, int]) -> str:
        """
        Get the imediate value in binary format.

        Parameters:
            imediate (str): The immediate value or label.
            labels (dict[str, int]): The labels defined in the assembly file.

        Returns:
            str: The immediate value in binary format, padded with zeros.
        """

        if imediate in labels:
            value = labels[imediate]

        else:
            try:
                if imediate.startswith("0x"):
                    value = int(imediate[2:], 16)
                else:
                    value = int(imediate)
            except ValueError:
                print(f"ERROR: Could not convert '{imediate}' to an integer.")
                return "0" * self.__imediate_length

        if value.bit_length() > self.__imediate_length:
            print(
                f"WARNING: Immediate value '{imediate}' is too large for the immediate field.")

            value = value & ((1 << self.__imediate_length) - 1)

        return bin(value)[2:].zfill(self.__imediate_length)

    def __mne_to_binary(self, mne: str) -> str:
        """
        Return the binary representation of a mnemonic.

        Parameters:
            mne (str): The mnemonic.

        Returns:
            str: The binary representation of the mnemonic.
        """

        if mne in self.mne_map:
            value = self.mne_map[mne]

            if value.bit_length() > self.__opcode_length:
                print(
                    f"WARNING: Mnemonic '{mne}' is too large for the opcode field.")

                value = value & ((1 << self.__opcode_length) - 1)

            return bin(value)[2:].zfill(self.__opcode_length)

        print(f"ERROR: Unknown instruction: {mne}")
        return "0" * self.__opcode_length
