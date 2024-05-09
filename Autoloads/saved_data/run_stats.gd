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
@export var _permanent_passive_items_ids: PackedStringArray = []
@export var temporal_passive_items: Array[TemporalPassiveItem] = []

## Bigger luck means more chance to get rare items from chests
@export var luck: int = 0

func get_level_seed() -> int:
	return int(str(run_seed) + str(biome.hash()).left(7) + str(level))

func add_permanent_passive_item(item: PermanentPassiveItem) -> void:
	assert(not _permanent_passive_items.has(item))
	assert(not _permanent_passive_items_ids.has(item.get_id()))

	_permanent_passive_items.push_back(item)
	_permanent_passive_items_ids.push_back(item.get_id())

func remove_permanent_passive_item(item: PermanentPassiveItem) -> void:
	_permanent_passive_items.erase(item)
	# Note that I don't remove the item from _permanent_passive_items_names, so the item won't appear again on chest or shops. This is useful when we convert the item to cursed, we don't want the item to appear again

func get_passive_items() -> Array[PassiveItem]:
	var res: Array[PassiveItem] = []
	var per: Array[PermanentPassiveItem] = _permanent_passive_items.duplicate()
	res.assign(per)

	var tem: Array[TemporalPassiveItem] = temporal_passive_items.duplicate()
	var adapted_tem: Array[PassiveItem] = []
	adapted_tem.assign(tem)

	res.append_array(adapted_tem)
	return res

func get_permanent_passive_items() -> Array[PermanentPassiveItem]:
	return _permanent_passive_items

func get_permanent_passive_items_ids() -> PackedStringArray:
	return _permanent_passive_items_ids

func get_amount_of_temporl_passive_items_of_type(item: TemporalPassiveItem) -> int:
	Log.debug(item.get_id())

	var amount: int = 0

	for temporal_item: TemporalPassiveItem in temporal_passive_items:
		Log.debug(temporal_item.get_id())
		if temporal_item.get_id() == item.get_id():
			amount += 1

	return amount

func _on_free() -> void:
	for permanent_item: PermanentPassiveItem in _permanent_passive_items:
		permanent_item.unequip(Globals.player)
