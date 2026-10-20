import re

# Strict validation rules for character names
MAX_NAME_LENGTH = 18
NAME_PATTERN = re.compile(r'^[a-zA-Z0-9_]+$')


def validate_character_name(name: str) -> tuple[bool, str]:
    """
    Validates character name:
    - 1 to 18 characters long
    - Alphanumeric and underscores ONLY (no spaces, no dashes, no special chars)
    """
    cleaned_name = name.strip()

    if not cleaned_name:
        return False, "Error: Name cannot be empty."

    if len(cleaned_name) > MAX_NAME_LENGTH:
        return False, f"Error: Name must be {MAX_NAME_LENGTH} characters or less (current: {len(cleaned_name)})."

    if not NAME_PATTERN.match(cleaned_name):
        return False, "Error: Name can only contain letters, numbers, and underscores (_) - no spaces or dashes."

    return True, cleaned_name


def prompt_custom_character_name() -> str:
    """
    Interactive prompt loop for creating a character with name validation.
    Use this during New Game initialization.
    """
    print("\n--- CHARACTER CREATION ---")
    while True:
        raw_name = input("Enter your character name (1-18 chars, letters/numbers/_ only): ")
        is_valid, result = validate_character_name(raw_name)
        if is_valid:
            print(f"Character created successfully! Welcome, {result}.\n")
            return result
        else:
            print(f"Invalid input: {result}. Please try again.\n")


class CommandParser:
    """
    Maps user input to game commands with support for aliases matching exact game loop expected keys.
    """
    COMMAND_ALIASES = {
        # Movement (Outputs exact expected game loop strings)
        "move_forward": ["f", "fw", "forward", "n", "north", "move forward", "move_forward"],
        "move_backward": ["b", "back", "backward", "s", "south", "move back", "move_backward"],
        "move_left": ["left", "w", "west", "move left", "move_left"],
        "move_right": ["r", "right", "e", "east", "move right", "move_right"],
        "teleport_home": ["home", "hearth", "recall", "teleport_home"],
        
        # Room & Inspection
        "look_room": ["look", "l", "examine", "inspect", "look_room"],
        "gather_node": ["gather", "g", "harvest", "gather_node"],
        
        # Progression & Stats
        "display_stats": ["stats", "status", "c", "char", "display_stats"],
        "display_inventory": ["inv", "inventory", "i", "display_inventory"],
        "talents": ["talents", "talent", "trees", "t", "specs"],
        
        # Crafting & Professions
        "craft": ["craft", "recipe", "recipes"],
        "alchemy": ["alchemy", "alch"],
        "blacksmithing": ["blacksmithing", "smith"],
        "enchanting": ["enchanting", "enchant"],
        "engineering": ["engineering", "eng"],
        "leatherworking": ["leatherworking", "lw", "tailoring"],
        
        # System Commands
        "display_help": ["help", "h", "commands", "?", "display_help"],
        "save": ["save"],
        "load": ["load"],
        "delete": ["delete"],
        "quit": ["quit", "exit"]
    }

    @classmethod
    def display_help(cls) -> str:
        """
        Display help categories and their associated commands.
        Dynamically builds output from the alias dictionary.
        """
        help_text = "\n==================================================\n"
        help_text += "              MISTWOOD FRONTIERS HELP             \n"
        help_text += "==================================================\n"

        categories = {
            "Movement": ["move_forward", "move_backward", "move_left", "move_right", "teleport_home"],
            "Room & Gathering": ["look_room", "gather_node"],
            "Progression & Crafting": ["display_stats", "display_inventory", "talents", "craft", "alchemy", "blacksmithing"],
            "System": ["display_help", "save", "load", "delete", "quit"]
        }

        for category, commands in categories.items():
            help_text += f"\n{category}:\n"
            for command in commands:
                aliases = cls.COMMAND_ALIASES.get(command, [command])
                clean_name = command.replace("_", " ").capitalize()
                help_text += f"  - {clean_name}: {', '.join(aliases)}\n"

        help_text += "==================================================\n"
        return help_text

    @classmethod
    def emit_signal(cls, command: str, godot_signal_emitter) -> None:
        """
        Trigger appropriate Godot signals based on the parsed command.

        :param command: Normalized command to handle
        :param godot_signal_emitter: Reference to Godot node to emit signals
        """
        signal_name = command.lower()
        if hasattr(godot_signal_emitter, command):
            godot_signal_emitter.emit_signal(signal_name)

    @classmethod
    def normalize_command(cls, input_command: str) -> str:
        """
        Normalize user input to its mapped core command.

        :param input_command: Raw command from user input
        :return: Normalized command string matching exact game loop keys
        """
        if not input_command or not input_command.strip():
            return "Unknown Command: Type 'help' for options."

        normalized_command = input_command.strip().lower()
        
        for base_command, alias_list in cls.COMMAND_ALIASES.items():
            if normalized_command in alias_list:
                return base_command
                
        return normalized_command


if __name__ == "__main__":
    # 1. Test Command Normalization
    print("--- Testing Command Normalization ---")
    test_inputs = ["forward", "f", "n", "back", "b", "look", "l", "stats", "inv", "help"]
    for inp in test_inputs:
        result = CommandParser.normalize_command(inp)
        print(f"Input: '{inp}' --> Normalized Key: '{result}'")

    # 2. Test Help Menu
    print(CommandParser.display_help())

    # 3. Test Character Name Validation / Prompt
    print("--- Testing Character Name Prompt ---")
    player_name = prompt_custom_character_name()
    print(f"Final Validated Character Name: {player_name}")