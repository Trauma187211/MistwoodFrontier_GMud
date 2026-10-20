from room_state import RoomState
from command_parser import CommandParser

class GameWorld:
    """
    Manages the world state, room transitions, and dynamic interactions.
    """
    def __init__(self):
        self.rooms = self.create_rooms()
        self.current_room = self.rooms["start"]  # Starting room

    def create_rooms(self):
        """
        Define the rooms and their interconnections.
        """
        return {
            "start": RoomState(
                "You are in a small village at the base of Mistwood Forest.",
                {"north": True, "south": False, "east": True, "west": False},
                has_mob=False,
                gathering_node="herbs"
            ),
            "forest": RoomState(
                "You are in the dense Mistwood Forest. The trees block out most of the light.",
                {"north": False, "south": True, "east": False, "west": False},
                has_mob=True,
                mob=type("Mob", (object,), {"name": "Forest Spider"})()
            ),
        }

    def parse_command(self, raw_input, player):
        """
        Handle user commands parsed via the CommandParser.
        """
        command = CommandParser.normalize_command(raw_input)

        if not command:
            print("Unknown command. Type 'help' for available options.")
            return

        if command in ["forward", "back", "left", "right"]:
            self.move_player(command)
        elif command == "look":
            self.current_room.look_around()
        elif command == "gather":
            self.current_room.gather_resources(player)
        elif command == "help":
            print("List of commands (Invoke help manager here).")
            # HelpManager.display_help() # Uncomment once integrated
        else:
            print("Command not yet implemented.")

    def move_player(self, direction):
        """
        Move the player to a new room if an exit exists.
        """
        if self.current_room.move(direction):
            # Determine new room based on direction
            if direction == "north":
                self.current_room = self.rooms.get("forest", self.current_room)
            elif direction == "south":
                self.current_room = self.rooms.get("start", self.current_room)
            # Add additional logic for other directions
        else:
            print("You cannot go that way.")

if __name__ == "__main__":
    from player_integration import Player

    player = Player("Explorer")
    game_world = GameWorld()

    print("Welcome to Mistwood Frontiers!")
    game_world.current_room.look_around()

    print("Automated playtest starting...")
    commands = ["look", "gather", "north", "look", "gather", "east", "look", "exit"]
    for user_input in commands:
        print(f"\nCommand: {user_input}")
        if user_input == "exit":
            print("Exiting the game. Goodbye!")
            break
        game_world.parse_command(user_input, player)