import re
from save_manager import SaveManager
from command_parser import prompt_custom_character_name, CommandParser

class CharacterCreation:
    @staticmethod
    def prompt_character_name():
        return prompt_custom_character_name()

    @staticmethod
    def create_new_character():
        manager = SaveManager()
        character_name = prompt_custom_character_name()
        
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
    while True:
        user_input = input("Enter command: ")
        normalized_command = CommandParser.normalize_command(user_input)

        if normalized_command == "display_help":
            print(CommandParser.display_help())
        elif normalized_command == "quit":
            print("Exiting game...")
            break
        else:
            print(f"Command '{normalized_command}' cannot be processed yet.")