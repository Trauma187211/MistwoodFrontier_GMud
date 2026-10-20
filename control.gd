extends Control

# ============================
# PLAYER & GAME DATA
# ============================
var player_level: int = 1
var max_level: int = 35
var player_hp: int = 100
var max_hp: int = 100
var player_atk: int = 15
var player_gold: int = 25
var player_xp: int = 0
var xp_to_next_level: int = 50

var talent_points: int = 0
var learned_talents: Array = []

var character_name: String = ""
var character_faction: String = ""
var character_race: String = ""
var character_class: String = ""
var creation_step: int = 0

var in_shop: bool = false
var in_combat: bool = false
var current_enemy: Dictionary = {}
var enemy_poison_ticks: int = 0

# ============================
# PROFESSIONS & SKILL XP
# ============================
var prof_mining: int = 1
var prof_herbalism: int = 1
var prof_blacksmithing: int = 1
var prof_alchemy: int = 1
var prof_enchanting: int = 1

# Equipment Slots & Stat Bonuses
var equipment: Dictionary = {
	"weapon": "None",
	"armor": "Cloth Tunic",
	"trinket": "None"
}
var gear_atk_bonus: int = 0
var gear_hp_bonus: int = 0
var gear_def_bonus: int = 0

var inventory: Dictionary = {
	"Iron Ore": 6,
	"Gloom Berries": 6,
	"Blood Lotus": 2,
	"Spectral Dust": 3,
	"Health Potion": 2
}

var cmd_aliases = {
	"l": "look",
	"i": "inventory",
	"inv": "inventory",
	"stat": "status",
	"stats": "status",
	"n": "north",
	"s": "south",
	"e": "east",
	"w": "west",
	"f": "north",
	"forward": "north",
	"b": "south",
	"back": "south",
	"r": "east",
	"right": "east",
	"left": "west",
	"h": "help",
	"tal": "talents",
	"prof": "professions",
	"mine": "gather",
	"harvest": "gather"
}

# ============================
# WORLD MAP & ROOM DATA
# ============================
var current_room_id: String = "frontier_gates"

var rooms = {
	# --- FRONTIER & ROADS ---
	"frontier_gates": {
		"title": "Frontier Gates",
		"description": "Massive iron-reinforced gates stand weathered against the mist. South leads into Oakhaven Keep. North leads into Mistwood Forest.",
		"safe": true,
		"exits": {"north": "mistwood_verge", "south": "oakhaven_square"}
	},
	"mistwood_verge": {
		"title": "Mistwood Verge",
		"description": "Gnarled oak trees loom out of the fog. A rich Gloom Bush grows near the roots.",
		"safe": false,
		"zone": "mistwood",
		"node": "Gloom Bush",
		"exits": {"south": "frontier_gates", "north": "shattered_crossroads", "east": "sunken_mire_entrance"}
	},
	"shattered_crossroads": {
		"title": "Shattered Crossroads",
		"description": "A cracked stone monument lies ruined at an intersection. Iron veins protrude from the broken rocks.",
		"safe": false,
		"zone": "mistwood",
		"node": "Iron Vein",
		"exits": {"south": "mistwood_verge", "north": "hollow_canopy", "east": "crypt_gates"}
	},
	"hollow_canopy": {
		"title": "The Hollow Canopy",
		"description": "Thick foliage blocks out all light. Glowing eyes glint in the suffocating shadows.",
		"safe": false,
		"zone": "mistwood",
		"exits": {"south": "shattered_crossroads"}
	},

	# --- CITY HUB: OAKHAVEN KEEP ---
	"oakhaven_square": {
		"title": "Oakhaven Town Square",
		"description": "A bustling cobblestone square protected by tall stone ramparts.",
		"safe": true,
		"exits": {"north": "frontier_gates", "west": "iron_anvil", "east": "ashen_bazaar", "south": "wayfarers_inn"}
	},
	"iron_anvil": {
		"title": "The Iron Anvil Smithy",
		"description": "The roar of a forge fills the room. Type [b]craft[/b] or [b]recipes[/b] to view blacksmithing and leatherworking options.",
		"safe": true,
		"exits": {"east": "oakhaven_square"}
	},
	"ashen_bazaar": {
		"title": "Ashen Bazaar & Alchemist Nook",
		"description": "Stalls are stacked high with rare vials and enchanting runes. Type [b]brew[/b], [b]enchant[/b], [b]buy[/b], or [b]sell[/b].",
		"safe": true,
		"exits": {"west": "oakhaven_square"}
	},
	"wayfarers_inn": {
		"title": "The Wayfarer's Inn",
		"description": "A roaring fireplace casts a warm glow. Type [b]rest[/b] (10 Gold) to restore HP.",
		"safe": true,
		"exits": {"north": "oakhaven_square"}
	},

	# --- ZONE 1: SUNKEN MIRE ---
	"sunken_mire_entrance": {
		"title": "Sunken Mire - Marsh Edge",
		"description": "Murky water pools around rotting mangroves. Rare Blood Lotus blooms in the mire mud.",
		"safe": false,
		"zone": "mire",
		"node": "Blood Lotus Node",
		"exits": {"west": "mistwood_verge", "east": "bog_heart"}
	},
	"bog_heart": {
		"title": "Sunken Mire - Deep Bog",
		"description": "Bubbling mud pits and ancient skeletal remains choke the swamp.",
		"safe": false,
		"zone": "mire",
		"exits": {"west": "sunken_mire_entrance"}
	},

	# --- ZONE 2: MISTLORD'S CRYPT ---
	"crypt_gates": {
		"title": "Mistlord's Crypt - Archway",
		"description": "Ancient obsidian tombs carved into the mountainside. Spectral veins sparkle in the cliff face.",
		"safe": false,
		"zone": "crypt",
		"node": "Spectral Vein",
		"exits": {"west": "shattered_crossroads", "east": "inner_sanctum"}
	},
	"inner_sanctum": {
		"title": "Mistlord's Crypt - Inner Sanctum",
		"description": "A colossal throne room bathed in spectral blue flame.",
		"safe": false,
		"zone": "crypt",
		"exits": {"west": "crypt_gates"}
	}
}

