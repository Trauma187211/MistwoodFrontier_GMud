extends Control

# ============================
# CHARACTER META
# ============================
var faction = ""
var race = ""
var player_class = ""
var starting_zone = ""
var creation_step = 0  # 0 = wait start, 1 = faction, 2 = race, 3 = class

# ============================
# PLAYER STATS
# ============================
var player_hp = 100
var player_max_hp = 100
var player_mana = 50
var player_max_mana = 50
var player_level = 1
var player_xp = 0
var player_gold = 0

# ============================
# GEAR SYSTEM
# ============================
var gear = {
	"weapon": null,
	"armor": null,
	"trinket": null
}

var base_attack = 20
var base_defense = 0

# ============================
# INVENTORY
# ============================
var inventory = {
	"potion": 2,
	"ether": 1
}

# ============================
# PROFESSIONS
# ============================
var professions = {
	"blacksmithing": false,
	"alchemy": false,
	"skinning": false,
	"enchanting": false
}


# tier number (as string) -> talent id
var talent_choices = {}
var talent_hp_bonus = 0

# Combat / talent runtime state
var player_shield = 0
var shield_turns = 0
var ironclad_used = false
var zeal = 0
var spellweave_stacks = 0
var player_stealth = false
var layonhands_used = false
var timewarp_cd = 0
var spell_cooldowns = {}
var player_debuffs = {}
var burn_turns = 0
var burn_dmg = 0
var poison_turns = 0
var poison_dmg = 0
# Secondary enemies (for AoE / chain talents); combat is currently single-target.
var extra_enemies = []

# ============================
# FACTION REPUTATION
# ============================
var reputation = {
	"vanguard": 0,
	"bloodborn": 0
}

# ============================
# QUESTS
# ============================
var quests = {
	"wolf_cull": {
		"active": false,
		"completed": false,
		"kills_needed": 3,
		"kills": 0,
		"reward_gold": 30,
		"reward_xp": 50
	},
	"shrine_offering": {
		"active": false,
		"completed": false,
		"item_needed": "potion",
		"reward_rep": 10
	}
}

# ============================
# MOUNT & PET
# ============================
var has_mount = false
var mount_name = ""
var has_combat_pet = false
var pet_name = ""
var pet_damage_bonus = 0

var current_room = ""
var game_started = false
var in_shop = false

# ============================
# ENEMY DATA
# ============================
var enemies = [
	{"name": "Wraith", "type": "undead", "applies_chill": true, "hp": 80, "dmg_min": 5, "dmg_max": 20, "ascii": " (>'-')> "},
	{"name": "Forest Wolf", "type": "beast", "hp": 60, "dmg_min": 4, "dmg_max": 15, "ascii": " ʕ•ᴥ•ʔ "},
	{"name": "Shadow Stalker", "type": "demon", "hp": 100, "dmg_min": 8, "dmg_max": 25, "ascii": " (◣_◢) "}
]

var boss_enemy = {
	"name": "Echo of the Mistlord",
	"type": "undead",
	"applies_chill": true,
	"hp": 200,
	"dmg_min": 12,
	"dmg_max": 28,
	"ascii": """
      █████████
      █  ◣_◢  █
      █  /|\\  █
      █  / \\  █
      █████████
    """
}

var enemy = null
var in_combat: bool:
	get:
		return enemy != null

# room id -> true once its boss has been killed; saved with the character
var defeated_bosses = {}

# ============================
# READY
# ============================
func _ready():
	$Terminal.scroll_following = true
	$Input.text_submitted.connect(_on_input_submitted)
	$Input.grab_focus()
	$Terminal.append_text("[color=yellow]Welcome to the Mistwood Frontier...[/color]\n")
	$Terminal.append_text("Type [b]start[/b] to begin character creation.\n")

# ============================
# INPUT HANDLER
# ============================
# Runs before GUI/shortcut handling: Enter or any printable key focuses the input.
func _input(event: InputEvent):
	if not (event is InputEventKey) or not event.pressed:
		return
	var input_el = $Input
	if input_el.has_focus():
		return
	if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		input_el.grab_focus()
		input_el.caret_column = input_el.text.length()
		# Swallow this Enter so it only focuses and doesn't also submit.
		get_viewport().set_input_as_handled()
	elif event.unicode >= 32 and not event.ctrl_pressed and not event.alt_pressed and not event.meta_pressed:
		# Focus now; the same keystroke then reaches the LineEdit as typed text.
		input_el.grab_focus()

func _on_input_submitted(text: String):
	var command = text.strip_edges()
	$Input.clear()
	$Input.grab_focus()
	if command == "":
		return
	log_player("> " + command)
	process_command(command.to_lower())
	scroll_to_bottom()

func scroll_to_bottom():
	# Wait a frame so the RichTextLabel has laid out the new text.
	await get_tree().process_frame
	$Terminal.scroll_to_line($Terminal.get_line_count())
	var bar = $Terminal.get_v_scroll_bar()
	bar.value = bar.max_value

# ============================
# MESSAGE FEED (single unified log)
# ============================
func log_player(text):
	$Terminal.append_text("[color=#8ec7ff][b]%s[/b][/color]\n" % text.replace("[", "[lb]"))

func log_success(text):
	$Terminal.append_text("[color=#5fd35f][b][lb]SUCCESS[rb][/b] %s[/color]\n" % text)

func log_error(text):
	$Terminal.append_text("[color=#ff6b4a][b][lb]ERROR[rb][/b] %s[/color]\n" % text)

func log_combat(text):
	$Terminal.append_text("[color=#ffd84a]%s[/color]\n" % text)

func log_heal(text):
	$Terminal.append_text("[color=#5fd35f]%s[/color]\n" % text)

func log_narrative(text):
	$Terminal.append_text("[color=#d0d0d0]%s[/color]\n" % text)

