extends Node
# Data-only autoload: static game definitions. No game state and no UI belongs here.
# Registered in project.godot as the "GameDatabase" autoload.

# ============================
# ITEMS
# ============================
# type: consumable | gear | material. Consumables list their effects; shop_price is optional.
const ITEMS = {
	"potion": {"type": "consumable", "hp": 40, "shop_price": 20, "use_msg": "You drink a potion. HP restored."},
	"ether": {"type": "consumable", "mana": 30, "shop_price": 30, "use_msg": "You use an ether. Mana restored."},
	"healing_draught": {"type": "consumable", "hp": 70, "use_msg": "You drink a potent healing draught. HP greatly restored."},
	"iron_sword": {"type": "gear", "slot": "weapon", "attack_bonus": 6},
	"leather_armor": {"type": "gear", "slot": "armor", "defense_bonus": 4},
	"focus_charm": {"type": "gear", "slot": "trinket", "attack_bonus": 2, "defense_bonus": 1},
	"iron_ore": {"type": "material"},
	"wolf_pelt": {"type": "material"},
	"herb": {"type": "material"},
	"arcane_dust": {"type": "material"},
	"trinket_shard": {"type": "material"}
}

# ============================
# CRAFTING RECIPES
# ============================
const RECIPES = {
	"iron_sword": {
		"profession": "blacksmithing",
		"materials": {"iron_ore": 3, "wolf_pelt": 1},
		"result_item": "iron_sword",
		"slot": "weapon",
		"attack_bonus": 6
	},
	"leather_armor": {
		"profession": "blacksmithing",
		"materials": {"wolf_pelt": 3},
		"result_item": "leather_armor",
		"slot": "armor",
		"defense_bonus": 4
	},
	"healing_draught": {
		"profession": "alchemy",
		"materials": {"herb": 2, "ether": 1},
		"result_item": "healing_draught"
	},
	"focus_charm": {
		"profession": "enchanting",
		"materials": {"arcane_dust": 2, "trinket_shard": 1},
		"result_item": "focus_charm",
		"slot": "trinket",
		"attack_bonus": 2,
		"defense_bonus": 1
	}
}