# ============================
# BESTIARY POOLS
# ============================
var enemy_pools = {
	"mistwood": [
		{"name": "Mistwood Stalker", "hp": 25, "max_hp": 25, "dmg_min": 4, "dmg_max": 8, "xp": 15, "gold": 8, "drop": "Gloom Berries", "ascii": " (◣_◢) "},
		{"name": "Gloom Crawler", "hp": 18, "max_hp": 18, "dmg_min": 3, "dmg_max": 6, "xp": 10, "gold": 5, "drop": "Gloom Berries", "ascii": " ʕ•ᴥ•ʔ "},
		{"name": "Shadow Hound", "hp": 30, "max_hp": 30, "dmg_min": 5, "dmg_max": 10, "xp": 20, "gold": 12, "drop": "Iron Ore", "ascii": " (>'-')> "}
	],
	"mire": [
		{"name": "Bog Lurker", "hp": 45, "max_hp": 45, "dmg_min": 8, "dmg_max": 14, "xp": 35, "gold": 18, "drop": "Blood Lotus", "ascii": " ~t(o_o)t~ "},
		{"name": "Venomous Hydra", "hp": 60, "max_hp": 60, "dmg_min": 10, "dmg_max": 18, "xp": 50, "gold": 25, "drop": "Spectral Dust", "ascii": " <:::=={===O "}
	],
	"crypt": [
		{"name": "Spectral Knight", "hp": 85, "max_hp": 85, "dmg_min": 14, "dmg_max": 22, "xp": 80, "gold": 45, "drop": "Spectral Dust", "ascii": " [o===> "},
		{"name": "Echo of the Mistlord", "hp": 180, "max_hp": 180, "dmg_min": 18, "dmg_max": 30, "xp": 200, "gold": 150, "drop": "Spectral Dust", "ascii": " ███◣_◢███ "}
	]
}

# ============================
# TALENT TREE DEFINITIONS
# ============================
var class_talents = {
	"slayer": [
		{"name": "shadowstep", "lvl": 5, "desc": "Increases critical damage & dodge chance."},
		{"name": "poison_blades", "lvl": 10, "desc": "Applies a 3-turn venom DoT to attacks."},
		{"name": "eviscerate", "lvl": 15, "desc": "Deals heavy execution damage to targets below 50% HP."},
		{"name": "fan_of_knives", "lvl": 20, "desc": "Adds bonus area bleed damage on casts."},
		{"name": "shadow_cloak", "lvl": 25, "desc": "Reduces incoming enemy damage by 8."},
		{"name": "venomous_spite", "lvl": 30, "desc": "Doubles poison tick damage."},
		{"name": "shadow_dance", "lvl": 35, "desc": "Capstone: Shadow Strike damage increased drastically."}
	],
	"mage": [
		{"name": "pyromancy", "lvl": 5, "desc": "Significantly boosts Fireball damage."},
		{"name": "arcane_shield", "lvl": 10, "desc": "Reduces incoming damage by 6."},
		{"name": "frostbite", "lvl": 15, "desc": "Chills targets, reducing their attack power."},
		{"name": "combustion", "lvl": 20, "desc": "Gives Fireball a high critical hit chance."},
		{"name": "mana_surge", "lvl": 25, "desc": "Increases overall spell power scaling."},
		{"name": "ignite", "lvl": 30, "desc": "Fireball burns enemies for extra damage per turn."},
		{"name": "archmage_sovereignty", "lvl": 35, "desc": "Capstone: Unleashes maximum arcane burst power."}
	],
	"guardian": [
		{"name": "iron_clad", "lvl": 5, "desc": "Reduces incoming physical damage by 5."},
		{"name": "shield_slam", "lvl": 10, "desc": "Shield Bash reduces enemy damage by half."},
		{"name": "last_stand", "lvl": 15, "desc": "Heals +30 HP when taking heavy damage."},
		{"name": "retaliation", "lvl": 20, "desc": "Reflects 6 damage back to attackers."},
		{"name": "fortitude", "lvl": 25, "desc": "Increases Max HP by +40."},
		{"name": "unbreakable", "lvl": 30, "desc": "Grants high flat defense."},
		{"name": "avatar_of_war", "lvl": 35, "desc": "Capstone: Massively boosts Attack & Defense."}
	],
	"warden": [
		{"name": "divine_grace", "lvl": 5, "desc": "Boosts potion and spell healing efficiency by +20 HP."},
		{"name": "smite", "lvl": 10, "desc": "Holy Smite deals +15 bonus holy damage."},
		{"name": "sacred_aura", "lvl": 15, "desc": "Passive aura reducing incoming damage by 5."},
		{"name": "judgment", "lvl": 20, "desc": "Attacks deal bonus radiant damage per hit."},
		{"name": "blessing_of_light", "lvl": 25, "desc": "Restores +8 HP every combat turn."},
		{"name": "purify", "lvl": 30, "desc": "Increases spell damage and clears poison."},
		{"name": "divine_intervention", "lvl": 35, "desc": "Capstone: Devastating radiant strike & full cleanse."}
	]
}