# ============================
# COMMAND PROCESSOR
# ============================
func process_command(cmd):
	if cmd == "save":
		save_character()
		return
	if cmd == "load":
		load_character()
		return

	if not game_started:
		handle_character_creation(cmd)
		return

	if in_shop:
		process_shop(cmd)
		return

	var parts = cmd.split(" ")
	var main = parts[0]

	match main:
		"move":
			if parts.size() > 1:
				move(parts[1])
			else:
				$Terminal.append_text("Move where? (forward, left, right, back)\n")
		"attack":
			attack_enemy()
		"flee":
			flee()
		"cast":
			if parts.size() > 1:
				cast_spell(parts[1])
			else:
				$Terminal.append_text("Cast what?\n")
		"use":
			if parts.size() > 1:
				use_item(parts[1])
			else:
				$Terminal.append_text("Use what?\n")
		"inventory":
			show_inventory()
		"status":
			show_status()
		"help":
			show_commands()
		"shop":
			enter_shop()
		"profession":
			if parts.size() > 1:
				learn_profession(parts[1])
			else:
				$Terminal.append_text("Choose a profession: blacksmithing, alchemy, skinning, enchanting\n")
		"talents", "talent":
			handle_talents_command(parts)
		"whirlwind":
			cmd_whirlwind()
		"timewarp":
			cmd_timewarp()
		"vanish":
			cmd_vanish()
		"layonhands":
			cmd_layonhands()
		"stealth":
			cmd_stealth()
		"mount":
			if parts.size() > 1:
				acquire_mount(parts[1])
			else:
				$Terminal.append_text("Name your mount: mount <name>\n")
		"pet":
			if parts.size() > 1:
				acquire_pet(parts[1])
			else:
				$Terminal.append_text("Name your pet: pet <name>\n")
		"talk":
			if parts.size() > 1:
				talk_to(parts[1])
			else:
				$Terminal.append_text("Talk to who? (merchant, elder)\n")
		"equip":
			if parts.size() > 2:
				equip_item(parts[1], parts[2])
			else:
				$Terminal.append_text("Usage: equip <slot> <item>\n")
		"craft":
			if parts.size() > 1:
				craft_item(parts[1])
			else:
				$Terminal.append_text("Usage: craft <recipe_name> (type 'recipes' to list)\n")
		"recipes":
			show_recipes()
		_:
			log_error("Command not recognized. Type 'help'")

# ============================
# CHARACTER CREATION
# ============================
func handle_character_creation(cmd):
	if creation_step == 0:
		if cmd == "start":
			creation_step = 1
			$Terminal.append_text("\n[b]Choose your faction:[/b]\n")
			$Terminal.append_text("vanguard - disciplined, oathbound defenders\n")
			$Terminal.append_text("bloodborn - ruthless, war-forged clans\n")
			$Terminal.append_text("Type: vanguard or bloodborn\n")
		else:
			$Terminal.append_text("[color=red]Type 'start' to begin character creation.[/color]\n")
		return

	if creation_step == 1:
		if cmd == "vanguard" or cmd == "bloodborn":
			faction = cmd
			creation_step = 2
			show_race_options()
		else:
			$Terminal.append_text("Invalid faction. Type: vanguard or bloodborn\n")
		return

	if creation_step == 2:
		if is_valid_race_for_faction(cmd):
			race = cmd
			starting_zone = get_starting_zone(faction, race)
			creation_step = 3
			show_class_options()
		else:
			$Terminal.append_text("That race does not belong to your faction.\n")
			show_race_options()
		return

	if creation_step == 3:
		if cmd == "guardian" or cmd == "slayer" or cmd == "warden" or cmd == "mage":
			player_class = cmd
			setup_class_stats(player_class)
			current_room = starting_zone
			game_started = true
			creation_step = 4
			show_character_summary()
			show_commands()
			show_room()
		else:
			$Terminal.append_text("Invalid class. Type: guardian, slayer, warden, or mage\n")
		return

func show_race_options():
	if faction == "vanguard":
		$Terminal.append_text("\n[b]Vanguard Races:[/b]\n")
		$Terminal.append_text("human - frontier soldiers and scouts\n")
		$Terminal.append_text("highborn - mystic bloodlines attuned to arcane\n")
		$Terminal.append_text("stonekin - rune-carved guardians of the cliffs\n")
		$Terminal.append_text("Type: human / highborn / stonekin\n")
	elif faction == "bloodborn":
		$Terminal.append_text("\n[b]Bloodborn Races:[/b]\n")
		$Terminal.append_text("ravager - brutal warbands from the wastes\n")
		$Terminal.append_text("shade - veiled assassins from shadowed hollows\n")
		$Terminal.append_text("wildling - feral hunters bound to the wild\n")
		$Terminal.append_text("Type: ravager / shade / wildling\n")

func is_valid_race_for_faction(r):
	if faction == "vanguard":
		return r in ["human", "highborn", "stonekin"]
	if faction == "bloodborn":
		return r in ["ravager", "shade", "wildling"]
	return false

func get_starting_zone(f, r):
	if f == "vanguard":
		match r:
			"human":
				return "dawnwatch_outpost"
			"highborn":
				return "emberfall_camp"
			"stonekin":
				return "stonegate_hold"
	elif f == "bloodborn":
		match r:
			"ravager":
				return "bloodfang_warcamp"
			"shade":
				return "shadow_hollow"
			"wildling":
				return "briar_thicket"
	return "mistwood_edge"

func show_class_options():
	$Terminal.append_text("\n[b]Choose your class:[/b]\n")
	$Terminal.append_text("guardian - Warrior: tank, high HP, moderate damage\n")
	$Terminal.append_text("slayer - Rogue: DPS, high damage, lower HP\n")
	$Terminal.append_text("warden - Cleric: healer, support, strong mana\n")
	$Terminal.append_text("mage - Mage: spellcaster, huge mana, fragile\n")
	$Terminal.append_text("Type: guardian / slayer / warden / mage\n")

func setup_class_stats(cls):
	if cls == "guardian":
		player_max_hp = 140
		player_hp = player_max_hp
		player_max_mana = 40
		player_mana = player_max_mana
		base_attack = 22
		base_defense = 5
	elif cls == "slayer":
		player_max_hp = 100
		player_hp = player_max_hp
		player_max_mana = 60
		player_mana = player_max_mana
		base_attack = 28
		base_defense = 1
	elif cls == "warden":
		player_max_hp = 110
		player_hp = player_max_hp
		player_max_mana = 80
		player_mana = player_max_mana
		base_attack = 18
		base_defense = 2
	elif cls == "mage":
		player_max_hp = 90
		player_hp = player_max_hp
		player_max_mana = 100
		player_mana = player_max_mana
		base_attack = 16
		base_defense = 0

func show_character_summary():
	$Terminal.append_text("\n[b]Character Created:[/b]\n")
	$Terminal.append_text("Faction: %s\n" % faction)
	$Terminal.append_text("Race: %s\n" % race)
	$Terminal.append_text("Class: %s\n" % player_class)
	$Terminal.append_text("Starting Zone: %s\n" % starting_zone)

