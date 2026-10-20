from crafting_system import Profession, Recipe

def create_professions():
    """
    Initializes professions and their corresponding recipes for the game.
    Returns a dictionary of professions mapped by their names.
    """
    professions = {}

    # Alchemy
    alchemy = Profession("Alchemy")
    alchemy.add_recipe(Recipe("elixir_strength", "Elixir of Giant Strength", 25, {"giant_blood": 2, "star_flower": 3, "crystal_essence": 1}, "elixir_giant_strength", 50))
    alchemy.add_recipe(Recipe("flask_arcane", "Flask of the Arcane", 30, {"arcane_essence": 3, "mana_root": 5}, "flask_arcane", 75))
    alchemy.add_recipe(Recipe("major_health_potion", "Major Health Potion", 15, {"red_flower": 3, "distilled_water": 1}, "major_health_potion", 20))
    professions[alchemy.name] = alchemy

    # Blacksmithing
    blacksmithing = Profession("Blacksmithing")
    blacksmithing.add_recipe(Recipe("plate_chestpiece", "Plate Chestpiece", 20, {"steel_bar": 8, "leather_strap": 2}, "plate_chestpiece", 100))
    blacksmithing.add_recipe(Recipe("refined_sword", "Refined Sword", 25, {"steel_bar": 5, "hardened_wood": 3, "magic_ore": 1}, "refined_sword", 150))
    professions[blacksmithing.name] = blacksmithing

    # Enchanting
    enchanting = Profession("Enchanting")
    enchanting.add_recipe(Recipe("glint_crit", "Enchant Weapon: +Critical Hit", 20, {"arcane_dust": 5, "shimmering_gem": 1}, "enchant_crit", 200))
    enchanting.add_recipe(Recipe("glint_armor", "Enchant Armor: +Armor", 15, {"arcane_dust": 4}, "enchant_armor", 150))
    professions[enchanting.name] = enchanting

    # Engineering
    engineering = Profession("Engineering")
    engineering.add_recipe(Recipe("goblin_grenade", "Goblin Grenade", 10, {"explosive_powder": 3, "goblin_scrap": 2}, "goblin_grenade", 30))
    engineering.add_recipe(Recipe("auto_turret", "Auto-Turret", 25, {"iron_gear": 5, "cogwheel": 4, "powered_crystal": 2}, "auto_turret", 200))
    professions[engineering.name] = engineering

    # Leatherworking/Tailoring
    tailoring = Profession("Leatherworking & Tailoring")
    tailoring.add_recipe(Recipe("agility_leather", "Agility Leather Armor", 18, {"leather_scraps": 6, "silk_thread": 4, "beast_hide": 2}, "agility_leather", 80))
    tailoring.add_recipe(Recipe("mana_cloth", "Mana Infused Cloth Armor", 22, {"mana_thread": 6, "enchanted_cloth": 4}, "mana_cloth", 120))
    professions[tailoring.name] = tailoring

    return professions

if __name__ == "__main__":
    professions = create_professions()
    for profession_name, profession in professions.items():
        print(f"\nProfession: {profession_name}")
        for recipe in profession.recipes:
            print(f" - {recipe.name}: Requires Level {recipe.required_level}, Materials: {recipe.required_materials}")