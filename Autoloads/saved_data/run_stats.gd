## This is what we use to load the stats when we change floor or when we save the game.
## Permanent stats like hp and unlocked armors are stored on [Data]
class_name RunStats extends Resource

signal coins_changed(new_coins: int)

## First eight digits are random seed. Then comes 7 digits for the biome name hash and the last digit is the level
@export var run_seed: int
@export var biome: String = "basecamp"
@export var level: int = 1:
	set(new_value):
		level = new_value

@export var hp: int = Character.DB["player"].max_hp + SavedData.data.get_extra_max_hp()
@export var weapon_stats: Array[WeaponStats] = []
@export var equipped_weapon_index: int = 0

@export var coins: int = 10:
	set(new_coins):
		coins = new_coins
		coins_changed.emit(coins)

@export var armor: Armor = null

@export var permanent_passive_items: Array[PermanentPassiveItem] = []
@export var temporal_passive_items: Array[TemporalPassiveItem] = []

## Bigger luck means more chance to get rare items from chests
@export var luck: int = 50


func get_level_seed() -> int:
	return int(str(run_seed) + str(biome.hash()).left(7) + str(level))
