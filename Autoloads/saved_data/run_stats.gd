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

@export var _permanent_passive_items: Array[PermanentPassiveItem] = []
@export var _permanent_passive_items_names: PackedStringArray = []
@export var temporal_passive_items: Array[TemporalPassiveItem] = []

## Bigger luck means more chance to get rare items from chests
@export var luck: int = 50


func get_level_seed() -> int:
	return int(str(run_seed) + str(biome.hash()).left(7) + str(level))


func add_permanent_passive_item(item: PermanentPassiveItem) -> void:
	assert(not _permanent_passive_items.has(item))
	assert(not _permanent_passive_items_names.has(item.get_item_name()))

	_permanent_passive_items.push_back(item)
	_permanent_passive_items_names.push_back(item.get_item_name())


func get_permanent_passive_items() -> Array[PermanentPassiveItem]:
	return _permanent_passive_items


func get_permanent_passive_items_names() -> PackedStringArray:
	return _permanent_passive_items_names


func get_amount_of_temporl_passive_items_of_type(item: Object) -> int:
	var amount: int = 0

	for temporal_item: TemporalPassiveItem in temporal_passive_items:
		if typeof(temporal_item) == typeof(item):
			amount += 1

	return amount


func _on_free() -> void:
	for permanent_item: PermanentPassiveItem in _permanent_passive_items:
		permanent_item.unequip(Globals.player)
