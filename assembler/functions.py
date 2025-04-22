"""
Module containing the auxiliary functions for the assembler.
"""

def read_file(path: str) -> list[str]:
    """
    Read a text file and return its content as a list of lines.

    Parameters
    ----------
    path : str
        The path to the file to read.

    Returns
    -------
    list[str]
        The content of the file as a list of lines.
    """

    try:
        with open(path, 'r', encoding='utf-8') as f:
            return [line for line in f.readlines() if line.strip()]

    except FileNotFoundError:
        print(f"FATAL: File {path} not found.")
        return []

    except IOError as e:
        print(f"FATAL: Could not read file {path}: {e}")
        return []

def write_to_file(path: str, content: list[str]) -> None:
    """
    Write the given content to a file.

    Parameters
    ----------
    path : str
        The path to the file to write.
    content : list[str]
        The content to write to the file.
    """

    try:
        with open(path, 'w', encoding='utf-8') as f:
            for line in content:
                if not line.endswith("\n"):
                    line += "\n"

                f.write(line)

    except IOError as e:
        print(f"FATAL Could not write to file {path}: {e}")

def retrive_constants(lines : list[str]) -> dict[str, int]:
    """
    Retrive the constants from the assembly file.

    Parameters
    ----------
    lines : list[str]
        The lines of the assembly file.

    Returns
    -------
    dict[str, int]
        The constants defined in the assembly file.
    """

    constants = {}

    for index, line in enumerate(lines, start=1):
        value = line.strip()

        if not value or value.startswith("#"):
            continue

        if value.startswith(".equ"):
            try:
                _, name, value = value.split()
                constants[name.strip()] = int(value.strip())

            except ValueError:
                print(
                    f"ERROR: Line {index}: Invalid constant definition: {line}")

    return constants

def retrive_labels(lines : list[str]) -> tuple[int, dict[str, int]]:
    """
    Retrive the labels from the assembly file.

    Parameters
    ----------
    lines : list[str]
        The lines of the assembly file.

    Returns
    -------
    tuple[int, dict[str, int]]
        The maximum memory address and the labels defined in the assembly file.
    """

    memory_address = 0
    labels = {}

    for line in lines:
        value = line.strip()

        if not value or value.startswith("#") or value.startswith(".equ"):
            continue

        if ":" in value:
            label, _ = value.split(":", 1)

            # Ignore commented line
            if "#" not in label:
                labels[label.strip()] = memory_address

        else:
            memory_address += 1

    return memory_address, labels

def handle_empty_line(
        memory_address: int,
        instructions: list[str],
        comment: str
    ) -> None:

    """
    Handle empty lines in the assembly code.

    Parameters
    ----------
    memory_address : int
        The current memory address.
    instructions : list[str]
        The list of instructions.
    comment : str
        The comment associated with the empty line.
    """

    if memory_address < 1 and len(instructions) > 0:
        instructions.pop()

    if comment:
        instructions.append("\t-- " + comment)

def retrive_comment(line: str) -> tuple[str, str]:
    """
    Retrive the comment from a line of assembly code.

    Parameters
    ----------
    line : str
        The line to process.
    
    Returns
    -------
    tuple[str, str]
        The instruction and the comment.
    """

    if '#' in line:
        splits = line.split('#', 1)

        return splits[0].strip(), splits[1].strip()

    return line.strip(), ""

def retrive_instrution_blocks(line: str) -> tuple[str, str]:
    """
    Retrive the instruction blocks from a line of assembly code.

    Parameters
    ----------
    line : str
        The instruction line.

    Returns
    -------
    tuple[str, str]
        The mnemonic and immediate value.
    """

    if "@" in line:
        splits = line.split("@")

        mne = splits[0].strip()
        imediate = splits[1].strip()

    elif "$" in line:
        splits = line.split("$")

        mne = splits[0].strip()
        imediate = splits[1].strip()

    else:
        mne = line.strip()
        imediate = "0"

    return mne, imediate