# ============================
# ROOMS
# ============================
# Exit keys: forward / left / right / back. "boss": true marks a one-time boss encounter.
const ROOMS = {
	# Starting zones
	"dawnwatch_outpost": {
		"desc": "Dawnwatch Outpost: timber walls and watchtowers guard the Mistwood frontier.",
		"forward": "mistwood_edge",
		"enemy_chance": 5,
		"music": "camp_theme"
	},
	"emberfall_camp": {
		"desc": "Emberfall Camp: braziers and banners, steel and prayer mingling in the air.",
		"forward": "mistwood_edge",
		"enemy_chance": 5,
		"music": "camp_theme"
	},
	"stonegate_hold": {
		"desc": "Stonegate Hold: carved from cliffstone, runes hum beneath your boots.",
		"forward": "mistwood_edge",
		"enemy_chance": 5,
		"music": "camp_theme"
	},
	"bloodfang_warcamp": {
		"desc": "Bloodfang Warcamp: crude spikes, roaring fires, and the smell of iron and smoke.",
		"forward": "mistwood_edge",
		"enemy_chance": 8,
		"music": "warcamp_theme"
	},
	"shadow_hollow": {
		"desc": "Shadow Hollow: a sunless ravine where lanterns burn violet and whispers cling to stone.",
		"forward": "mistwood_edge",
		"enemy_chance": 10,
		"music": "shadow_theme"
	},
	"briar_thicket": {
		"desc": "Briar Thicket: tangled roots and thorned vines, the wild pressing close around you.",
		"forward": "mistwood_edge",
		"enemy_chance": 8,
		"music": "forest_theme"
	},

	# Shared forest region
	"mistwood_edge": {
		"desc": "Mistwood Edge: ancient trees loom overhead, mist curling around their roots.",
		"forward": "forest_path",
		"back": "campfire_rest",
		"enemy_chance": 15,
		"music": "forest_theme"
	},
	"campfire_rest": {
		"desc": "A quiet campfire circle, abandoned but still warm. A rare pocket of safety.",
		"forward": "mistwood_edge",
		"enemy_chance": 0,
		"music": "camp_theme"
	},
	"forest_path": {
		"desc": "A narrow path winds deeper into the woods. Strange whispers ride the wind.",
		"forward": "deep_woods",
		"left": "wolf_den",
		"right": "shrine",
		"back": "mistwood_edge",
		"enemy_chance": 25,
		"music": "forest_theme"
	},
	"wolf_den": {
		"desc": "Bones and claw marks litter the ground. This is clearly a predator's lair.",
		"back": "forest_path",
		"enemy_chance": 40,
		"music": "danger_theme"
	},
	"shrine": {
		"desc": "An old stone shrine covered in moss. Faint runes glow with forgotten magic.",
		"back": "forest_path",
		"enemy_chance": 15,
		"music": "mystic_theme"
	},
	"deep_woods": {
		"desc": "The trees grow taller and thicker here. Light barely reaches the forest floor.",
		"forward": "ruined_tower",
		"left": "merchant_trail",
		"right": "dungeon_entrance",
		"back": "forest_path",
		"enemy_chance": 35,
		"music": "forest_deep_theme"
	},
	"merchant_trail": {
		"desc": "A worn trail with cart tracks. You hear the clink of coin and quiet muttering.",
		"forward": "forest_merchant",
		"back": "deep_woods",
		"enemy_chance": 10,
		"music": "merchant_theme"
	},
	"forest_merchant": {
		"desc": "A robed figure stands beside a cart of goods. The Forest Merchant eyes you carefully.",
		"back": "merchant_trail",
		"enemy_chance": 0,
		"music": "merchant_theme"
	},
	"ruined_tower": {
		"desc": "A crumbling stone tower rises above the treeline. Shadows move in the broken windows.",
		"forward": "tower_heart",
		"back": "deep_woods",
		"enemy_chance": 40,
		"music": "tower_theme"
	},
	"tower_heart": {
		"desc": "Inside the tower, a cold presence fills the air. This feels like a place of final battles.",
		"back": "ruined_tower",
		"enemy_chance": 60,
		"music": "boss_theme"
	},

	# Dungeon
	"dungeon_entrance": {
		"desc": "A stone arch yawns open into darkness. Faint chanting echoes from within.",
		"forward": "dungeon_hall",
		"back": "deep_woods",
		"enemy_chance": 20,
		"music": "dungeon_theme"
	},
	"dungeon_hall": {
		"desc": "A long hall lined with broken statues. The air is heavy and still.",
		"forward": "dungeon_chamber",
		"back": "dungeon_entrance",
		"enemy_chance": 40,
		"music": "dungeon_theme"
	},
	"dungeon_chamber": {
		"desc": "A wide chamber with a cracked floor. You feel eyes on you from the shadows.",
		"forward": "dungeon_boss_room",
		"back": "dungeon_hall",
		"enemy_chance": 50,
		"music": "dungeon_theme"
	},
	"dungeon_boss_room": {
		"desc": "A vast room dominated by a shattered altar. Power hums in the air.",
		"back": "dungeon_chamber",
		"enemy_chance": 80,
		"music": "boss_theme",
		"boss": true,
		"cleared_desc": "The shattered altar lies silent. Whatever haunted this room is gone."
	}
}

