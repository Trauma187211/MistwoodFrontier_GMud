import os
import json
import re
from datetime import datetime

class SaveManager:
    """
    Manages game saves, supporting multiple character-based named slots.
    """
    SAVE_FOLDER = "saves"

    def __init__(self):
        # Ensure the save folder exists
        os.makedirs(self.SAVE_FOLDER, exist_ok=True)

    def sanitize_name(self, name):
        """
        Sanitizes the character name for safe file use.
        """
        sanitized_name = re.sub(r'[^a-zA-Z0-9_]', '_', name).lower()
        return sanitized_name

    def get_save_path(self, character_name):
        """
        Constructs the file path for a character's save file.
        """
        sanitized_name = self.sanitize_name(character_name)
        return os.path.join(self.SAVE_FOLDER, f"save_{sanitized_name}.json")

    def save_game(self, player):
        """
        Saves player progress to the appropriate file based on character name.
        """
        save_path = self.get_save_path(player.name)

        # Create the save data
        save_data = {
            "character_name": player.name,
            "level": player.level,
            "zone": player.zone,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "data": {
                "level": player.level,
                "current_exp": player.current_exp,
                "exp_to_next_level": player.exp_to_next_level,
                "talent_points": player.talent_points,
                "inventory": player.inventory,
            }
        }

        # Write to file
        with open(save_path, "w") as f:
            json.dump(save_data, f, indent=4)
        print(f"💾 Progress saved for {player.name} (Level {player.level})!")

    def load_game(self, character_name):
        """
        Loads player progress from a given character's save file.
        """
        save_path = self.get_save_path(character_name)

        if not os.path.exists(save_path):
            print(f"⚠️ No save found for character '{character_name}'.")
            return None

        with open(save_path, "r") as f:
            data = json.load(f)
            print(f"✅ Save loaded: {data}")
            return data

    def list_saves(self):
        """
        Lists all available save files with metadata.
        """
        print("\nAvailable Saves:")
        for filename in os.listdir(self.SAVE_FOLDER):
            if filename.endswith(".json") and filename.startswith("save_"):
                save_path = os.path.join(self.SAVE_FOLDER, filename)
                try:
                    metadata = self.get_save_metadata(save_path)
                    if metadata:
                        print(f"{filename}: {metadata['character_name']} (Level {metadata['level']}, {metadata['zone']}) - Last Saved: {metadata['timestamp']}")
                    else:
                        print(f"{filename}: [Corrupted Save]")
                except Exception as e:
                    print(f"{filename}: [Error reading file: {e}]")

    def get_save_metadata(self, save_path):
        """
        Returns metadata about a save file without loading full contents.
        """
        with open(save_path, "r") as f:
            data = json.load(f)
            return {
                "character_name": data.get("character_name", "Unknown"),
                "level": data.get("level", 1),
                "zone": data.get("zone", "Unknown"),
                "timestamp": data.get("timestamp", "Unknown")
            }

if __name__ == "__main__":
    # Example player class
    class Player:
        def __init__(self, name, level, zone):
            self.name = name
            self.level = level
            self.current_exp = 0
            self.exp_to_next_level = 100
            self.talent_points = 0
            self.inventory = {}
            self.zone = zone

    from command_parser import prompt_custom_character_name

    # Prompt character name
    character_name = prompt_custom_character_name()

    # Initialize player and save manager
    player = Player(character_name, 12, "Mistwood Forest")
    manager = SaveManager()

    # Save the game
    manager.save_game(player)

    # List all saves
    manager.list_saves()

    # Load a save
    save_data = manager.load_game(character_name)
    print("\nLoaded Save Data:", save_data)