class TalentNode:
    """
    Represents a single talent node with unlock conditions and bonuses.
    """
    def __init__(self, id, name, description, tier, cost, is_active, unlock_requirements=None, bonuses=None):
        self.id = id
        self.name = name
        self.description = description
        self.tier = tier  # Tier level (20, 25, 30, 35)
        self.cost = cost  # Points required to unlock
        self.is_active = is_active  # True if it unlocks an active ability
        self.unlock_requirements = unlock_requirements or []  # List of dependent TalentNode IDs
        self.bonuses = bonuses or {}  # Dict of stat bonuses or ability added
        self.is_unlocked = False

class TalentTree:
    """
    Manages a tree of talent nodes for the player, including talent allocation.
    """
    def __init__(self):
        self.talent_nodes = []  # A list of TalentNode objects

    def add_node(self, talent_node):
        """Add a new talent node to the tree."""
        self.talent_nodes.append(talent_node)

    def display(self):
        """Display the talent tree structure."""
        print("Talent Tree:")
        for node in self.talent_nodes:
            status = "[X]" if node.is_unlocked else "[ ]"
            print(f"{status} Tier {node.tier}: {node.name} ({node.description})")

    def validate_unlock(self, node_id, available_points):
        """
        Validates if a talent node can be unlocked.
        """
        node = self.get_node(node_id)
        if node.is_unlocked:
            return False, "Talent is already unlocked."
        if node.tier * 5 > self.get_total_points_allocated() + available_points:
            return False, f"You cannot unlock this talent until you reach Level {node.tier}."

        for req in node.unlock_requirements:
            prerequisite = self.get_node(req)
            if not prerequisite.is_unlocked:
                return False, f"Prerequisite Talent '{prerequisite.name}' is not unlocked."

        if node.cost > available_points:
            return False, "Not enough talent points."

        return True, None

    def unlock_talent(self, node_id, available_points):
        """
        Unlock a talent node and deduct the points.
        """
        node = self.get_node(node_id)
        can_unlock, reason = self.validate_unlock(node_id, available_points)
        if can_unlock:
            node.is_unlocked = True
            return True, node.cost
        else:
            return False, reason

    def get_node(self, node_id):
        """Retrieve a talent node by ID."""
        for node in self.talent_nodes:
            if node.id == node_id:
                return node
        raise ValueError(f"Talent Node with ID {node_id} not found.")

    def get_total_points_allocated(self):
        """Calculate the total talent points spent."""
        return sum(node.cost for node in self.talent_nodes if node.is_unlocked)

if __name__ == "__main__":
    # Example of TalentTree usage
    tree = TalentTree()

    # Adding nodes to the tree
    tree.add_node(TalentNode("crit_bonus", "Critical Strike Bonus", "+15% Crit Chance", 20, 1, False, [], {"crit_chance": 0.15}))
    tree.add_node(TalentNode("health_boost", "Health Boost", "+20% Max Health", 20, 1, False, [], {"max_health": 0.20}))
    tree.add_node(TalentNode("berserk", "Berserk", "High attack speed and damage for 3 turns.", 35, 3, True, ["crit_bonus", "health_boost"], {"new_ability": "berserk"}))

    # Displaying the tree
    tree.display()

    # Attempt to unlock talents
    points = 5
    success, result = tree.unlock_talent("crit_bonus", points)
    if success:
        points -= result
        print("Successfully unlocked 'Critical Strike Bonus'.")
    else:
        print(result)

    success, result = tree.unlock_talent("berserk", points)
    if success:
        points -= result
        print("Successfully unlocked 'Berserk'.")
    else:
        print(result)

    tree.display()