# ============================
# TALENT TREES
# ============================
# Class ids: guardian = Warrior, mage = Mage, slayer = Rogue, warden = Cleric/Paladin.
# Per option:
#   id, name, desc  - identity and display text
#   mods            - flat numeric modifiers summed by the stat pipeline:
#                     hp_pct, armor, melee_dmg_pct, crit_chance, crit_damage, evasion,
#                     mana_cost_pct, execute_dmg_pct, ...
#   command         - optional command unlocked by the talent
# Behavioural talents (shields, procs, reflects) are implemented in combat code by id.
const TALENT_TREES = {
	"guardian": {
		"title": "WARRIOR",
		"tiers": [
			{"level": 5, "name": "Combat Stance", "options": [
				{"id": "brawler", "name": "Brawler", "desc": "+15% Physical Damage with melee attacks", "mods": {"melee_dmg_pct": 0.15}},
				{"id": "juggernaut", "name": "Juggernaut", "desc": "+20% Max HP, +10 Armor", "mods": {"hp_pct": 0.20, "armor": 10}}
			]},
			{"level": 10, "name": "Battle Mastery", "options": [
				{"id": "executioner", "name": "Executioner", "desc": "+30% damage to targets under 30% HP", "mods": {"execute_dmg_pct": 0.30}},
				{"id": "ironclad", "name": "Ironclad", "desc": "Emergency Shield (25% Max HP, 3 turns) under 35% HP, once per combat", "mods": {}}
			]},
			{"level": 15, "name": "Heroic Capstone", "options": [
				{"id": "whirlwind_fury", "name": "Whirlwind Fury", "desc": "Unlocks 'whirlwind' command: 80% weapon damage to all enemies", "command": "whirlwind", "mods": {}},
				{"id": "unyielding_sentinel", "name": "Unyielding Sentinel", "desc": "Reflect 20% of incoming physical damage", "mods": {"reflect_pct": 0.20}}
			]}
		]
	},
	"mage": {
		"title": "MAGE",
		"tiers": [
			{"level": 5, "name": "Arcane Mastery", "options": [
				{"id": "pyromancy", "name": "Pyromancy", "desc": "Fire spells burn for 10% of damage per turn for 3 turns", "mods": {}},
				{"id": "subtle_magic", "name": "Subtle Magic", "desc": "-20% mana cost on all spells", "mods": {"mana_cost_pct": -0.20}}
			]},
			{"level": 10, "name": "Metamagic", "options": [
				{"id": "spellweave", "name": "Spellweave", "desc": "Each cast gives +5% spell crit chance, stacks up to 4", "mods": {}},
				{"id": "arcane_barrier", "name": "Arcane Barrier", "desc": "15% of damage taken is absorbed by Mana", "mods": {}}
			]},
			{"level": 15, "name": "High Sorcery", "options": [
				{"id": "chain_impact", "name": "Chain Impact", "desc": "Single-target spells have 30% chance to jump to a second target for 70% damage", "mods": {}},
				{"id": "time_warp", "name": "Time Warp", "desc": "Unlocks 'timewarp' command: reset all spell cooldowns (10 turn cooldown)", "command": "timewarp", "mods": {}}
			]}
		]
	},
	"slayer": {
		"title": "ROGUE",
		"tiers": [
			{"level": 5, "name": "Precision", "options": [
				{"id": "lethality", "name": "Lethality", "desc": "+10% Crit Chance, +25% Crit Damage", "mods": {"crit_chance": 0.10, "crit_damage": 0.25}},
				{"id": "fleet_footed", "name": "Fleet Footed", "desc": "+15% Evasion", "mods": {"evasion": 0.15}}
			]},
			{"level": 10, "name": "Underhanded Tactics", "options": [
				{"id": "venomous_blades", "name": "Venomous Blades", "desc": "Basic attacks poison enemies (Nature damage, reduced healing)", "mods": {}},
				{"id": "shadow_step", "name": "Shadow Step", "desc": "Attacks from Stealth always crit and ignore 100% Armor", "mods": {}}
			]},
			{"level": 15, "name": "Master Assassin", "options": [
				{"id": "flurry_of_steel", "name": "Flurry of Steel", "desc": "25% chance for an extra off-hand strike", "mods": {}},
				{"id": "vanish", "name": "Vanish", "desc": "Unlocks 'vanish' command: escape combat and re-enter Stealth", "command": "vanish", "mods": {}}
			]}
		]
	},
	"warden": {
		"title": "CLERIC",
		"tiers": [
			{"level": 5, "name": "Devotion", "options": [
				{"id": "smite_the_unworthy", "name": "Smite the Unworthy", "desc": "Holy spells deal +20% damage to Undead/Demons", "mods": {}},
				{"id": "blessed_light", "name": "Blessed Light", "desc": "+20% healing from spells and items", "mods": {"healing_pct": 0.20}}
			]},
			{"level": 10, "name": "Aegis", "options": [
				{"id": "divine_grace", "name": "Divine Grace", "desc": "Debuffs on you last 50% fewer turns", "mods": {}},
				{"id": "retribution", "name": "Retribution", "desc": "Taking damage grants Zeal: +3% damage per stack, max 5", "mods": {}}
			]},
			{"level": 15, "name": "Avatar", "options": [
				{"id": "lay_on_hands", "name": "Lay on Hands", "desc": "Unlocks 'layonhands' command: full heal, once per run", "command": "layonhands", "mods": {}},
				{"id": "aura_of_protection", "name": "Aura of Protection", "desc": "Party gains +15 Armor and +10% Elemental Resistance", "mods": {"armor": 15, "elemental_resist": 0.10}}
			]}
		]
	}
}
