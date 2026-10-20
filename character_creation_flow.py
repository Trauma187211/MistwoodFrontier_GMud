import re
from save_manager import SaveManager

class CharacterCreation:
    @staticmethod
    def prompt_character_name():
        while True:
            name = input("Enter your character name (1-18 chars, letters/numbers/_ only): ").strip()

            # Validation: Length, allowed characters
            if 1 <= len(name) <= 18 and re.match(r'^[a-zA-Z0-9_]+$', name):
                return name

            # Display error and re-prompt
            print("Invalid name! Must be 1-18 characters containing only letters, numbers, and underscores (_). No spaces or dashes.")

    @staticmethod
    def create_new_character():
        manager = SaveManager()
        character_name = CharacterCreation.prompt_character_name()
        manager.save_game(Player(name=character_name, level=1, zone="Starting Zone"))
        print(f"Character '{character_name}' created and saved successfully!")

# Example Player class for testing
class Player:
    def __init__(self, name, level, zone):
        self.name = name
        self.level = level
        self.current_exp = 0
        self.exp_to_next_level = 100
        self.talent_points = 0
        self.inventory = {}
        self.zone = zone

if __name__ == "__main__":
    CharacterCreation.create_new_character()