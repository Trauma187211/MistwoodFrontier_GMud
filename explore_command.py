from encounter_engine import EncounterEngine
from exploration_zones import zones

class ExploreCommand:
    """
    Handles the player's exploration commands, integrating exploration zones with encounters.
    """
    def __init__(self, player):
        self.player = player
        self.encounter_engine = EncounterEngine(self.player)

    def explore(self, zone_name):
        """
        Begin exploration in a specified zone and handle encounter generation.
        """
        if zone_name not in zones:
            print(f"Zone '{zone_name}' does not exist.")
            return

        self.encounter_engine.set_zone(zone_name)

        print("Auto-testing exploration events...")
        for _ in range(5):
            self.encounter_engine.generate_encounter()
        print(f"Testing complete. You have left {zone_name}.")

if __name__ == "__main__":
    from player_integration import Player

    player = Player("Adventurer")

    # Example of using the ExploreCommand
    explore_command = ExploreCommand(player)

    print("Available Zones:")
    for zone_name, zone in zones.items():
        print(f" - {zone_name.title()} (Level {zone.recommended_level[0]}-{zone.recommended_level[1]})")

    selected_zone = "sunken_catacombs"
    print(f"Auto-selected zone for testing: {selected_zone}")
    explore_command.explore(selected_zone)