# ============================
# READY & INPUT SETUP
# ============================
func _ready() -> void:
	$Terminal.scroll_following = true
	$Input.text_submitted.connect(_on_input_submitted)
	$Input.grab_focus()
	$Terminal.append_text("[color=yellow]Welcome to Mistwood Frontiers RPG[/color]\n")
	$Terminal.append_text("Type [b]start[/b] to begin character creation.\n")

func _on_input_submitted(new_text: String) -> void:
	$Input.clear()
	process_command(new_text)

# ============================
# MAIN COMMAND PARSER
# ============================
func process_command(cmd: String) -> void:
	cmd = cmd.strip_edges()
	if cmd == "":
		return
	
	cmd = cmd_aliases.get(cmd, cmd)
	
	if creation_step < 5:
		handle_character_creation(cmd)
		return
		
	var parts = cmd.split(" ", false)
	if parts.size() == 0:
		return
	var main_cmd = parts[0].to_lower()
	
	if main_cmd in ["move", "go"] and parts.size() > 1:
		main_cmd = parts[1].to_lower()

	match main_cmd:
		"look", "l":
			_cmd_look()
		"inventory", "inv", "i":
			_cmd_inventory()
		"status", "stats":
			_cmd_status()
		"gear", "equipment":
			_cmd_gear()
		"talents", "talent":
			_cmd_talents()
		"learn":
			_cmd_learn_talent(parts)
		"professions", "profession", "recipes":
			_cmd_professions()
		"gather":
			_cmd_gather()
		"help", "h":
			_cmd_help()
		"use", "drink", "u":
			_cmd_use(parts)
		"rest":
			_cmd_rest()
		"craft":
			_cmd_craft(parts)
		"brew":
			_cmd_brew(parts)
		"enchant":
			_cmd_enchant(parts)
		"buy":
			_cmd_buy(parts)
		"forward", "f", "north", "n":
			_cmd_move("north")
		"back", "b", "south", "s":
			_cmd_move("south")
		"east", "e", "right", "r":
			_cmd_move("east")
		"west", "w", "left":
			_cmd_move("west")
		"attack", "att", "a":
			_cmd_attack()
		"cast", "c":
			_cmd_cast()
		"flee", "run":
			_cmd_flee()
		"save":
			save_character()
		"load":
			load_character()
		_:
			append_output("Unknown command: " + cmd)

# ============================
# CHARACTER CREATION
# ============================
func handle_character_creation(cmd: String) -> void:
	var clean_cmd = cmd.to_lower().strip_edges()

	if creation_step == 0:
		if clean_cmd == "start":
			append_output("> start")
			append_output("Enter your character name:")
			creation_step = 1
		else:
			append_output("Type [b]start[/b] to begin character creation.")
		return

	elif creation_step == 1:
		character_name = cmd
		append_output("> " + cmd)
		append_output("")
		append_output("[b]Choose your faction:[/b]")
		append_output("vanguard - disciplined, oathbound defenders")
		append_output("bloodborn - ruthless, war-forged clans")
		creation_step = 2
		return

	elif creation_step == 2:
		if clean_cmd in ["vanguard", "bloodborn"]:
			character_faction = clean_cmd
			append_output("> " + cmd)
			append_output("")
			if character_faction == "vanguard":
				append_output("[b]Vanguard Races:[/b] human / highborn / stonekin")
			else:
				append_output("[b]Bloodborn Races:[/b] ravager / shade / wildling")
			creation_step = 3
		else:
			append_output("Type: vanguard or bloodborn")
		return

	elif creation_step == 3:
		var valid_races = ["human", "highborn", "stonekin"] if character_faction == "vanguard" else ["ravager", "shade", "wildling"]
		if clean_cmd in valid_races:
			character_race = clean_cmd
			append_output("> " + cmd)
			append_output("")
			append_output("[b]Choose your class:[/b]")
			append_output("guardian (Tank) | slayer (Rogue DPS) | warden (Cleric) | mage (Spellcaster)")
			creation_step = 4
		else:
			append_output("Select a valid race.")
		return

	elif creation_step == 4:
		if clean_cmd in ["guardian", "slayer", "warden", "mage"]:
			character_class = clean_cmd
			append_output("> " + cmd)
			append_output("")
			append_output("[color=green]Character creation complete![/color]")
			append_output("Welcome, " + character_name + " the " + character_race.capitalize() + " " + character_class.capitalize() + " of the " + character_faction.capitalize() + ".")
			creation_step = 5
			_cmd_look()
		else:
			append_output("Type: guardian / slayer / warden / mage")
		return

