class CommandParser:
    """
    Maps user input to game commands with support for aliases.
    """
    COMMAND_ALIASES = {
        "forward": ["move forward", "forward", "f", "move north", "north", "n"],
        "back": ["move back", "back", "b", "move south", "south", "s"],
        "left": ["move left", "left", "lft", "move west", "west", "w"],
        "right": ["move right", "right", "r", "move east", "east", "e"],
        "inventory": ["inventory", "inv", "i", "bag", "bags"],
        "stats": ["character", "stats", "c", "stat", "profile"],
        "look": ["look", "l", "examine", "inspect", "search"],
        "gather": ["gather", "mine", "harvest", "g", "pick"],
        "help": ["help", "h", "commands", "?"],
        "talents": ["talents", "talent", "trees", "t", "specs"],
        "home": ["home", "recall", "hearth"],
    }

    @classmethod
    def normalize_command(cls, input_command):
        """
        Normalize user input to its mapped core command.
        """
        normalized_command = input_command.strip().lower()
        for command, aliases in cls.COMMAND_ALIASES.items():
            if normalized_command in aliases:
                return command
        return None  # Command not found

if __name__ == "__main__":
    # Example usage of CommandParser
    while True:
        user_input = input("Enter a command: ").strip()
        normalized = CommandParser.normalize_command(user_input)

        if normalized:
            print(f"Normalized Command: {normalized}")
        else:
            print("Unknown command. Type 'help' for available options.")

        if user_input == "exit":
            break