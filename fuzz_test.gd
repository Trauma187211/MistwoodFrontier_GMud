extends SceneTree
# Headless fuzz test. Run from the project folder with:
#   godot --headless --path . -s fuzz_test.gd -- [runs] [commands_per_run] [seed]
# Example: godot --headless --path . -s fuzz_test.gd -- 20 400 1234
#
# GDScript runtime errors (null access, missing keys, bad calls) do NOT throw; the engine
# prints "SCRIPT ERROR:" to stderr and keeps going. Check the whole output for that text.
# This runner additionally fails on broken game-state invariants and prints the command
# history that led to each failure. It never touches save files (save/load are not fuzzed).

const CLASSES = ["guardian", "slayer", "warden", "mage"]
const FACTION_RACES = {"vanguard": ["human", "highborn", "stonekin"], "bloodborn": ["ravager", "shade", "wildling"]}

var COMMANDS = [
	"move forward", "move back", "move left", "move right", "move up", "move",
	"forward", "back", "attack", "attack attack", "flee",
	"cast fire", "cast fireball", "cast meteor", "cast holy", "cast heal", "cast bogus", "cast",
	"use potion", "use ether", "use healing_draught", "use iron_sword", "use bogus", "use",
	"inventory", "status", "help", "recipes",
	"shop", "buy potion", "buy ether", "buy sword", "buy", "leave",
	"craft iron_sword", "craft leather_armor", "craft healing_draught", "craft focus_charm", "craft nothing", "craft",
	"equip weapon iron_sword", "equip armor leather_armor", "equip trinket focus_charm", "equip hat potion", "equip weapon",
	"profession blacksmithing", "profession alchemy", "profession enchanting", "profession skinning", "profession bogus", "profession",
	"talents", "talents list", "talents current", "talents reset", "talents choose", "talents choose 1", "talents choose 2",
	"talents choose 3", "talents choose 4", "talents choose 5", "talents choose 6", "talents choose 99", "talents choose bogus",
	"talents bogus", "talent", "whirlwind", "timewarp", "vanish", "layonhands", "stealth",
	"mount horse", "mount", "pet wolf", "pet", "talk merchant", "talk elder", "talk nobody", "talk",
	"", "   ", "???", "[b]bold[/b]", "[", "]", "ATTACK", "save_me", "x".repeat(500)
]

var rng = RandomNumberGenerator.new()
var failures = 0
var total_commands = 0

func _initialize():
	var args = OS.get_cmdline_user_args()
	var runs = int(args[0]) if args.size() > 0 else 20
	var per_run = int(args[1]) if args.size() > 1 else 400
	var base_seed = int(args[2]) if args.size() > 2 else int(Time.get_unix_time_from_system())
	print("FUZZ: runs=%d commands/run=%d base_seed=%d" % [runs, per_run, base_seed])

	var scene = load("res://control.tscn")
	for run in range(runs):
		var run_seed = base_seed + run
		run_once(scene, run_seed, per_run)

	print("FUZZ DONE: %d commands, %d failing runs" % [total_commands, failures])
	failures += run_targeted(scene)
	print("TARGETED: %s" % ("all passed" if targeted_failures.is_empty() else "FAILED: %s" % str(targeted_failures)))
	print("Coverage: %s | rooms visited: %d/%d | gear equipped: %s" % [coverage, rooms_seen.size(), GameDatabase.ROOMS.size(), gear_seen.keys()])
	print("Reminder: also search the output for 'SCRIPT ERROR' (engine-level errors).")
	quit(1 if failures > 0 else 0)