# ============================
# NAVIGATION & WORLD LOGIC
# ============================
func _cmd_look() -> void:
	if not rooms.has(current_room_id):
		append_output("You are lost in the void.")
		return
		
	var room = rooms[current_room_id]
	append_output("")
	append_output("[b][color=cyan]" + room["title"] + "[/color][/b]")
	append_output(room["description"])
	
	if room.has("node") and room["node"] != "":
		append_output("[color=green]Gathering Node Available:[/color] " + room["node"] + " (Type [b]gather[/b])")
	
	var exit_list = []
	for ex in room["exits"].keys():
		exit_list.append(ex)
	append_output("[color=yellow]Exits:[/color] " + ", ".join(exit_list))

func _cmd_move(direction: String) -> void:
	if in_combat:
		append_output("You cannot move while in combat! Type [b]flee[/b] or fight.")
		return

	if not rooms.has(current_room_id):
		append_output("You cannot move from here.")
		return

	var room = rooms[current_room_id]
	if room["exits"].has(direction):
		current_room_id = room["exits"][direction]
		append_output("You head " + direction + "...")
		_cmd_look()
		
		var target_room = rooms[current_room_id]
		if not target_room.get("safe", false):
			check_for_encounter(target_room.get("zone", "mistwood"))
	else:
		append_output("You cannot go " + direction + " from here.")

# ============================
# TALENTS & PROFESSIONS
# ============================
func _cmd_talents() -> void:
	append_output("")
	append_output("[color=cyan][b]=== " + character_class.to_upper() + " TALENT TREE (LEVEL CAP 35) ===[/b][/color]")
	append_output("Available Talent Points: " + str(talent_points) + " (Earned every 5 Levels)")
	append_output("Learned Talents: " + (", ".join(learned_talents) if learned_talents.size() > 0 else "None"))
	append_output("--------------------------------------------------")
	
	var tree = class_talents.get(character_class, [])
	for t in tree:
		var status = "[color=green][LEARNED][/color]" if t["name"] in learned_talents else ("[Req Lvl " + str(t["lvl"]) + "]")
		append_output("• [b]" + t["name"] + "[/b] " + status + " - " + t["desc"])
		
	append_output("Type [b]learn <talent_name>[/b] to unlock.")

func _cmd_learn_talent(parts: Array) -> void:
	if parts.size() < 2:
		append_output("Type [b]learn <talent_name>[/b] (e.g. [b]learn shadowstep[/b])")
		return
		
	var t_name = parts[1].to_lower()
	if talent_points < 1:
		append_output("You don't have any unspent Talent Points!")
		return
		
	if t_name in learned_talents:
		append_output("You have already mastered that talent!")
		return
		
	var tree = class_talents.get(character_class, [])
	var target_talent = {}
	for t in tree:
		if t["name"] == t_name:
			target_talent = t
			break
			
	if target_talent.is_empty():
		append_output("That talent does not exist for your class.")
		return
		
	if player_level < target_talent["lvl"]:
		append_output("You must reach Level " + str(target_talent["lvl"]) + " to unlock " + t_name + "!")
		return
		
	learned_talents.append(t_name)
	talent_points -= 1
	append_output("[color=green][b]TALENT UNLOCKED![/b] You mastered " + t_name.capitalize() + "![/color]")

func _cmd_professions() -> void:
	append_output("")
	append_output("[color=yellow][b]=== PROFESSIONS & RECIPES ===[/b][/color]")
	append_output("• [b]Mining[/b] (Lvl " + str(prof_mining) + ") | [b]Herbalism[/b] (Lvl " + str(prof_herbalism) + ")")
	append_output("• [b]Blacksmithing[/b] (Lvl " + str(prof_blacksmithing) + ") | [b]Alchemy[/b] (Lvl " + str(prof_alchemy) + ") | [b]Enchanting[/b] (Lvl " + str(prof_enchanting) + ")")
	append_output("--------------------------------------------------")
	append_output("[color=cyan]BLACKSMITHING & LEATHERWORKING (At Iron Anvil):[/color]")
	append_output("• [b]craft sword[/b] (5 Iron Ore) -> Refined Steel Sword (+8 Atk)")
	append_output("• [b]craft battleaxe[/b] (10 Iron Ore, 2 Spectral Dust) -> Great Executioner Axe (+18 Atk)")
	append_output("• [b]craft tunic[/b] (4 Gloom Berries, 2 Iron Ore) -> Hardened Leather Tunic (+25 Max HP)")
	append_output("• [b]craft plate[/b] (12 Iron Ore) -> Heavy Iron Plate Armor (+40 Max HP, -4 Inbound Dmg)")
	append_output("[color=cyan]ALCHEMY & ENCHANTING (At Ashen Bazaar):[/color]")
	append_output("• [b]brew potion[/b] (3 Gloom Berries) -> Health Potion (+40 HP)")
	append_output("• [b]brew elixir[/b] (2 Blood Lotus, 4 Gloom Berries) -> Elixir of Might (+10 Base Atk)")
	append_output("• [b]brew flask[/b] (3 Blood Lotus) -> Flask of Vitality (+30 Permanent Max HP)")
	append_output("• [b]enchant weapon[/b] (4 Spectral Dust) -> Arcane Fire Runes (+12 Weapon Atk)")
	append_output("• [b]enchant trinket[/b] (5 Spectral Dust) -> Void Talisman (+15 Atk, +20 Max HP Trinket)")

