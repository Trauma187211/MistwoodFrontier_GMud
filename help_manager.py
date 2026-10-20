class HelpManager:
    """
    Dynamically generates a categorized help menu for all active game commands.
    """

    CATEGORIES = {
        "Exploration & Navigation": [
            ("forward", ["move forward", "forward", "f", "move north", "north", "n"], "Move forward or north."),
            ("back", ["move back", "back", "b", "move south", "south", "s"], "Move back or south."),
            ("left", ["move left", "left", "lft", "move west", "west", "w"], "Move left or west."),
            ("right", ["move right", "right", "r", "move east", "east", "e"], "Move right or east."),
            ("look", ["look", "l", "examine", "inspect", "search"], "Look around or examine surroundings."),
            ("home", ["home", "recall", "hearth"], "Return to the base city."),
        ],
        "Gathering & Crafting": [
            ("gather", ["gather", "mine", "harvest", "g", "pick"], "Gather resources like herbs or ores."),
            ("forge", ["forge"], "Craft items using blacksmithing."),
            ("alchemy", ["alchemy"], "Brew potions and elixirs."),
        ],
        "Character & Progression": [
            ("stats", ["character", "stats", "c", "stat", "profile"], "View character stats and status."),
            ("inventory", ["inventory", "inv", "i", "bag", "bags"], "View your inventory and items."),
            ("talents", ["talents", "talent", "trees", "t", "specs"], "View and spend talent points."),
        ],
        "System & Game State": [
            ("help", ["help", "h", "commands", "?"], "Display this help menu."),
            ("save", ["save"], "Save your progress."),
            ("load", ["load"], "Load your saved game."),
            ("quit", ["quit"], "Quit the game."),
        ],
    }

    @classmethod
    def display_help(cls):
        """
        Prints a categorized help menu to the console.
        """
        print("\n=== HELP MENU ===")
        for category, commands in cls.CATEGORIES.items():
            print(f"\n{category}:")
            for command, aliases, description in commands:
                alias_list = ", ".join(aliases)
                print(f"  {command:10} - {description}")
                print(f"     Aliases: {alias_list}")

if __name__ == "__main__":
    # Example of the HelpManager display
    HelpManager.display_help()