# ============================
# COMMAND LIST
# ============================
func show_commands():
	$Terminal.append_text("\n[b]Available Commands:[/b]\n")
	$Terminal.append_text("move forward / move left / move right / move back\n")
	$Terminal.append_text("attack / flee\n")
	$Terminal.append_text("cast fire / cast meteor / cast holy (cleric) / cast heal (cleric)\n")
	$Terminal.append_text("use <item>\n")
	$Terminal.append_text("inventory\n")
	$Terminal.append_text("status\n")
	$Terminal.append_text("shop\n")
	$Terminal.append_text("profession <name>\n")
	$Terminal.append_text("talents / talents list / talents choose <id|name> / talents current / talents reset\n")
	$Terminal.append_text("stealth (rogue); talent commands: whirlwind, timewarp, vanish, layonhands\n")
	$Terminal.append_text("mount <name>\n")
	$Terminal.append_text("pet <name>\n")
	$Terminal.append_text("talk merchant / talk elder\n")
	$Terminal.append_text("equip <slot> <item>\n")
	$Terminal.append_text("recipes\n")
	$Terminal.append_text("craft <recipe_name>\n")
	$Terminal.append_text("save / load\n")
	$Terminal.append_text("help\n")

# ============================
# MUSIC / SFX CUES
# ============================
func play_music_cue(tag):
	match tag:
		"camp_theme":
			$Terminal.append_text("[music] Soft campfire strings and distant drums.\n")
		"warcamp_theme":
			$Terminal.append_text("[music] Heavy war drums and harsh horns.\n")
		"shadow_theme":
			$Terminal.append_text("[music] Whispering voices and low, eerie tones.\n")
		"forest_theme":
			$Terminal.append_text("[music] Gentle flutes over rustling leaves.\n")
		"forest_deep_theme":
			$Terminal.append_text("[music] Deep, pulsing ambience beneath creaking branches.\n")
		"merchant_theme":
			$Terminal.append_text("[music] Light strings and the clink of coin.\n")
		"tower_theme":
			$Terminal.append_text("[music] Echoing choir and distant thunder.\n")
		"dungeon_theme":
			$Terminal.append_text("[music] Low drones and ritual chanting.\n")
		"boss_theme":
			$Terminal.append_text("[music] Intense percussion and rising strings.\n")
		"danger_theme":
			$Terminal.append_text("[music] Tense staccato notes and snarling breaths.\n")
		"mystic_theme":
			$Terminal.append_text("[music] Chimes and shimmering tones.\n")
		_:
			$Terminal.append_text("[music] The soundscape shifts around you.\n")

# ============================
# ROOM SYSTEM
# ============================
func show_room():
	var room = GameDatabase.ROOMS[current_room]
	$Terminal.append_text("\n[color=cyan]%s[/color]\n" % room["desc"])

	if room.has("music"):
		play_music_cue(room["music"])

	if room.get("boss", false):
		if defeated_bosses.get(current_room, false):
			$Terminal.append_text("%s\n" % room.get("cleared_desc", "This place is quiet now."))
			return
		if enemy == null:
			spawn_boss()
		return

	if randi() % 100 < room["enemy_chance"]:
		spawn_enemy()

func move(direction):
	if enemy != null:
		log_error("You can't walk away from a fight! Use 'flee' to try to escape.")
		return
	var room = GameDatabase.ROOMS[current_room]

	if room.has(direction):
		current_room = room[direction]
		show_room()
	else:
		$Terminal.append_text("[color=red]You can't move %s from here.[/color]\n" % direction)

func flee():
	if enemy == null:
		log_error("You aren't in combat.")
		return
	if randf() < 0.5:
		enemy = null
		reset_combat_state()
		log_success("You break away from the fight.")
	else:
		log_combat("You fail to escape!")
		enemy_attack()

# ============================
# ENEMY SYSTEM
# ============================
func spawn_enemy():
	enemy = enemies[randi() % enemies.size()].duplicate()
	enemy["max_hp"] = enemy["hp"]
	reset_combat_state()
	$Terminal.append_text("\n[color=purple]A %s appears![/color]\n" % enemy["name"])
	$Terminal.append_text("[b]%s[/b]\n" % enemy["ascii"])
	$Terminal.append_text("HP: %d\n" % enemy["hp"])

func spawn_boss():
	enemy = boss_enemy.duplicate()
	enemy["max_hp"] = enemy["hp"]
	enemy["boss_room"] = current_room
	reset_combat_state()
	$Terminal.append_text("\n[color=purple]An echo of the Mistlord manifests![/color]\n")
	$Terminal.append_text("[b]%s[/b]\n" % enemy["ascii"])
	$Terminal.append_text("HP: %d\n" % enemy["hp"])
	play_music_cue("boss_theme")

func get_total_attack():
	var atk = base_attack
	if has_combat_pet:
		atk += pet_damage_bonus
	atk += get_gear_bonus("attack_bonus")
	return atk

func get_total_defense():
	var def = base_defense
	def += int(talent_mod("armor"))
	def += get_gear_bonus("defense_bonus")
	return def

func get_elemental_resist():
	return talent_mod("elemental_resist")

func get_gear_bonus(stat):
	var total = 0
	for slot in gear.keys():
		var item_id = gear[slot]
		if item_id != null and GameDatabase.ITEMS.has(item_id):
			total += GameDatabase.ITEMS[item_id].get(stat, 0)
	return total

# ============================
# COMBAT HELPERS
# ============================
func reset_combat_state():
	player_shield = 0
	shield_turns = 0
	ironclad_used = false
	zeal = 0
	spellweave_stacks = 0
	spell_cooldowns = {}
	player_debuffs = {}
	burn_turns = 0
	poison_turns = 0
	extra_enemies = []

# Returns {"dmg": int, "crit": bool}. kind is "melee" or "spell".
func calc_player_damage(raw, kind):
	var mult = 1.0
	if kind == "melee":
		mult *= 1.0 + talent_mod("melee_dmg_pct")
	if enemy != null and enemy["hp"] < enemy["max_hp"] * 0.3:
		mult *= 1.0 + talent_mod("execute_dmg_pct")
	if zeal > 0:
		mult *= 1.0 + 0.03 * zeal
	if player_debuffs.has("chilled"):
		mult *= 0.8

	var crit_chance = 0.05
	var crit_mult = 1.5
	crit_chance += talent_mod("crit_chance")
	crit_mult += talent_mod("crit_damage")
	if kind == "spell":
		crit_chance += 0.05 * spellweave_stacks
	var crit = randf() < crit_chance
	# Enemies have no armor stat yet, so Shadow Step's armor penetration is implicit.
	if kind == "melee" and player_stealth and has_talent("shadow_step"):
		crit = true
	if crit:
		mult *= crit_mult
	return {"dmg": max(int(raw * mult), 1), "crit": crit}