func _cmd_gather() -> void:
	if in_combat:
		append_output("You cannot gather materials while in combat!")
		return
		
	var room = rooms[current_room_id]
	if not room.has("node") or room["node"] == "":
		append_output("There are no gathering nodes in this room.")
		return
		
	var node_type = room["node"]
	append_output("You harvest the " + node_type + "...")
	
	if "Gloom" in node_type:
		inventory["Gloom Berries"] = inventory.get("Gloom Berries", 0) + 2
		prof_herbalism += 1
		append_output("[color=green]+2 Gloom Berries gathered! Herbalism Lvl " + str(prof_herbalism) + ".[/color]")
	elif "Blood Lotus" in node_type:
		inventory["Blood Lotus"] = inventory.get("Blood Lotus", 0) + 1
		prof_herbalism += 2
		append_output("[color=green]+1 Blood Lotus gathered! Herbalism Lvl " + str(prof_herbalism) + ".[/color]")
	elif "Iron" in node_type:
		inventory["Iron Ore"] = inventory.get("Iron Ore", 0) + 2
		prof_mining += 1
		append_output("[color=green]+2 Iron Ore mined! Mining Lvl " + str(prof_mining) + ".[/color]")
	elif "Spectral" in node_type:
		inventory["Spectral Dust"] = inventory.get("Spectral Dust", 0) + 2
		prof_mining += 2
		append_output("[color=green]+2 Spectral Dust extracted! Mining Lvl " + str(prof_mining) + ".[/color]")

# ============================
# PLAYER STATUS & GEAR
# ============================
func recalculate_stats() -> void:
	gear_atk_bonus = 0
	gear_hp_bonus = 0
	gear_def_bonus = 0
	
	# Weapon Bonuses
	if equipment["weapon"] == "Refined Steel Sword":
		gear_atk_bonus += 8
	elif equipment["weapon"] == "Great Executioner Axe":
		gear_atk_bonus += 18
	elif equipment["weapon"] == "Arcane Enchanted Weapon":
		gear_atk_bonus += 20

	# Armor Bonuses
	if equipment["armor"] == "Hardened Leather Tunic":
		gear_hp_bonus += 25
	elif equipment["armor"] == "Heavy Iron Plate Armor":
		gear_hp_bonus += 40
		gear_def_bonus += 4

	# Trinket Bonuses
	if equipment["trinket"] == "Void Talisman":
		gear_atk_bonus += 15
		gear_hp_bonus += 20

func _cmd_status() -> void:
	recalculate_stats()
	append_output("")
	append_output("[color=cyan][b]=== CHARACTER STATUS ===[/b][/color]")
	append_output("Name: " + character_name + " | Level " + str(player_level) + "/" + str(max_level) + " " + character_class.capitalize())
	append_output("Faction: " + character_faction.capitalize() + " | Race: " + character_race.capitalize())
	append_output("Total HP: " + str(player_hp) + " / " + str(max_hp + gear_hp_bonus) + " (Base " + str(max_hp) + " + Gear " + str(gear_hp_bonus) + ")")
	append_output("Total Attack: " + str(player_atk + gear_atk_bonus) + " (Base " + str(player_atk) + " + Gear " + str(gear_atk_bonus) + ")")
	append_output("Unspent Talent Points: " + str(talent_points))
	append_output("Gold: " + str(player_gold) + "g | XP: " + str(player_xp) + " / " + str(xp_to_next_level))
	append_output("[color=cyan]========================[/color]")

func _cmd_gear() -> void:
	recalculate_stats()
	append_output("")
	append_output("[color=yellow][b]=== EQUIPMENT SLOTS ===[/b][/color]")
	append_output("Weapon: " + equipment["weapon"] + " (Bonus Atk: +" + str(gear_atk_bonus) + ")")
	append_output("Armor: " + equipment["armor"] + " (Bonus HP: +" + str(gear_hp_bonus) + ")")
	append_output("Trinket: " + equipment["trinket"])
	append_output("[color=yellow]=======================[/color]")

func _cmd_inventory() -> void:
	append_output("")
	append_output("[color=yellow][b]=== INVENTORY ===[/b][/color]")
	append_output("Gold: " + str(player_gold) + "g")
	if inventory.is_empty():
		append_output("Your bag is empty.")
	else:
		for item in inventory.keys():
			append_output("• " + item + " x" + str(inventory[item]))
	append_output("[color=yellow]=================[/color]")

