from crafting_system import CraftingSystem
from crafting_professions import create_professions

class Player:
    """
    Represents a player character with professions, inventory, stats, and crafting capabilities.
    """
    def __init__(self, name: str):
        self.name = name
        self.level = 1
        self.gold = 100
        self.inventory = {"iron_ore": 10, "red_flower": 5, "arcane_dust": 3}  # Example inventory
        self.professions = create_professions()  # Initialize professions

    def craft(self, profession_name: str, recipe_id: str):
        """
        Interface for crafting an item by specifying a profession and recipe ID.
        """
        if profession_name not in self.professions:
            print(f"Profession '{profession_name}' does not exist.")
            return

        # Retrieve Profession and Recipe
        profession = self.professions[profession_name]
        try:
            recipe = profession.get_recipe(recipe_id)
        except ValueError as e:
            print(e)
            return

        # Use Crafting System
        crafting_system = CraftingSystem(self)
        success = crafting_system.craft_item(recipe)
        if success:
            print(f"You crafted: {recipe.name}!")

if __name__ == "__main__":
    # Example of a player using the crafting system
    player = Player("Adventurer")
    player.level = 25
    player.gold = 500

    print("Starting inventory:", player.inventory)

    # Attempt to craft an Elixir of Giant Strength using Alchemy
    player.craft("Alchemy", "elixir_strength")

    # Attempt to craft a Plate Chestpiece using Blacksmithing
    player.craft("Blacksmithing", "plate_chestpiece")

    print("Final inventory:", player.inventory)