import random
from exploration_zones import zones

class EncounterEngine:
    """
    Handles random encounters, mini-boss, and boss logic based on the current zone.
    """
    def __init__(self, player):
        self.player = player
        self.current_zone = None
        self.kill_count = 0

    def set_zone(self, zone_name):
        """
        Set the player's current zone and reset kill count.
        """
        if zone_name in zones:
            self.current_zone = zones[zone_name]
            self.kill_count = 0
            print(f"You have entered {self.current_zone.name}.")
            print(f"Recommended Level: {self.current_zone.recommended_level[0]}-{self.current_zone.recommended_level[1]}")
        else:
            print(f"Zone '{zone_name}' does not exist.")

    def generate_encounter(self):
        """
        Generate a random encounter in the current zone.
        """
        if not self.current_zone:
            print("You are not in a valid exploration zone.")
            return

        # Randomly select a monster or trigger a boss encounter
        if self.kill_count >= 10:
            # Trigger mini-boss or boss
            if self.kill_count >= 20:
                self.trigger_boss(self.current_zone.zone_boss)
            else:
                self.trigger_boss(self.current_zone.mini_boss)
        else:
            # Randomly select a monster from the zone
            monster = random.choices(
                self.current_zone.monsters, weights=[1] * len(self.current_zone.monsters), k=1
            )[0]
            self.start_combat(monster)

    def start_combat(self, monster):
        """
        Initialize combat with a monster.
        """
        print(f"\nA wild {monster.name} appeared! It looks dangerous...")
        print(f"Level: {monster.level}, HP: {monster.hp}, ATK: {monster.attack}, DEF: {monster.defense}")
        # Placeholder for combat system logic
        print("[Combat starts here...]\n")
        # Simulate a victory for development purposes
        print(f"You defeated the {monster.name}!")
        print(f"You received {monster.gold_reward} gold and {monster.exp_reward} experience points.")
        for drop in monster.drop_table:
            print(f"You loot: {drop}")
        self.player.gold += monster.gold_reward
        self.kill_count += 1

    def trigger_boss(self, boss):
        """
        Trigger a mini-boss or zone boss encounter.
        """
        print(f"\nWARNING: {boss.name} has appeared!")
        print(f"Level: {boss.level}, HP: {boss.hp}, ATK: {boss.attack}, DEF: {boss.defense}")
        # Placeholder for boss combat logic
        print("[Boss Combat starts here...]\n")
        # Simulate a victory for development purposes
        print(f"You defeated the {boss.name}!")
        print(f"You received {boss.gold_reward} gold and {boss.exp_reward} experience points.")
        for drop in boss.drop_table:
            print(f"You loot: {drop}")
        self.player.gold += boss.gold_reward
        # Reset kill count on mini-boss or boss defeat
        self.kill_count = 0

if __name__ == "__main__":
    # Example of using the EncounterEngine
    from player_integration import Player

    player = Player("Adventurer")
    encounter_engine = EncounterEngine(player)

    # Set the current zone to the Sunken Catacombs
    encounter_engine.set_zone("sunken_catacombs")

    for _ in range(25):  # Simulate multiple encounters
        encounter_engine.generate_encounter()

    # Switch to the Scorched Peaks
    encounter_engine.set_zone("scorched_peaks")

    for _ in range(15):  # Simulate additional encounters
        encounter_engine.generate_encounter()