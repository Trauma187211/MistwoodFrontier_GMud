class Player:
    """
    A class representing the player, including stats, location, and inventory.
    """
    def __init__(self, name):
        self.name = name
        self.location = "starting_area"
        self.in_combat = False
        self.inventory = []

class HubCity:
    """
    A class for managing the main hub city, "The Ironclad Sanctuary."
    """

    def __init__(self, player):
        """Initialize the city with references to the player."""
        self.player = player

    def display_menu(self):
        """
        Display the main menu options available in "The Ironclad Sanctuary."
        """
        print("\nWelcome to The Ironclad Sanctuary!")
        print("Please choose an action:")
        print("[forge] or [blacksmith]: Craft weapons, armor, and gear upgrades.")
        print("[alchemy] or [lab]: Brew potions and stat-buff elixirs.")
        print("[enchant] or [sanctum]: Disenchant gear and apply stat glints.")
        print("[trainer] or [hall]: Train and learn new abilities.")
        print("[vault] or [store]: Access bank storage and buy/sell items.")
        print("[leave] or [explore]: Choose a new world zone to explore.")

    def navigate(self, command):
        """
        Handle navigation commands within the Ironclad Sanctuary.
        """
        if command in ["forge", "blacksmith"]:
            print("You head to the forge to craft and upgrade your gear.")
        elif command in ["alchemy", "lab"]:
            print("You enter the alchemy lab to prepare potions and elixirs.")
        elif command in ["enchant", "sanctum"]:
            print("You visit the sanctum for disenchanting and enchanting gear.")
        elif command in ["trainer", "hall"]:
            print("Welcome to the training hall for honing skills and spending talent points.")
        elif command in ["vault", "store"]:
            print("Accessing inventory and marketplace options.")
        elif command in ["leave", "explore"]:
            print("Select a new adventure to embark on.")
            self.player.location = "world_map"
        else:
            print("Invalid option. Please try again.")

class GameWorld:
    """
    A class representing the overall world of the game.
    """
    def __init__(self):
        self.player = Player(name="Adventurer")
        self.hub_city = HubCity(self.player)

    def home_command(self):
        """
        Teleport the player to The Ironclad Sanctuary, if eligible.
        """
        if self.player.in_combat:
            print("You cannot use 'home' while in combat!")
        else:
            print("You invoke the power of the Ancient Hearthstone.")
            print("A warm, glowing light surrounds you as you're transported to safety...")
            self.player.location = "ironclad_sanctuary"
            self.hub_city.display_menu()

# Example usage:
game_world = GameWorld()

def main_loop(game_world):
    """
    Simulate the game loop, processing user input.
    """
    while True:
        command = input("Enter a command: ").strip().lower()
        if command in ["home", "recall", "hearth"]:
            game_world.home_command()
        elif command == "exit":
            print("Exiting. Farewell, adventurer!")
            break
        elif game_world.player.location == "ironclad_sanctuary":
            game_world.hub_city.navigate(command)
        else:
            print(f"You are currently in {game_world.player.location}. Explore or use 'home' to return to The Ironclad Sanctuary.")

if __name__ == "__main__":
    main_loop(game_world)