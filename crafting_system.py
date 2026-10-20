from typing import List, Dict

class Recipe:
    """
    Represents a crafting recipe with required materials and output.
    """
    def __init__(self, recipe_id: str, name: str, required_level: int, required_materials: Dict[str, int], produced_item: str, crafting_cost: int):
        self.recipe_id = recipe_id
        self.name = name
        self.required_level = required_level
        self.required_materials = required_materials  # {material_id: quantity}
        self.produced_item = produced_item
        self.crafting_cost = crafting_cost

class Profession:
    """
    A class for managing professions and their recipes.
    """
    def __init__(self, name: str):
        self.name = name
        self.recipes: List[Recipe] = []

    def add_recipe(self, recipe: Recipe):
        """Add a new recipe to the profession."""
        self.recipes.append(recipe)

    def get_recipe(self, recipe_id: str) -> Recipe:
        """Retrieve a recipe by its ID."""
        for recipe in self.recipes:
            if recipe.recipe_id == recipe_id:
                return recipe
        raise ValueError(f"Recipe with ID {recipe_id} not found in {self.name} profession.")

class CraftingSystem:
    """
    Handles crafting mechanics for the player using recipes and materials.
    """
    def __init__(self, player):
        self.player = player

    def craft_item(self, recipe: Recipe):
        """
        Attempt to craft an item using the given recipe.
        - Validate level requirements.
        - Check for sufficient materials.
        - Deduct crafting cost and materials.
        - Add crafted item to inventory.
        """
        if self.player.level < recipe.required_level:
            print(f"You need to be level {recipe.required_level} to craft {recipe.name}.")
            return False

        # Check if player has all required materials
        for material, quantity in recipe.required_materials.items():
            if self.player.inventory.get(material, 0) < quantity:
                print(f"You lack the required material: {material} (need {quantity}).")
                return False

        # Deduct materials and crafting cost
        for material, quantity in recipe.required_materials.items():
            self.player.inventory[material] -= quantity

        self.player.gold -= recipe.crafting_cost

        # Add the crafted item to inventory
        self.player.inventory[recipe.produced_item] = self.player.inventory.get(recipe.produced_item, 0) + 1
        print(f"Successfully crafted: {recipe.name}")
        return True

class Player:
    """
    Represents a player character with inventory and stats.
    """
    def __init__(self, name: str):
        self.name = name
        self.level = 1
        self.inventory: Dict[str, int] = {}  # {item_id: quantity}
        self.gold = 100

if __name__ == "__main__":
    # Example setup and usage
    player = Player("Adventurer")
    player.level = 20
    player.inventory = {"iron_ore": 10, "wood": 5, "arcane_dust": 3}
    player.gold = 500

    # Define professions
    alchemy = Profession("Alchemy")
    blacksmithing = Profession("Blacksmithing")

    # Add recipes
    alchemy.add_recipe(Recipe("potion_health", "Health Potion", 5, {"herbs": 3, "water": 1}, "health_potion", 10))
    blacksmithing.add_recipe(Recipe("iron_sword", "Iron Sword", 10, {"iron_ore": 2, "wood": 1}, "iron_sword", 20))

    # Crafting simulation
    crafting_system = CraftingSystem(player)
    recipe = blacksmithing.get_recipe("iron_sword")
    crafting_system.craft_item(recipe)