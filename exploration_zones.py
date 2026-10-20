class Zone:
    """
    Represents a world zone with monsters, bosses, and level information.
    """
    def __init__(self, name, recommended_level, monsters, mini_boss, zone_boss):
        self.name = name
        self.recommended_level = recommended_level  # Tuple of min and max level
        self.monsters = monsters
        self.mini_boss = mini_boss
        self.zone_boss = zone_boss

class Monster:
    """
    Represents a monster or boss with stats, abilities, and drop tables.
    """
    def __init__(self, id, name, level, hp, attack, defense, abilities, exp_reward, gold_reward, drop_table):
        self.id = id
        self.name = name
        self.level = level
        self.hp = hp
        self.max_hp = hp  # Max HP remains constant
        self.attack = attack
        self.defense = defense
        self.abilities = abilities  # List of special moves or effects
        self.exp_reward = exp_reward
        self.gold_reward = gold_reward
        self.drop_table = drop_table  # List of drops with probabilities

# Define The Sunken Catacombs
sunken_catacombs = Zone(
    name="The Sunken Catacombs",
    recommended_level=(15, 25),
    monsters=[
        Monster("crypt_ghoul", "Crypt Ghoul", 18, 150, 20, 10, ["Bite"], 50, 20, ["ancient_bones", "shadow_essence"]),
        Monster("bone_archer", "Bone Archer", 20, 120, 25, 8, ["Arrow Volley"], 60, 25, ["rare_bone_shard"]),
        Monster("necromancer", "Necromancer", 22, 100, 30, 15, ["Summon Skeletons", "Shadow Bolt"], 70, 30, ["arcane_dust"]),
    ],
    mini_boss=Monster("tomb_guardian", "Tomb Guardian", 25, 500, 40, 50, ["Shield Bash", "Counter Strike"], 200, 100, ["tattered_cloak", "magic_ore"]),
    zone_boss=Monster("disciple_lich", "Disciple of the Lich King", 27, 1000, 60, 30, ["Shadow Bolt AOE", "Raise Dead"], 500, 300, ["lich_staff", "shadow_crystal"]),
)

# Define Scorched Peaks
scorched_peaks = Zone(
    name="Scorched Peaks",
    recommended_level=(25, 35),
    monsters=[
        Monster("magma_hound", "Magma Hound", 26, 200, 35, 20, ["Burning Bite"], 80, 50, ["magma_rock"]),
        Monster("fire_drake", "Fire Drake", 28, 180, 40, 25, ["Fire Breath"], 100, 75, ["dragon_scale"]),
        Monster("ash_cultist", "Ash Cultist", 30, 250, 45, 15, ["Flame Surge", "Fire Shield"], 120, 100, ["ashes_of_ember"]),
    ],
    mini_boss=Monster("flame_elemental", "Flame Elemental", 32, 700, 60, 30, ["Burn", "Flame Nova"], 300, 200, ["elemental_core"]),
    zone_boss=Monster("volcanic_wyrm", "Volcanic Wyrm", 35, 2000, 80, 50, ["Lava Burst", "Enrage", "Tail Swipe"], 1000, 500, ["molten_heart", "obsidian_scale"]),
)

zones = {
    "sunken_catacombs": sunken_catacombs,
    "scorched_peaks": scorched_peaks,
}

if __name__ == "__main__":
    for zone_name, zone in zones.items():
        print(f"\nZone: {zone_name} (Recommended Level: {zone.recommended_level[0]}-{zone.recommended_level[1]})")
        print(f"Monsters:")
        for monster in zone.monsters:
            print(f" - {monster.name} (Level {monster.level}): {monster.hp} HP, {monster.attack} ATK, {monster.defense} DEF")
        print(f"Mini-Boss: {zone.mini_boss.name} (Level {zone.mini_boss.level}): {zone.mini_boss.hp} HP")
        print(f"Zone Boss: {zone.zone_boss.name} (Level {zone.zone_boss.level}): {zone.zone_boss.hp} HP")