func finish_if_dead(verb):
	if enemy == null or enemy["hp"] > 0:
		return false
	$Terminal.append_text("[color=green]%s is %s![/color]\n" % [enemy["name"], verb])
	gain_loot()
	check_quests_on_kill(enemy["name"])
	if enemy.has("boss_room"):
		defeated_bosses[enemy["boss_room"]] = true
	enemy = null
	reset_combat_state()
	return true

func get_combat_targets():
	var targets = []
	if enemy != null:
		targets.append(enemy)
	for e in extra_enemies:
		if e["hp"] > 0:
			targets.append(e)
	return targets

func apply_player_debuff(debuff, turns):
	if has_talent("divine_grace"):
		turns = max(int(turns / 2), 1)
	player_debuffs[debuff] = turns
	$Terminal.append_text("[color=gray]You are %s for %d turns.[/color]\n" % [debuff, turns])

func heal_player(amount):
	amount = int(amount * (1.0 + talent_mod("healing_pct")))
	player_hp = min(player_hp + amount, player_max_hp)

# Applies damage through shield, Arcane Barrier, Zeal and Ironclad. Returns HP lost.
func take_damage(amount):
	var remaining = amount
	if player_shield > 0:
		var absorbed = min(player_shield, remaining)
		player_shield -= absorbed
		remaining -= absorbed
	if has_talent("arcane_barrier") and remaining > 0:
		var portion = min(int(round(remaining * 0.15)), player_mana)
		player_mana -= portion
		remaining -= portion
	player_hp -= remaining
	if has_talent("retribution"):
		zeal = min(zeal + 1, 5)
	if has_talent("ironclad") and not ironclad_used and player_hp > 0 and player_hp < player_max_hp * 0.35:
		ironclad_used = true
		player_shield = int(player_max_hp * 0.25)
		shield_turns = 3
		$Terminal.append_text("[color=cyan]Ironclad! You gain a %d point shield.[/color]\n" % player_shield)
	return remaining

func tick_enemy_effects():
	if burn_turns > 0:
		burn_turns -= 1
		enemy["hp"] -= burn_dmg
		$Terminal.append_text("[color=orange]%s burns for %d damage.[/color]\n" % [enemy["name"], burn_dmg])
	if poison_turns > 0:
		poison_turns -= 1
		enemy["hp"] -= poison_dmg
		$Terminal.append_text("[color=green]%s suffers %d Nature damage from poison.[/color]\n" % [enemy["name"], poison_dmg])
	return finish_if_dead("consumed")

func tick_player_timers():
	if shield_turns > 0:
		shield_turns -= 1
		if shield_turns == 0:
			player_shield = 0
	for d in player_debuffs.keys():
		player_debuffs[d] -= 1
		if player_debuffs[d] <= 0:
			player_debuffs.erase(d)
	for s in spell_cooldowns.keys():
		spell_cooldowns[s] -= 1
		if spell_cooldowns[s] <= 0:
			spell_cooldowns.erase(s)
	if timewarp_cd > 0:
		timewarp_cd -= 1

func attack_enemy():
	if enemy == null:
		$Terminal.append_text("There is nothing to attack.\n")
		return

	var raw = randi() % max(get_total_attack(), 1) + 5
	var r = calc_player_damage(raw, "melee")
	var dmg = r["dmg"]
	enemy["hp"] -= dmg
	player_stealth = false

	var crit_text = " [b]Critical![/b]" if r["crit"] else ""
	$Terminal.append_text("[color=white]You strike the %s for %d damage!%s[/color]\n" % [enemy["name"], dmg, crit_text])

	if has_talent("venomous_blades"):
		poison_turns = 3
		poison_dmg = max(int(dmg * 0.15), 2)
		$Terminal.append_text("[color=green]Your blades poison the %s (healing reduced).[/color]\n" % enemy["name"])

	if has_talent("flurry_of_steel") and randf() < 0.25:
		var extra = calc_player_damage(raw * 0.5, "melee")["dmg"]
		enemy["hp"] -= extra
		$Terminal.append_text("[color=white]Flurry of Steel! Your off-hand strikes for %d damage.[/color]\n" % extra)

	if finish_if_dead("defeated"):
		return

	enemy_attack()

func enemy_attack():
	if tick_enemy_effects():
		return

	tick_player_timers()

	if randf() < talent_mod("evasion"):
		$Terminal.append_text("[color=cyan]You evade the %s's attack![/color]\n" % enemy["name"])
		return

	var dmg = enemy["dmg_min"] + randi() % max(enemy["dmg_max"] - enemy["dmg_min"], 1)
	var mitigated = max(dmg - get_total_defense(), 1)
	take_damage(mitigated)

	$Terminal.append_text("[color=red]%s hits you for %d damage![/color]\n" % [enemy["name"], mitigated])

	if player_hp <= 0:
		$Terminal.append_text("[color=red]You have fallen...[/color]\n")
		respawn()
		return

	if enemy.get("applies_chill", false) and randf() < 0.25:
		apply_player_debuff("chilled", 2)

	if talent_mod("reflect_pct") > 0.0:
		var reflected = max(int(mitigated * talent_mod("reflect_pct")), 1)
		enemy["hp"] -= reflected
		$Terminal.append_text("[color=cyan]You reflect %d damage back![/color]\n" % reflected)
		finish_if_dead("defeated")

# ============================
# LOOT + XP + MATERIALS
# ============================
func gain_loot():
	var gold_gain = randi() % 20 + 10
	var xp_gain = randi() % 30 + 20

	player_gold += gold_gain
	player_xp += xp_gain

	$Terminal.append_text("You gain %d gold and %d XP.\n" % [gold_gain, xp_gain])

	# Simple material drops
	var roll = randi() % 100
	if roll < 30:
		add_material("iron_ore")
	elif roll < 60:
		add_material("wolf_pelt")
	elif roll < 80:
		add_material("herb")
	else:
		add_material("arcane_dust")

	if player_xp >= player_level * 100:
		level_up()

func add_material(mat):
	if not inventory.has(mat):
		inventory[mat] = 0
	inventory[mat] += 1
	$Terminal.append_text("You obtain: %s\n" % mat)

func level_up():
	player_level += 1
	player_max_hp += 20
	player_max_mana += 10
	refresh_talent_hp()
	player_hp = player_max_hp
	player_mana = player_max_mana

	$Terminal.append_text("[color=green]You leveled up to level %d![/color]\n" % player_level)
	for tier in get_class_tiers():
		if tier["level"] == player_level:
			$Terminal.append_text("[color=yellow]A new talent tier is available! Type 'talents'.[/color]\n")