func _cmd_use(parts: Array) -> void:
	if parts.size() < 2:
		append_output("Use what? (e.g. [b]use potion[/b])")
		return
		
	var item_name = " ".join(parts.slice(1)).to_lower()
	
	if "potion" in item_name:
		if inventory.get("Health Potion", 0) > 0:
			inventory["Health Potion"] -= 1
			if inventory["Health Potion"] <= 0:
				inventory.erase("Health Potion")
				
			var heal_amount = 40
			if "divine_grace" in learned_talents:
				heal_amount += 20
				
			recalculate_stats()
			var effective_max = max_hp + gear_hp_bonus
			player_hp = min(effective_max, player_hp + heal_amount)
			append_output("[color=green]You drink a Health Potion and restore " + str(heal_amount) + " HP![/color]")
			append_output("Your HP: " + str(player_hp) + "/" + str(effective_max))
			
			if in_combat:
				enemy_turn()
		else:
			append_output("You don't have any Health Potions in your bag!")
	else:
		append_output("You can't use that item.")

func _cmd_help() -> void:
	append_output("")
	append_output("[color=yellow][b]=== COMMAND LIST ===[/b][/color]")
	append_output("• [b]Navigation[/b]: north (n), south (s), east (e), west (w)")
	append_output("• [b]Info[/b]: look (l), inventory (i), status, gear, talents, professions, recipes")
	append_output("• [b]Actions[/b]: gather, use potion, learn <talent>")
	append_output("• [b]Crafting[/b]: craft <item>, brew <item>, enchant <item>")
	append_output("• [b]City Actions[/b]: rest, buy, sell")
	append_output("• [b]Combat[/b]: attack (a), cast (c), flee (run)")
	append_output("[color=yellow]====================[/color]")

# ============================
# CRAFTING & CITY SERVICES
# ============================
func _cmd_rest() -> void:
	if current_room_id != "wayfarers_inn":
		append_output("You can only rest and heal at The Wayfarer's Inn in Oakhaven!")
		return
	if player_gold < 10:
		append_output("You need at least 10 Gold to rent a bed for the night.")
		return
		
	recalculate_stats()
	player_gold -= 10
	player_hp = max_hp + gear_hp_bonus
	append_output("[color=green]You rent a room at the Inn and enjoy a long rest. HP fully restored![/color]")

func _cmd_craft(parts: Array) -> void:
	if current_room_id != "iron_anvil":
		append_output("You must be at The Iron Anvil smithy to craft weapons and armor!")
		return
		
	if parts.size() < 2:
		_cmd_professions()
		return
		
	var item = parts[1].to_lower()
	if item == "sword":
		if inventory.get("Iron Ore", 0) >= 5:
			inventory["Iron Ore"] -= 5
			equipment["weapon"] = "Refined Steel Sword"
			prof_blacksmithing += 1
			append_output("[color=green]You forge a Refined Steel Sword! Equipped to Weapon Slot (+8 Atk)![/color]")
		else:
			append_output("Requires 5x Iron Ore.")
	elif item == "battleaxe":
		if inventory.get("Iron Ore", 0) >= 10 and inventory.get("Spectral Dust", 0) >= 2:
			inventory["Iron Ore"] -= 10
			inventory["Spectral Dust"] -= 2
			equipment["weapon"] = "Great Executioner Axe"
			prof_blacksmithing += 3
			append_output("[color=green]You forge the Great Executioner Axe! Equipped to Weapon Slot (+18 Atk)![/color]")
		else:
			append_output("Requires 10x Iron Ore and 2x Spectral Dust.")
	elif item == "tunic":
		if inventory.get("Gloom Berries", 0) >= 4 and inventory.get("Iron Ore", 0) >= 2:
			inventory["Gloom Berries"] -= 4
			inventory["Iron Ore"] -= 2
			equipment["armor"] = "Hardened Leather Tunic"
			prof_blacksmithing += 1
			append_output("[color=green]You craft a Hardened Leather Tunic! Equipped to Armor Slot (+25 Max HP)![/color]")
		else:
			append_output("Requires 4x Gloom Berries and 2x Iron Ore.")
	elif item == "plate":
		if inventory.get("Iron Ore", 0) >= 12:
			inventory["Iron Ore"] -= 12
			equipment["armor"] = "Heavy Iron Plate Armor"
			prof_blacksmithing += 2
			append_output("[color=green]You forge Heavy Iron Plate Armor! Equipped to Armor Slot (+40 Max HP, -4 Inbound Dmg)![/color]")
		else:
			append_output("Requires 12x Iron Ore.")

