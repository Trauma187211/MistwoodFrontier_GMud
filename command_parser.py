class CommandParser:
    """
    Maps user input to game commands with support for aliases.
    """
    COMMAND_ALIASES = {
        "move_forward": ["f", "fw", "forward", "n", "north"],
        "move_backward": ["b", "back", "backward", "s", "south"],
        "move_left": ["l", "left", "w", "west"],
        "move_right": ["r", "right", "e", "east"],
        "look_room": ["look", "l", "examine", "inspect"],
        "display_stats": ["stats", "status", "c", "char"],
        "display_inventory": ["inv", "inventory", "i"],
        "teleport_home": ["home", "hearth", "recall"],
        "gather_node": ["gather", "g", "harvest"],
        "display_help": ["help", "h", "commands", "?"],
        "talents": ["talents", "talent", "trees", "t", "specs"],
        "home": ["home", "recall", "hearth"],
    }

    @classmethod
    def display_help(cls):
        """
        Display help categories and their associated commands.
        
        Dynamically builds output from the alias dictionary.
        """
        help_text = "\nCommands:\n"

        categories = {
            "Movement": ["move_forward", "move_backward", "move_left", "move_right", "teleport_home"],
            "Room & Gathering": ["look_room", "gather_node"],
            "Progression & Crafting": ["display_stats", "display_inventory", "talents", "craft", "alchemy", "blacksmithing"],
            "System": ["display_help", "save", "load", "quit"]
        }

        for category, commands in categories.items():
            help_text += f"\n{category}:\n"
            for command in commands:
                aliases = cls.COMMAND_ALIASES.get(command, [])
                help_text += f"  - {command.replace('_', ' ').capitalize()}: {', '.join(aliases)}\n"
        
        return help_text

    @classmethod
    def emit_signal(cls, command, godot_signal_emitter):
        """
        Trigger appropriate Godot signals based on the parsed command.

        :param command: Normalized command to handle
        :param godot_signal_emitter: Reference to Godot node to emit signals
        """
        signal_name = command.lower()
        if hasattr(godot_signal_emitter, command):
            godot_signal_emitter.emit_signal(signal_name)
    
    @classmethod
    def normalize_command(cls, input_command):
        """
        Normalize user input to its mapped core command.

        :param input_command: Raw command from user input
        :return: Normalized command string if a match is found, or None otherwise
        """
        normalized_command = input_command.strip().lower()
        """
        Normalize user input to its mapped core command.
        """
        normalized_command = input_command.strip().lower()
        for base_command, alias_list in cls.COMMAND_ALIASES.items():
            if normalized_command in alias_list:
                return base_command
        return "Unknown Command: Type 'help' for options."  # Feedback if unknown

if __name__ == "__main__":
    # Example usage of CommandParser
    test_commands = [
        "f", "north", "look", "gather", "stats", "inv", "home", "help", "unknown_command"
    ]

    print("--- Help Output ---\n")
    print(CommandParser.display_help())

    print("\n--- Test Normalized Commands ---\n")
    for cmd in test_commands:
        normalized = CommandParser.normalize_command(cmd)
        print(f"Input: {cmd} -> Normalized: {normalized}")