# ============================
# SPELLS
# ============================
func get_spell_cost(spell):
	var cost = 10
	match spell:
		"meteor":
			cost = 25
		"holy", "heal":
			cost = 12
		"fire":
			if player_class == "warden":
				cost = 8
	cost = int(ceil(cost * (1.0 + talent_mod("mana_cost_pct"))))
	return cost

func cast_spell(spell):
	if not spell in ["fire", "meteor", "holy", "heal"]:
		log_error("Unknown spell.")
		return
	if (spell == "holy" or spell == "heal") and player_class != "warden":
		log_error("Only clerics can cast that.")
		return
	if spell_cooldowns.has(spell):
		$Terminal.append_text("%s is on cooldown (%d turns).\n" % [spell, spell_cooldowns[spell]])
		return

	var cost = get_spell_cost(spell)
	if player_mana < cost:
		log_error("Not enough mana.")
		return

	if spell == "heal":
		player_mana -= cost
		heal_player(35)
		log_heal("You cast Heal. HP: %d/%d" % [player_hp, player_max_hp])
		if enemy != null:
			enemy_attack()
		return

	if enemy == null:
		$Terminal.append_text("No enemy to cast on.\n")
		return

	player_mana -= cost
	var base = 30
	var label = "Fire"
	if spell == "meteor":
		base = 70
		label = "Meteor"
		spell_cooldowns["meteor"] = 4
	elif spell == "holy":
		base = 35
		label = "Holy Light"
	elif player_class == "slayer":
		base = 40
	var raw = randi() % base + 15
	if spell == "holy" and has_talent("smite_the_unworthy") and enemy.get("type", "") in ["undead", "demon"]:
		raw = int(raw * 1.2)
	var r = calc_player_damage(raw, "spell")
	var dmg = r["dmg"]
	enemy["hp"] -= dmg
	if has_talent("spellweave"):
		spellweave_stacks = min(spellweave_stacks + 1, 4)

	var crit_text = " [b]Critical![/b]" if r["crit"] else ""
	$Terminal.append_text("[color=orange]You cast %s for %d damage!%s[/color]\n" % [label, dmg, crit_text])

	if has_talent("pyromancy") and (spell == "fire" or spell == "meteor"):
		burn_turns = 3
		burn_dmg = max(int(dmg * 0.1), 1)
		$Terminal.append_text("[color=orange]%s is set ablaze![/color]\n" % enemy["name"])

	if has_talent("chain_impact") and randf() < 0.3:
		for t in get_combat_targets():
			if t != enemy:
				var jump = int(dmg * 0.7)
				t["hp"] -= jump
				$Terminal.append_text("[color=orange]Chain Impact jumps to %s for %d damage![/color]\n" % [t["name"], jump])
				break

	if finish_if_dead("incinerated"):
		return

	enemy_attack()

# ============================
# ITEMS
# ============================
func use_item(item):
	if not inventory.has(item):
		log_error("You don't have that item.")
		return
	if inventory[item] <= 0:
		log_error("You're out of %s." % item)
		return

	var def = GameDatabase.ITEMS.get(item, {})
	if def.get("type", "") != "consumable":
		log_error("You can't use that.")
		return

	inventory[item] -= 1
	if def.has("hp"):
		heal_player(def["hp"])
	if def.has("mana"):
		player_mana = min(player_mana + def["mana"], player_max_mana)
	log_heal(def.get("use_msg", "You use %s." % item))

	# Using an item takes your turn.
	if in_combat:
		enemy_attack()

# ============================
# PROFESSIONS
# ============================
func learn_profession(name):
	if in_combat:
		log_error("You cannot do that while in combat!")
		return
	if not professions.has(name):
		$Terminal.append_text("Unknown profession.\n")
		return
	if professions[name]:
		$Terminal.append_text("You already know %s.\n" % name)
		return
	professions[name] = true
	$Terminal.append_text("You learn the profession of %s.\n" % name)

# ============================
# TALENTS
# ============================
func get_class_tiers():
	if GameDatabase.TALENT_TREES.has(player_class):
		return GameDatabase.TALENT_TREES[player_class]["tiers"]
	return []

func has_talent(id):
	return talent_choices.values().has(id)

func get_talent_option(id):
	for tier in get_class_tiers():
		for opt in tier["options"]:
			if opt["id"] == id:
				return opt
	return null

# Sums one modifier (e.g. "armor", "hp_pct") across all chosen talents.
func talent_mod(key):
	var total = 0.0
	for id in talent_choices.values():
		var opt = get_talent_option(id)
		if opt != null:
			total += opt.get("mods", {}).get(key, 0.0)
	return total

# Flattens the tree into [{"number", "tier", "tier_index", "level", "id", ...}] in display order.
func get_talent_entries():
	var entries = []
	var n = 1
	var tiers = get_class_tiers()
	for i in range(tiers.size()):
		for opt in tiers[i]["options"]:
			entries.append({"number": n, "tier_index": i, "level": tiers[i]["level"], "tier_name": tiers[i]["name"], "id": opt["id"], "name": opt["name"], "desc": opt["desc"]})
			n += 1
	return entries

func find_talent_entry(query):
	query = query.strip_edges().to_lower().replace(" ", "_")
	for e in get_talent_entries():
		if str(e["number"]) == query or e["id"] == query or e["id"].replace("_", "") == query.replace("_", ""):
			return e
	return null

func refresh_talent_hp():
	var base = player_max_hp - talent_hp_bonus
	var old_max = player_max_hp
	talent_hp_bonus = int(base * talent_mod("hp_pct"))
	player_max_hp = base + talent_hp_bonus
	if player_max_hp > old_max:
		player_hp += player_max_hp - old_max
	player_hp = clamp(player_hp, 1, player_max_hp)

func handle_talents_command(parts):
	if player_class == "":
		log_error("You must choose a class first.")
		return
	var sub = parts[1] if parts.size() > 1 else "list"
	match sub:
		"list":
			show_talent_tree()
		"current":
			show_current_talents()
		"choose":
			if parts.size() < 3:
				log_error("Usage: talents choose <number|name>")
			else:
				choose_talent(" ".join(parts.slice(2)))
		"reset":
			reset_talents()
		_:
			log_error("Usage: talents [list] | talents choose <id> | talents current | talents reset")