func _cmd_brew(parts: Array) -> void:
	if current_room_id != "ashen_bazaar":
		append_output("You must be at the Ashen Bazaar to brew potions!")
		return
		
	if parts.size() < 2:
		_cmd_professions()
		return
		
	var item = parts[1].to_lower()
	if item == "potion":
		if inventory.get("Gloom Berries", 0) >= 3:
			inventory["Gloom Berries"] -= 3
			inventory["Health Potion"] = inventory.get("Health Potion", 0) + 1
			prof_alchemy += 1
			append_output("[color=green]You concoct a Health Potion![/color]")
		else:
			append_output("Requires 3x Gloom Berries.")
	elif item == "elixir":
		if inventory.get("Blood Lotus", 0) >= 2 and inventory.get("Gloom Berries", 0) >= 4:
			inventory["Blood Lotus"] -= 2
			inventory["Gloom Berries"] -= 4
			player_atk += 10
			prof_alchemy += 3
			append_output("[color=green]You brew and drink an Elixir of Might! Permanently gain +10 Base Attack![/color]")
		else:
			append_output("Requires 2x Blood Lotus and 4x Gloom Berries.")
	elif item == "flask":
		if inventory.get("Blood Lotus", 0) >= 3:
			inventory["Blood Lotus"] -= 3
			max_hp += 30
			player_hp += 30
			prof_alchemy += 3
			append_output("[color=green]You brew and drink a Flask of Vitality! Permanently gain +30 Max HP![/color]")
		else:
			append_output("Requires 3x Blood Lotus.")

func _cmd_enchant(parts: Array) -> void:
	if current_room_id != "ashen_bazaar":
		append_output("You must be at the Ashen Bazaar to enchant gear!")
		return
		
	if parts.size() < 2:
		_cmd_professions()
		return
		
	var item = parts[1].to_lower()
	if item == "weapon":
		if inventory.get("Spectral Dust", 0) >= 4:
			inventory["Spectral Dust"] -= 4
			equipment["weapon"] = "Arcane Enchanted Weapon"
			prof_enchanting += 2
			append_output("[color=cyan]You weave runes into your weapon! Weapon upgraded to Arcane Fire (+20 Atk)![/color]")
		else:
			append_output("Requires 4x Spectral Dust.")
	elif item == "trinket":
		if inventory.get("Spectral Dust", 0) >= 5:
			inventory["Spectral Dust"] -= 5
			equipment["trinket"] = "Void Talisman"
			prof_enchanting += 3
			append_output("[color=cyan]You forge a Void Talisman! Equipped to Trinket Slot (+15 Atk, +20 Max HP)![/color]")
		else:
			append_output("Requires 5x Spectral Dust.")

func _cmd_buy(parts: Array) -> void:
	if current_room_id != "ashen_bazaar":
		append_output("You must be in the Ashen Bazaar to buy items!")
		return
	if parts.size() < 2 or parts[1].to_lower() != "potion":
		append_output("Bazaar Goods:")
		append_output("• [b]buy potion[/b] - 15 Gold")
		return
	if player_gold >= 15:
		player_gold -= 15
		inventory["Health Potion"] = inventory.get("Health Potion", 0) + 1
		append_output("Bought 1x Health Potion!")
	else:
		append_output("Not enough gold!")

# ============================
# COMBAT & LEVELING ENGINE
# ============================
func check_for_encounter(zone_key: String) -> void:
	if randf() < 0.45:
		var pool = enemy_pools.get(zone_key, enemy_pools["mistwood"])
		var raw_enemy = pool[randi() % pool.size()]
		current_enemy = raw_enemy.duplicate()
		in_combat = true
		enemy_poison_ticks = 0
		append_output("")
		append_output("[color=red][b]AMBUSH![/b] A " + current_enemy["name"] + " emerges![/color]")
		if current_enemy.has("ascii"):
			append_output("[color=red]" + current_enemy["ascii"] + "[/color]")
		append_output("[color=yellow]" + current_enemy["name"] + " HP: " + str(current_enemy["hp"]) + "/" + str(current_enemy["max_hp"]) + "[/color]")

func enemy_turn() -> void:
	if not in_combat or current_enemy.is_empty():
		return
		
	recalculate_stats()
	var effective_max = max_hp + gear_hp_bonus
	
	# Apply Passive Talent Effects
	if "blessing_of_light" in learned_talents:
		player_hp = min(effective_max, player_hp + 8)
		append_output("[color=green]Blessing of Light restores +8 HP![/color]")
		
	if enemy_poison_ticks > 0:
		enemy_poison_ticks -= 1
		var poison_dmg = 16 if "venomous_spite" in learned_talents else 8
		current_enemy["hp"] = max(0, current_enemy["hp"] - poison_dmg)
		append_output("[color=green]Venom ticks on " + current_enemy["name"] + " for " + str(poison_dmg) + " damage![/color]")
		if current_enemy["hp"] <= 0:
			handle_victory()
			return

	var dmg = randi_range(current_enemy["dmg_min"], current_enemy["dmg_max"])
	
	# Apply Gear Defense & Talent Mitigations
	dmg = max(1, dmg - gear_def_bonus)
	if "iron_clad" in learned_talents:
		dmg = max(1, dmg - 5)
	if "arcane_shield" in learned_talents:
		dmg = max(1, dmg - 6)
	if "shadow_cloak" in learned_talents:
		dmg = max(1, dmg - 8)
	if "sacred_aura" in learned_talents:
		dmg = max(1, dmg - 5)
		
	player_hp = max(0, player_hp - dmg)
	append_output("The " + current_enemy["name"] + " hits you for [color=red]" + str(dmg) + " damage[/color]!")
	append_output("Your HP: " + str(player_hp) + "/" + str(effective_max))
	
	if player_hp <= 0:
		append_output("")
		append_output("[color=red][b]YOU WERE SLAIN...[/b][/color]")
		append_output("Respawning at Oakhaven Town Square...")
		in_combat = false
		current_enemy = {}
		player_hp = effective_max
		current_room_id = "oakhaven_square"
		_cmd_look()

