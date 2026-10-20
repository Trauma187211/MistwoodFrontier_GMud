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


class CommandParser:
    """
    Maps user input to game commands with support for aliases.
    """
    COMMAND_ALIASES = {
        # Movement
        "move_forward": ["f", "fw", "forward", "n", "north"],
        "move_backward": ["b", "back", "backward", "s", "south"],
        "move_left": ["left", "w", "west"],
        "move_right": ["r", "right", "e", "east"],
        "teleport_home": ["home", "hearth", "recall"],
        
        # Room & Gathering
        "look_room": ["look", "l", "examine", "inspect"],
        "gather_node": ["gather", "g", "harvest"],
        
        # Progression & Stats
        "display_stats": ["stats", "status", "c", "char"],
        "display_inventory": ["inv", "inventory", "i"],
        "talents": ["talents", "talent", "trees", "t", "specs"],
        
        # Crafting & Professions
        "craft": ["craft", "recipe", "recipes"],
        "alchemy": ["alchemy", "alch"],
        "blacksmithing": ["blacksmithing", "smith"],
        "enchanting": ["enchanting", "enchant"],
        "engineering": ["engineering", "eng"],
        "leatherworking": ["leatherworking", "lw", "tailoring"],
        
        # System Commands
        "display_help": ["help", "h", "commands", "?"],
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
        :return: Normalized command string if a match is found, or error message otherwise
        """
        if not input_command or not input_command.strip():
            return "Unknown Command: Type 'help' for options."

        normalized_command = input_command.strip().lower()
        
        for base_command, alias_list in cls.COMMAND_ALIASES.items():
            if normalized_command in alias_list:
                return base_command
                
        return f"Unknown Command: '{input_command}'. Type 'help' for options."


if __name__ == "__main__":
    # Test Suite
    test_commands = [
        "f", "north", "b", "w", "l", "look", "g", "gather", 
        "c", "inv", "home", "help", "craft", "alchemy", "invalid_cmd"
    ]

    print("--- Help Output ---")
    print(CommandParser.display_help())

    print("\n--- Test Normalized Commands ---")
    for cmd in test_commands:
        normalized = CommandParser.normalize_command(cmd)
        print(f"Input: '{cmd}' -> Normalized: {normalized}")

    print("\n--- Test Character Name Validation ---")
    test_names = ["Trauma", "Doc_Trauma", "Invalid Name", "TooLongOfANameThatExceeds18Chars", "Bad-Dash"]
    for name in test_names:
        valid, msg = validate_character_name(name)
        print(f"Name: '{name}' -> Valid: {valid} | Output: {msg}")