func run_once(scene, run_seed, per_run):
	rng.seed = run_seed
	seed(run_seed) # the game uses the global randi()/randf()
	var game = scene.instantiate()
	root.add_child(game)

	var history = []
	if not create_character(game, history):
		fail(game, run_seed, history, "character creation did not complete")
		game.queue_free()
		return

	# Varied power levels so every talent tier and spell is reachable.
	game.player_level = rng.randi_range(1, 20)
	if run_seed % 2 == 0:
		# Tanky variant: survives long enough to reach boss kills and low-HP triggers.
		game.player_max_hp = 600
		game.player_hp = 600
		game.player_max_mana = 400
		game.player_mana = 400
		game.base_attack = 60
	game.player_gold = rng.randi_range(0, 500)
	for mat in ["iron_ore", "wolf_pelt", "herb", "arcane_dust", "trinket_shard", "potion", "ether"]:
		game.inventory[mat] = rng.randi_range(0, 6)

	for i in range(per_run):
		var cmd = COMMANDS[rng.randi() % COMMANDS.size()]
		history.append(cmd)
		if history.size() > 40:
			history.pop_front()
		total_commands += 1
		game.process_command(cmd.strip_edges().to_lower())
		track_coverage(game)
		var problem = check_invariants(game)
		if problem != "":
			fail(game, run_seed, history, problem)
			break
		# Occasionally top up so the run keeps exercising deeper paths.
		if i % 60 == 59:
			game.player_gold += 100
			game.inventory["potion"] = game.inventory.get("potion", 0) + 2
			game.inventory["ether"] = game.inventory.get("ether", 0) + 2

	game.queue_free()

func create_character(game, history):
	var faction = FACTION_RACES.keys()[rng.randi() % FACTION_RACES.size()]
	var races = FACTION_RACES[faction]
	var steps = ["start", faction, races[rng.randi() % races.size()], CLASSES[rng.randi() % CLASSES.size()]]
	for s in steps:
		history.append(s)
		game.process_command(s)
	return game.game_started

func check_invariants(g):
	if g.player_hp <= 0 or g.player_hp > g.player_max_hp:
		return "HP out of range: %d/%d" % [g.player_hp, g.player_max_hp]
	if g.player_mana < 0 or g.player_mana > g.player_max_mana:
		return "Mana out of range: %d/%d" % [g.player_mana, g.player_max_mana]
	if g.player_max_hp < 1:
		return "max HP below 1"
	if g.player_gold < 0:
		return "negative gold: %d" % g.player_gold
	if g.player_shield < 0:
		return "negative shield"
	for item in g.inventory.keys():
		if g.inventory[item] < 0:
			return "negative inventory: %s=%d" % [item, g.inventory[item]]
	if not GameDatabase.ROOMS.has(g.current_room):
		return "invalid room: %s" % g.current_room
	if g.enemy != null and g.enemy["hp"] <= 0:
		return "dead enemy still in combat: %s" % g.enemy["name"]
	if g.in_combat != (g.enemy != null):
		return "in_combat out of sync"
	if g.in_combat and g.in_shop:
		return "in shop while in combat"
	if g.zeal < 0 or g.zeal > 5 or g.spellweave_stacks < 0 or g.spellweave_stacks > 4:
		return "buff stacks out of range (zeal=%d spellweave=%d)" % [g.zeal, g.spellweave_stacks]
	for key in g.talent_choices.keys():
		var idx = int(key) - 1
		var tiers = g.get_class_tiers()
		if idx < 0 or idx >= tiers.size() or g.player_level < tiers[idx]["level"]:
			return "talent chosen below its level requirement: tier %s" % key
	for stat in [g.get_total_attack(), g.get_total_defense(), g.get_elemental_resist()]:
		if is_nan(float(stat)) or is_inf(float(stat)):
			return "NaN/inf stat"
	for spell in GameDatabase.SPELLS.keys():
		if g.get_spell_cost(spell) < 1:
			return "spell %s costs less than 1 mana" % spell
	return ""

var coverage = {"in_combat_steps": 0, "shop_steps": 0, "boss_kills": 0, "max_talents": 0, "stealth_steps": 0, "burning_steps": 0, "shield_steps": 0}
var rooms_seen = {}
var gear_seen = {}

func track_coverage(g):
	rooms_seen[g.current_room] = true
	if g.in_combat: coverage["in_combat_steps"] += 1
	if g.in_shop: coverage["shop_steps"] += 1
	if g.player_stealth: coverage["stealth_steps"] += 1
	if g.burn_turns > 0 or g.poison_turns > 0: coverage["burning_steps"] += 1
	if g.player_shield > 0: coverage["shield_steps"] += 1
	coverage["boss_kills"] = max(coverage["boss_kills"], g.defeated_bosses.size())
	coverage["max_talents"] = max(coverage["max_talents"], g.talent_choices.size())
	for slot in g.gear.keys():
		if g.gear[slot] != null: gear_seen[g.gear[slot]] = true

