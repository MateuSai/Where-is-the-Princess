## This is what we use to load the stats when we change floor or when we save the game.
## Permanent stats like hp and unlocked armors are stored on [Data]
class_name RunStats extends Resource

signal coins_changed(new_coins: int)

@export var biome: String = "sewer"
@export var level: int = 1

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