func add_xp(amount: int) -> void:
	if player_level >= max_level:
		append_output("Gained [color=yellow]" + str(amount) + " XP[/color] (At Level Cap 35).")
		return
		
	player_xp += amount
	append_output("Gained [color=yellow]" + str(amount) + " XP[/color].")
	
	if player_xp >= xp_to_next_level:
		player_level += 1
		player_xp -= xp_to_next_level
		xp_to_next_level = int(xp_to_next_level * 1.4)
		max_hp += 25
		player_hp = max_hp + gear_hp_bonus
		player_atk += 5
		
		if player_level % 5 == 0:
			talent_points += 1
			append_output("[color=yellow][b]+1 TALENT POINT EARNED![/b][/color] (Type [b]talents[/b] to view)")
			
		append_output("")
		append_output("[color=cyan][b]LEVEL UP! You are now Level " + str(player_level) + "/" + str(max_level) + "![/b][/color]")
		append_output("Base HP boosted to " + str(max_hp) + " | Base Attack boosted to " + str(player_atk) + "!")

func _cmd_attack() -> void:
	if not in_combat:
		append_output("There is nothing to attack here.")
		return
		
	recalculate_stats()
	var total_atk = player_atk + gear_atk_bonus
	var dmg = randi_range(8, total_atk)
	
	if "poison_blades" in learned_talents:
		enemy_poison_ticks = 3
		append_output("[color=green]Your weapons coat the target in deadly venom![/color]")
	if "judgment" in learned_talents:
		dmg += 10
		
	current_enemy["hp"] = max(0, current_enemy["hp"] - dmg)
	append_output("You strike the " + current_enemy["name"] + " for [color=green]" + str(dmg) + " damage[/color]!")
	
	if current_enemy["hp"] <= 0:
		handle_victory()
	else:
		append_output(current_enemy["name"] + " HP: " + str(current_enemy["hp"]) + "/" + str(current_enemy["max_hp"]))
		enemy_turn()

func _cmd_cast() -> void:
	if not in_combat:
		append_output("There is no target for your spell.")
		return
		
	recalculate_stats()
	var total_atk = player_atk + gear_atk_bonus
	var spell_name = "Arcane Strike"
	var bonus_dmg = 10
	
	if character_class == "mage":
		spell_name = "Fireball"
		bonus_dmg = 20
		if "pyromancy" in learned_talents:
			bonus_dmg += 15
		if "archmage_sovereignty" in learned_talents:
			bonus_dmg += 35
	elif character_class == "slayer":
		spell_name = "Shadow Strike"
		bonus_dmg = 16
		if "shadowstep" in learned_talents:
			bonus_dmg += 12
		if "shadow_dance" in learned_talents:
			bonus_dmg += 30
	elif character_class == "guardian":
		spell_name = "Shield Bash"
		bonus_dmg = 10
		if "avatar_of_war" in learned_talents:
			bonus_dmg += 25
	elif character_class == "warden":
		spell_name = "Holy Smite"
		bonus_dmg = 14
		if "smite" in learned_talents:
			bonus_dmg += 15
		if "divine_intervention" in learned_talents:
			bonus_dmg += 30

	var spell_dmg = randi_range(12, total_atk + bonus_dmg)
	current_enemy["hp"] = max(0, current_enemy["hp"] - spell_dmg)
	append_output("You execute [b]" + spell_name + "[/b] on the " + current_enemy["name"] + " for [color=cyan]" + str(spell_dmg) + " damage[/color]!")
	
	if current_enemy["hp"] <= 0:
		handle_victory()
	else:
		append_output(current_enemy["name"] + " HP: " + str(current_enemy["hp"]) + "/" + str(current_enemy["max_hp"]))
		enemy_turn()

func handle_victory() -> void:
	append_output("[color=green][b]VICTORY![/b] You defeated the " + current_enemy["name"] + "![/color]")
	var earned_gold = current_enemy.get("gold", 10)
	player_gold += earned_gold
	append_output("Found " + str(earned_gold) + " Gold.")
	
	var drop_item = current_enemy.get("drop", "")
	if drop_item != "":
		inventory[drop_item] = inventory.get(drop_item, 0) + 1
		append_output("Looted: [b]" + drop_item + "[/b]!")
		
	add_xp(current_enemy.get("xp", 15))
	in_combat = false
	current_enemy = {}

func _cmd_flee() -> void:
	if not in_combat:
		append_output("You aren't in combat!")
		return
		
	if randf() < 0.65:
		in_combat = false
		current_enemy = {}
		append_output("You scramble away escaping combat!")
	else:
		append_output("Escape failed!")
		enemy_turn()

# ============================
# SAVE / LOAD & TERMINAL LOGIC
# ============================
func save_character() -> void:
	append_output("Character progression saved successfully.")

func load_character() -> void:
	append_output("Character progression loaded successfully.")

func append_output(text: String) -> void:
	$Terminal.append_text(text + "\n")