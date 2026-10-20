from talent_tree import TalentTree, TalentNode

class Player:
    """
    Represents a player character with stats, inventory, and a talent system.
    """
    def __init__(self, name):
        self.name = name
        self.level = 1
        self.inventory = {}
        self.gold = 0
        self.base_stats = {
            "health": 100,
            "mana": 50,
            "crit_chance": 0.05,
            "armor": 10,
        }
        self.talent_points = 0
        self.talent_tree = self.initialize_talent_tree()
        self.active_abilities = []  # List of abilities unlocked through talents

    def initialize_talent_tree(self):
        """
        Create and initialize the player's talent tree.
        """
        tree = TalentTree()
        # Add Talent Nodes
        tree.add_node(TalentNode("crit_bonus", "Critical Strike Bonus", "+15% Crit Chance", 20, 1, False, [], {"crit_chance": 0.15}))
        tree.add_node(TalentNode("health_boost", "Health Boost", "+20% Max Health", 20, 1, False, [], {"max_health": 0.20}))
        tree.add_node(TalentNode("berserk", "Berserk", "High attack speed and damage for 3 turns.", 35, 3, True, ["crit_bonus", "health_boost"], {"new_ability": "berserk"}))
        return tree

    def gain_level(self):
        """
        Level up the player, granting talent points if applicable.
        """
        self.level += 1
        if 20 <= self.level <= 35:
            self.talent_points += 1
            print(f"You have gained a Talent Point! Total: {self.talent_points}")

    def allocate_talent(self, talent_id):
        """
        Allocate talent points to a specific talent node.
        """
        success, result = self.talent_tree.unlock_talent(talent_id, self.talent_points)
        if success:
            self.talent_points -= result
            print(f"Successfully unlocked '{self.talent_tree.get_node(talent_id).name}'.")
            if self.talent_tree.get_node(talent_id).is_active:
                self.active_abilities.append(self.talent_tree.get_node(talent_id).bonuses["new_ability"])
        else:
            print(result)

    def reset_talents(self):
        """
        Reset all talent allocations (respec) by spending gold.
        """
        respec_cost = 100  # Arbitrary gold cost for respec
        if self.gold >= respec_cost:
            self.gold -= respec_cost
            self.talent_points += self.talent_tree.get_total_points_allocated()
            for node in self.talent_tree.talent_nodes:
                node.is_unlocked = False
            print("Your talent points have been reset.")
        else:
            print("You do not have enough gold to reset talents.")

if __name__ == "__main__":
    # Example usage of the player with talents
    player = Player("Adventurer")

    # Simulate gaining levels and receiving talent points
    for _ in range(20, 36):
        player.gain_level()

    # Display current talents
    player.talent_tree.display()

    # Allocate points
    player.allocate_talents("crit_bonus")
    player.allocate_talents("health_boost")

    # Attempt to allocate a tier-4 talent
    player.allocate_talents("berserk")

    # Respec talents by resetting
    player.gold = 150
    player.reset_talents()

    # Display tree again
    player.talent_tree.display()