class GameConfig:
    """
    Stores global game configuration, including the level cap.
    """
    MAX_LEVEL = 35

class Player:
    """
    Represents a player character, including XP, level, and progression.
    """
    def __init__(self, name):
        self.name = name
        self.level = 1
        self.current_exp = 0
        self.exp_to_next_level = 100  # Example scaling, grows per level
        self.talent_points = 0

    def gain_experience(self, amount):
        """
        Adds experience and handles leveling up if applicable.
        """
        if self.level >= GameConfig.MAX_LEVEL:
            self.current_exp = 0
            print(f"🌟 You are at MAX LEVEL ({GameConfig.MAX_LEVEL})! Experience capped.")
            return

        print(f"You gain {amount} XP!")
        self.current_exp += amount

        while self.current_exp >= self.exp_to_next_level and self.level < GameConfig.MAX_LEVEL:
            self.level_up()

        # Cap current_exp at the max target for the last level
        if self.level >= GameConfig.MAX_LEVEL:
            self.current_exp = self.exp_to_next_level

        print(f"Current XP: {self.current_exp}/{self.exp_to_next_level}")

    def level_up(self):
        """
        Handles the logic for leveling up the player.
        """
        self.level += 1
        self.current_exp -= self.exp_to_next_level

        # Adjust exp_to_next_level (example scaling)
        self.exp_to_next_level = int(self.exp_to_next_level * 1.25)

        print(f"🎉 Level Up! You are now Level {self.level}.")

        # Grant talent points for levels between 20 and MAX_LEVEL
        if 20 <= self.level <= GameConfig.MAX_LEVEL:
            self.talent_points += 1
            print(f"You have gained a Talent Point! Total Talent Points: {self.talent_points}")

        # Handle max level logic
        if self.level == GameConfig.MAX_LEVEL:
            self.exp_to_next_level = 0
            print("🌟 Congratulations! You have reached MAX LEVEL. Prepare for endgame content!")

if __name__ == "__main__":
    # Example usage of Player progression with level cap
    player = Player("Hero")

    # Simulate experience gain
    exp_rewards = [50, 100, 200, 300, 5000]  # A mixture of small and large XP amounts
    for exp in exp_rewards:
        player.gain_experience(exp)

    print("\nChanging max level to 40 for expansion...")
    GameConfig.MAX_LEVEL = 40

    # Simulate post-expansion progression
    player.gain_experience(10000)