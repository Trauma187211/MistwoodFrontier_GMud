class RoomState:
    """
    Tracks the state of a room, including gathering nodes and mobs.
    """
    def __init__(self, description, exits, has_mob=False, mob=None, gathering_node=None):
        self.description = description  # Room description
        self.exits = exits  # Dictionary of possible exits, e.g., {"north": True, "south": False}
        self.has_mob = has_mob  # If a mob is present in the room
        self.mob = mob  # The mob object, if any
        self.gathering_node = gathering_node  # The type of gathering resource: herbs, ores, etc.
        self.node_depleted = False  # Whether the gathering node is depleted

    def look_around(self):
        """
        Display the description and state of the room.
        """
        print(self.description)
        print("Exits:")
        for direction, accessible in self.exits.items():
            if accessible:
                print(f" - {direction}")
        if self.has_mob:
            print(f"There is a dangerous {self.mob.name} here! Be careful.")
        elif self.gathering_node and not self.node_depleted:
            print(f"You notice a {self.gathering_node} here ready to gather.")

    def gather_resources(self, player):
        """
        Handle gathering resources in the room.
        """
        if self.has_mob:
            print("You must defeat the mob in the room before gathering resources.")
            return

        if self.gathering_node and not self.node_depleted:
            print(f"You gather resources from the {self.gathering_node}...")
            # Assume we add items to the player's inventory
            player.inventory[self.gathering_node] = player.inventory.get(self.gathering_node, 0) + 1
            self.node_depleted = True
            print(f"You have collected {self.gathering_node}!")
        elif self.gathering_node:
            print(f"The {self.gathering_node} has already been gathered.")
        else:
            print("There are no resources to gather here.")

    def move(self, direction):
        """
        Handles movement within the room based on exits.
        """
        if self.exits.get(direction):
            print(f"You move {direction}.")
            return True  # Movement successful
        else:
            print("*You bump straight into a solid wall!*")
            return False  # Movement unsuccessful

if __name__ == "__main__":
    # Example usage
    room = RoomState(
        "You are in a dark cave. The walls glisten with moisture.",
        {
            "north": True,
            "south": False,
            "east": True,
            "west": False
        },
        has_mob=True,
        mob=type("Mob", (object,), {"name": "Cave Spider"})(),
        gathering_node="ore"
    )

    room.look_around()
    room.move("north")
    room.move("south")
    room.gather_resources(type("Player", (object,), {"inventory": {}})())