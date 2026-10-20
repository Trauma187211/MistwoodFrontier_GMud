from player_with_talents import Player

class CombatEngine:
    """
    Handles combat mechanics, including turn-based combat and abilities.
    """
    def __init__(self, player):
        self.player = player

    def display_actions(self):
        """
        Display available combat actions.
        """
        print("\nAvailable Combat Actions:")
        print("[1] Attack")
        print("[2] Defend")
        for idx, ability in enumerate(self.player.active_abilities, start=3):
            print(f"[{idx}] {ability.capitalize()}")

    def execute_action(self, action):
        """
        Execute the selected combat action.
        """
        if action == "1":
            print("You perform a basic attack!")
        elif action == "2":
            print("You prepare to defend next turn!")
        else:
            # Map active abilities
            ability_index = int(action) - 3
            if 0 <= ability_index < len(self.player.active_abilities):
                ability = self.player.active_abilities[ability_index]
                print(f"You use the ability: {ability.capitalize()}!")
                # Placeholder for ability logic (e.g., cooldown, resource cost)
            else:
                print("Invalid action. No such ability.")

if __name__ == "__main__":
    # Example player setup
    player = Player("Hero")
    player.active_abilities = ["berserk", "execute"]

    combat_engine = CombatEngine(player)

    # Simulate a combat loop
    while True:
        combat_engine.display_actions()
        action = input("Choose your action: ").strip()

        if action.lower() == "quit":
            print("Exiting combat.")
            break

        combat_engine.execute_action(action)