func show_talent_tree():
	var tiers = get_class_tiers()
	$Terminal.append_text("\n[b]=== %s TALENT TREE ===[/b]\n" % GameDatabase.TALENT_TREES[player_class]["title"])
	var n = 1
	for i in range(tiers.size()):
		var t = tiers[i]
		var status = "UNLOCKED" if player_level >= t["level"] else "LOCKED - Requires Level %d" % t["level"]
		$Terminal.append_text("[lb]Tier %d - Level %d[rb] (%s)\n" % [i + 1, t["level"], status])
		for opt in t["options"]:
			var mark = " [lb]SELECTED[rb]" if talent_choices.get(str(i + 1), "") == opt["id"] else ""
			$Terminal.append_text("  %d. %s: %s%s\n" % [n, opt["name"], opt["desc"], mark])
			n += 1
		$Terminal.append_text("\n")
	$Terminal.append_text("Use 'talents choose <number|name>' to pick a talent.\n")

func show_current_talents():
	$Terminal.append_text("\n[b]Active talents:[/b]\n")
	if talent_choices.is_empty():
		$Terminal.append_text("None chosen yet.\n")
		return
	for e in get_talent_entries():
		if talent_choices.get(str(e["tier_index"] + 1), "") == e["id"]:
			$Terminal.append_text("Tier %d - %s: %s\n" % [e["tier_index"] + 1, e["name"], e["desc"]])

func choose_talent(query):
	if enemy != null:
		log_error("You can't change talents during combat.")
		return
	var e = find_talent_entry(query)
	if e == null:
		log_error("Unknown talent. Type 'talents' to see the list.")
		return
	if player_level < e["level"]:
		log_error("That tier requires level %d." % e["level"])
		return
	var key = str(e["tier_index"] + 1)
	if talent_choices.has(key):
		log_error("You already chose a talent for this tier. Use 'talents reset' to respec.")
		return
	talent_choices[key] = e["id"]
	refresh_talent_hp()
	log_success("You selected %s!" % e["name"])

func reset_talents():
	if enemy != null:
		log_error("You can't reset talents during combat.")
		return
	if talent_choices.is_empty():
		log_error("You have no talents to reset.")
		return
	talent_choices = {}
	player_stealth = false
	refresh_talent_hp()
	log_success("Your talents have been reset.")

func require_talent(id):
	if has_talent(id):
		return true
	log_error("You haven't learned that ability.")
	return false

func cmd_whirlwind():
	if not require_talent("whirlwind_fury"):
		return
	if enemy == null:
		$Terminal.append_text("There is nothing to attack.\n")
		return
	var weapon_dmg = get_total_attack()
	for t in get_combat_targets():
		var dmg = max(int(weapon_dmg * 0.8), 1)
		t["hp"] -= dmg
		$Terminal.append_text("[color=white]Whirlwind hits %s for %d damage![/color]\n" % [t["name"], dmg])
	extra_enemies = extra_enemies.filter(func(e): return e["hp"] > 0)
	if finish_if_dead("defeated"):
		return
	enemy_attack()

func cmd_timewarp():
	if not require_talent("time_warp"):
		return
	if timewarp_cd > 0:
		$Terminal.append_text("Time Warp is on cooldown (%d turns).\n" % timewarp_cd)
		return
	spell_cooldowns = {}
	timewarp_cd = 10
	$Terminal.append_text("[color=cyan]Time bends. All spell cooldowns are reset.[/color]\n")

func cmd_vanish():
	if not require_talent("vanish"):
		return
	if enemy == null:
		$Terminal.append_text("You aren't in combat.\n")
		return
	enemy = null
	reset_combat_state()
	player_stealth = true
	$Terminal.append_text("[color=gray]You vanish into the mist and escape combat. You are stealthed.[/color]\n")

func cmd_stealth():
	if player_class != "slayer":
		log_error("Only rogues can stealth.")
		return
	if enemy != null:
		$Terminal.append_text("You can't stealth while in combat.\n")
		return
	player_stealth = true
	$Terminal.append_text("[color=gray]You slip into the shadows.[/color]\n")

func cmd_layonhands():
	if not require_talent("lay_on_hands"):
		return
	if layonhands_used:
		$Terminal.append_text("Lay on Hands was already used this run.\n")
		return
	layonhands_used = true
	player_hp = player_max_hp
	$Terminal.append_text("[color=cyan]Lay on Hands! You are fully healed.[/color]\n")
	if enemy != null:
		enemy_attack()

# ============================
# MOUNT & PET
# ============================
func acquire_mount(name):
	if in_combat:
		log_error("You cannot do that while in combat!")
		return
	if has_mount:
		$Terminal.append_text("You already have a mount: %s.\n" % mount_name)
		return
	has_mount = true
	mount_name = name
	$Terminal.append_text("You acquire a mount named %s. Travel feels faster.\n" % mount_name)

func acquire_pet(name):
	if in_combat:
		log_error("You cannot do that while in combat!")
		return
	if has_combat_pet:
		$Terminal.append_text("You already have a combat companion: %s.\n" % pet_name)
		return
	has_combat_pet = true
	pet_name = name
	pet_damage_bonus = 5
	$Terminal.append_text("A loyal companion named %s joins you. Your attacks feel stronger.\n" % pet_name)

# ============================
# SHOP
# ============================
func enter_shop():
	if in_combat:
		log_error("You cannot do that while in combat!")
		return
	if current_room != "forest_merchant":
		$Terminal.append_text("You don't see any merchant here.\n")
		return

	in_shop = true
	$Terminal.append_text("\n[color=yellow]Forest Merchant[/color]\n")
	for item_id in GameDatabase.ITEMS.keys():
		if GameDatabase.ITEMS[item_id].has("shop_price"):
			$Terminal.append_text("%s - %d gold\n" % [item_id, GameDatabase.ITEMS[item_id]["shop_price"]])
	$Terminal.append_text("Type: buy potion / buy ether / leave\n")

func process_shop(cmd):
	if cmd == "leave":
		in_shop = false
		$Terminal.append_text("You step away from the merchant.\n")
		return

	var parts = cmd.split(" ")
	if parts.size() < 2 or parts[0] != "buy":
		$Terminal.append_text("Shop commands: buy potion / buy ether / leave\n")
		return

	var item = parts[1]
	if not GameDatabase.ITEMS.has(item) or not GameDatabase.ITEMS[item].has("shop_price"):
		$Terminal.append_text("The merchant does not sell that.\n")
		return
	var cost = GameDatabase.ITEMS[item]["shop_price"]

	if player_gold < cost:
		$Terminal.append_text("You don't have enough gold.\n")
		return

	player_gold -= cost
	if not inventory.has(item):
		inventory[item] = 0
	inventory[item] += 1

	$Terminal.append_text("You buy a %s.\n" % item)