var targeted_failures = []

func expect(cond, label):
	if not cond:
		targeted_failures.append(label)

func new_game(scene, cls):
	var g = scene.instantiate()
	root.add_child(g)
	for s in ["start", "vanguard", "human", cls]:
		g.process_command(s)
	return g

func run_targeted(scene):
	seed(1)
	var g = new_game(scene, "mage")

	# Fire costs 10% less (10 -> 9) and "fireball" is an alias.
	expect(g.get_spell_cost("fire") == 9, "mage fire cost is 9")
	g.player_mana = 50
	g.spawn_enemy()
	g.enemy["hp"] = 100000
	g.enemy["max_hp"] = 100000
	g.process_command("cast fireball")
	expect(g.player_mana == 41, "fireball alias spends 9 mana (got %d)" % g.player_mana)
	g.player_mana = 8
	g.process_command("cast fire")
	expect(g.player_mana == 8, "cast with insufficient mana spends nothing")

	# Items cost a combat turn (enemy retaliates) and non-combat actions are blocked.
	g.player_hp = g.player_max_hp
	g.player_max_hp = 1000
	g.player_hp = 500
	g.inventory["potion"] = 2
	g.enemy["dmg_min"] = 30
	g.enemy["dmg_max"] = 31
	g.player_shield = 0
	g.process_command("use potion")
	expect(g.inventory["potion"] == 1, "potion consumed")
	expect(g.player_hp < 500 + 40, "enemy retaliated after potion (hp %d)" % g.player_hp)
	g.player_gold = 500
	g.inventory["iron_ore"] = 9
	g.inventory["wolf_pelt"] = 9
	g.professions["blacksmithing"] = true
	for cmd in ["craft iron_sword", "equip weapon potion", "profession alchemy", "talk elder", "shop"]:
		var before = [g.inventory.duplicate(), g.gear.duplicate(), g.professions.duplicate(), g.in_shop]
		g.process_command(cmd)
		expect([g.inventory, g.gear, g.professions, g.in_shop] == before, "'%s' blocked in combat" % cmd)
	g.process_command("move forward")
	expect(g.in_combat, "cannot walk out of combat")
	g.queue_free()

	# Boss rooms spawn once, and the defeat is remembered.
	g = new_game(scene, "guardian")
	g.player_max_hp = 100000
	g.player_hp = 100000
	g.current_room = "dungeon_chamber"
	g.process_command("move forward")
	expect(g.in_combat and g.enemy.has("boss_room"), "boss spawns on first entry")
	g.enemy["hp"] = 1
	g.process_command("attack")
	for i in range(30):
		if g.in_combat and g.enemy["hp"] > 0:
			g.process_command("attack")
	expect(not g.in_combat, "boss was killed")
	expect(g.defeated_bosses.get("dungeon_boss_room", false), "defeat flag set")
	g.process_command("move back")
	g.process_command("move forward")
	expect(not g.in_combat, "boss does not respawn after defeat")

	# Ironclad: shield triggers once when dropping under 35% HP.
	g.defeated_bosses = {}
	g.current_room = "campfire_rest"
	g.player_level = 10
	g.talent_choices = {"2": "ironclad"}
	g.player_max_hp = 100
	g.player_hp = 40
	g.spawn_enemy()
	g.enemy["dmg_min"] = 10
	g.enemy["dmg_max"] = 11
	g.enemy["hp"] = 100000
	g.enemy["max_hp"] = 100000
	g.take_damage(10)
	expect(g.player_shield == 25 and g.ironclad_used, "ironclad grants 25%% max HP shield (shield %d)" % g.player_shield)
	g.queue_free()

	return targeted_failures.size()

func fail(game, run_seed, history, problem):
	failures += 1
	print("FUZZ FAIL (seed %d, class %s, level %d, room %s): %s" % [run_seed, game.player_class, game.player_level, game.current_room, problem])
	print("  last commands: %s" % " | ".join(history))
