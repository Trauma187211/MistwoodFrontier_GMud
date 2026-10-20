from player_with_talents import Player

class TalentUI:
    """
    Handles the display and allocation of talent points using commands.
    """
    def __init__(self, player):
        self.player = player

    def display_talents(self):
        """
        Display the player's talent tree and available points.
        """
        print(f"\n{self.player.name}'s Talent Tree")
        print(f"Available Talent Points: {self.player.talent_points}")
        self.player.talent_tree.display()

    def allocate_talent(self):
        """
        Simulate talent allocation for testing.
        """
        self.display_talents()
        test_choices = ["crit_bonus", "health_boost", "berserk"]  # Simulated test input
        for choice in test_choices:
            print(f"Attempting to unlock talent: {choice}")
            try:
                self.player.allocate_talent(choice)
            except ValueError as e:
                print(e)
        print("Talent allocation test complete.")

if __name__ == "__main__":
    # Example usage of TalentUI
    player = Player("Hero")

    # Simulate player gaining levels and talent points
    for _ in range(20, 36):
        player.gain_level()

    talent_ui = TalentUI(player)

    # Example: Player interacts with talents
    talent_ui.allocate_talent()