# ============================
# NPC DIALOGUE
# ============================
func talk_to(target):
	if in_combat:
		log_error("You cannot do that while in combat!")
		return
	if target == "merchant":
		if current_room != "forest_merchant":
			$Terminal.append_text("No merchant is nearby.\n")
			return
		$Terminal.append_text("\n[color=yellow]Forest Merchant:[/color]\n")
		$Terminal.append_text("\"Coin for goods, traveler. Danger for free.\"\n")
		return
	elif target == "elder":
		if current_room != "shrine":
			$Terminal.append_text("No elder is nearby.\n")
			return
		$Terminal.append_text("\n[color=yellow]Shrine Elder:[/color]\n")
		$Terminal.append_text("\"The woods remember every step. Will you walk them with care?\"\n")
		if not quests["shrine_offering"]["active"] and not quests["shrine_offering"]["completed"]:
			quests["shrine_offering"]["active"] = true
			$Terminal.append_text("Quest started: Shrine Offering. Bring a potion to the shrine.\n")
		else:
			turn_in_shrine_offering()
		return
	else:
		$Terminal.append_text("You see no one by that name.\n")

# ============================
# QUESTS
# ============================
func check_quests_on_kill(enemy_name):
	if quests["wolf_cull"]["active"] and not quests["wolf_cull"]["completed"]:
		if enemy_name == "Forest Wolf":
			quests["wolf_cull"]["kills"] += 1
			$Terminal.append_text("Wolf Cull progress: %d/%d\n" % [quests["wolf_cull"]["kills"], quests["wolf_cull"]["kills_needed"]])
			if quests["wolf_cull"]["kills"] >= quests["wolf_cull"]["kills_needed"]:
				quests["wolf_cull"]["completed"] = true
				player_gold += quests["wolf_cull"]["reward_gold"]
				player_xp += quests["wolf_cull"]["reward_xp"]
				$Terminal.append_text("[color=green]Quest completed: Wolf Cull![/color]\n")
				$Terminal.append_text("You gain %d gold and %d XP.\n" % [quests["wolf_cull"]["reward_gold"], quests["wolf_cull"]["reward_xp"]])

func turn_in_shrine_offering():
	var q = quests["shrine_offering"]
	if not q["active"] or q["completed"]:
		return
	if inventory.has(q["item_needed"]) and inventory[q["item_needed"]] > 0:
		inventory[q["item_needed"]] -= 1
		q["completed"] = true
		reputation[faction] += q["reward_rep"]
		$Terminal.append_text("[color=green]Quest completed: Shrine Offering![/color]\n")
		$Terminal.append_text("Your reputation with %s increases.\n" % faction)
	else:
		$Terminal.append_text("You lack the required offering.\n")

# ============================
# CRAFTING
# ============================
func show_recipes():
	$Terminal.append_text("\n[b]Known Recipes:[/b]\n")
	for name in GameDatabase.RECIPES.keys():
		var r = GameDatabase.RECIPES[name]
		$Terminal.append_text("%s (requires %s)\n" % [name, r["profession"]])

func craft_item(name):
	if in_combat:
		log_error("You cannot do that while in combat!")
		return
	if not GameDatabase.RECIPES.has(name):
		$Terminal.append_text("Unknown recipe.\n")
		return

	var r = GameDatabase.RECIPES[name]
	var prof = r["profession"]
	if not professions.has(prof) or not professions[prof]:
		$Terminal.append_text("You must learn %s to craft this.\n" % prof)
		return

	# Check materials
	for mat in r["materials"].keys():
		var needed = r["materials"][mat]
		if not inventory.has(mat) or inventory[mat] < needed:
			$Terminal.append_text("Missing materials: %s x%d\n" % [mat, needed])
			return

	# Consume materials
	for mat in r["materials"].keys():
		var needed = r["materials"][mat]
		inventory[mat] -= needed

	var result_item = r["result_item"]
	if not inventory.has(result_item):
		inventory[result_item] = 0
	inventory[result_item] += 1

	$Terminal.append_text("You craft: %s\n" % result_item)

	# Auto-equip gear if recipe has slot
	if r.has("slot"):
		var slot = r["slot"]
		gear[slot] = result_item
		$Terminal.append_text("You equip %s in slot %s.\n" % [result_item, slot])

# ============================
# GEAR
# ============================
func equip_item(slot, item):
	if in_combat:
		log_error("You cannot do that while in combat!")
		return
	if not gear.has(slot):
		$Terminal.append_text("Invalid gear slot.\n")
		return
	if not inventory.has(item) or inventory[item] <= 0:
		$Terminal.append_text("You don't have that item.\n")
		return
	gear[slot] = item
	$Terminal.append_text("You equip %s in slot %s.\n" % [item, slot])

# ============================
# STATUS + INVENTORY
# ============================
func show_status():
	$Terminal.append_text("\n[b]HP:[/b] %d/%d\n" % [player_hp, player_max_hp])
	$Terminal.append_text("[b]Mana:[/b] %d/%d\n" % [player_mana, player_max_mana])
	$Terminal.append_text("[b]Level:[/b] %d\n" % player_level)
	$Terminal.append_text("[b]XP:[/b] %d\n" % player_xp)
	$Terminal.append_text("[b]Gold:[/b] %d\n" % player_gold)
	$Terminal.append_text("[b]Faction:[/b] %s\n" % faction)
	$Terminal.append_text("[b]Race:[/b] %s\n" % race)
	$Terminal.append_text("[b]Class:[/b] %s\n" % player_class)
	$Terminal.append_text("[b]Reputation (%s):[/b] %d\n" % [faction, reputation.get(faction, 0)])
	if has_mount:
		$Terminal.append_text("[b]Mount:[/b] %s\n" % mount_name)
	if has_combat_pet:
		$Terminal.append_text("[b]Pet:[/b] %s\n" % pet_name)
	$Terminal.append_text("[b]Gear:[/b] weapon=%s, armor=%s, trinket=%s\n" % [gear["weapon"], gear["armor"], gear["trinket"]])

func show_inventory():
	$Terminal.append_text("\n[b]Inventory:[/b]\n")
	for item in inventory.keys():
		$Terminal.append_text("%s: %d\n" % [item, inventory[item]])

# ============================
# SAVE / LOAD
# ============================
const SAVE_VERSION = 3
const SAVE_PATH = "user://gmud_save.json"

func save_character():
	if not game_started:
		log_error("Create a character before saving.")
		return
	var data = {
		"save_version": SAVE_VERSION,
		"faction": faction,
		"race": race,
		"player_class": player_class,
		"starting_zone": starting_zone,
		"player_hp": player_hp,
		"player_max_hp": player_max_hp,
		"player_mana": player_mana,
		"player_max_mana": player_max_mana,
		"player_level": player_level,
		"player_xp": player_xp,
		"player_gold": player_gold,
		"gear": gear,
		"inventory": inventory,
		"professions": professions,
		"talent_choices": talent_choices,
		"talent_hp_bonus": talent_hp_bonus,
		"layonhands_used": layonhands_used,
		"defeated_bosses": defeated_bosses,
		"reputation": reputation,
		"quests": quests,
		"has_mount": has_mount,
		"mount_name": mount_name,
		"has_combat_pet": has_combat_pet,
		"pet_name": pet_name,
		"current_room": current_room
	}

	# Write to a temp file and rename so a crash mid-write can't corrupt the existing save.
	var tmp_path = SAVE_PATH + ".tmp"
	var file = FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		log_error("Failed to save.")
		return
	file.store_string(JSON.stringify(data))
	file.close()
	var dir = DirAccess.open("user://")
	if dir == null or dir.rename(tmp_path, SAVE_PATH) != OK:
		if dir != null and dir.file_exists(SAVE_PATH.get_file()):
			dir.remove(SAVE_PATH.get_file())
			dir.rename(tmp_path, SAVE_PATH)
		else:
			log_error("Failed to save.")
			return
	log_success("Game saved.")

# JSON turns every number into a float, so coerce where ints are expected.
func save_int(data, key, fallback, min_value = 0):
	var v = data.get(key, fallback)
	if typeof(v) != TYPE_INT and typeof(v) != TYPE_FLOAT:
		return fallback
	return max(int(v), min_value)

func save_str(data, key, fallback = ""):
	var v = data.get(key, fallback)
	return v if typeof(v) == TYPE_STRING else fallback

# Overlays saved values onto defaults so missing or unknown keys never crash.
func merge_saved_dict(defaults, saved):
	var out = defaults.duplicate(true)
	if typeof(saved) != TYPE_DICTIONARY:
		return out
	for key in defaults.keys():
		if not saved.has(key):
			continue
		if typeof(defaults[key]) == TYPE_DICTIONARY:
			out[key] = merge_saved_dict(defaults[key], saved[key])
		elif typeof(saved[key]) == typeof(defaults[key]) or typeof(defaults[key]) == TYPE_NIL:
			out[key] = saved[key]
		elif typeof(defaults[key]) in [TYPE_INT, TYPE_FLOAT] and typeof(saved[key]) in [TYPE_INT, TYPE_FLOAT]:
			out[key] = saved[key]
	return out

func load_character():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		log_error("No save file found.")
		return

	var text = file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		log_error("Save file corrupted.")
		return

	var version = save_int(data, "save_version", 1)
	if version > SAVE_VERSION:
		log_error("This save was made by a newer version of the game.")
		return

	var cls = save_str(data, "player_class")
	var fac = save_str(data, "faction")
	if not GameDatabase.TALENT_TREES.has(cls) or not reputation.has(fac):
		log_error("Save file is missing a valid class or faction.")
		return
	var zone = save_str(data, "starting_zone")
	var room_id = save_str(data, "current_room")
	if not GameDatabase.ROOMS.has(zone):
		log_error("Save file has an unknown starting zone.")
		return
	if not GameDatabase.ROOMS.has(room_id):
		room_id = zone

	faction = fac
	race = save_str(data, "race")
	player_class = cls
	starting_zone = zone
	current_room = room_id

	player_level = save_int(data, "player_level", 1, 1)
	player_xp = save_int(data, "player_xp", 0)
	player_gold = save_int(data, "player_gold", 0)
	player_max_hp = save_int(data, "player_max_hp", 100, 1)
	player_max_mana = save_int(data, "player_max_mana", 50, 0)
	player_hp = clamp(save_int(data, "player_hp", player_max_hp, 1), 1, player_max_hp)
	player_mana = clamp(save_int(data, "player_mana", player_max_mana), 0, player_max_mana)

	gear = merge_saved_dict({"weapon": null, "armor": null, "trinket": null}, data.get("gear"))
	if typeof(data.get("inventory")) == TYPE_DICTIONARY:
		inventory = {}
		for item in data["inventory"].keys():
			inventory[str(item)] = save_int(data["inventory"], item, 0)
	professions = merge_saved_dict(professions, data.get("professions"))
	reputation = merge_saved_dict(reputation, data.get("reputation"))
	quests = merge_saved_dict(quests, data.get("quests"))

	has_mount = data.get("has_mount", false) == true
	mount_name = save_str(data, "mount_name")
	has_combat_pet = data.get("has_combat_pet", false) == true
	pet_name = save_str(data, "pet_name")

	# Talents: v1 saves used a different structure, so those picks are dropped.
	talent_choices = {}
	var saved_choices = data.get("talent_choices", {})
	if typeof(saved_choices) == TYPE_DICTIONARY:
		var tiers = get_class_tiers()
		for key in saved_choices.keys():
			var idx = int(str(key)) - 1
			if idx < 0 or idx >= tiers.size() or player_level < tiers[idx]["level"]:
				continue
			for opt in tiers[idx]["options"]:
				if opt["id"] == saved_choices[key]:
					talent_choices[str(idx + 1)] = opt["id"]
	talent_hp_bonus = save_int(data, "talent_hp_bonus", 0) if not talent_choices.is_empty() else 0
	layonhands_used = data.get("layonhands_used", false) == true
	defeated_bosses = {}
	if typeof(data.get("defeated_bosses")) == TYPE_DICTIONARY:
		for room_key in data["defeated_bosses"].keys():
			if GameDatabase.ROOMS.has(room_key) and data["defeated_bosses"][room_key] == true:
				defeated_bosses[room_key] = true
	pet_damage_bonus = 5 if has_combat_pet else 0

	enemy = null
	in_shop = false
	reset_combat_state()
	player_stealth = false

	game_started = true
	creation_step = 4
	log_success("Game loaded.")
	show_status()
	show_room()

# ============================
# RESPAWN
# ============================
func respawn():
	player_hp = player_max_hp
	player_mana = player_max_mana
	current_room = starting_zone
	enemy = null
	reset_combat_state()
	player_stealth = false
	layonhands_used = false
	in_shop = false
	$Terminal.append_text("[color=cyan]You awaken near your starting camp once more...[/color]\n")
	show_room()
