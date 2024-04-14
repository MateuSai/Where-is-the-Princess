class_name Data

const SAVE_NAME: String = "data.json"

#region Data available from start
const ALL_VANILLA_WEAPONS: PackedStringArray = ["res://Weapons/Dagger.tscn", "res://Weapons/Melee/branch/branch.tscn", "res://Weapons/Melee/Katana/Katana.tscn", "res://Weapons/Melee/spear/Spear.tscn", "res://Weapons/Melee/DragonKiller/DragonKiller.tscn", "res://Weapons/Melee/KombatHammer/KombatHammer.tscn", "res://Weapons/Melee/OrcSword/OrcSword.tscn", "res://Weapons/Melee/Scimitar/Scimitar.tscn", "res://Weapons/Melee/SharpAxe/SharpAxe.tscn", "res://Weapons/Melee/SmallAxe/SmallAxe.tscn", "res://Weapons/Melee/WarAxe/WarAxe.tscn", "res://Weapons/Melee/WarHammer/WarHammer.tscn", "res://Weapons/Melee/WarriorSword/WarriorSword.tscn", "res://Weapons/Ranged/Bows/WoodenBow/wooden_bow.tscn", "res://Weapons/Ranged/Bows/short_wooden_bow/short_wooden_bow.tscn", "res://Weapons/Melee/rusty_sword/rusty_sword.tscn", "res://Weapons/Ranged/crossbows/wooden_crossbow/wooden_crossbow.tscn", "res://Weapons/Ranged/crossbows/royal_crossbow/royal_crossbow.tscn"]
const AVAILABLE_WEAPONS_FROM_START: PackedStringArray = ["res://Weapons/Melee/Katana/Katana.tscn", "res://Weapons/Melee/spear/Spear.tscn", "res://Weapons/Melee/DragonKiller/DragonKiller.tscn", "res://Weapons/Melee/KombatHammer/KombatHammer.tscn", "res://Weapons/Melee/OrcSword/OrcSword.tscn", "res://Weapons/Melee/Scimitar/Scimitar.tscn", "res://Weapons/Melee/SharpAxe/SharpAxe.tscn", "res://Weapons/Melee/SmallAxe/SmallAxe.tscn", "res://Weapons/Melee/WarAxe/WarAxe.tscn", "res://Weapons/Melee/WarHammer/WarHammer.tscn", "res://Weapons/Melee/WarriorSword/WarriorSword.tscn", "res://Weapons/Ranged/Bows/WoodenBow/wooden_bow.tscn", "res://Weapons/Ranged/crossbows/royal_crossbow/royal_crossbow.tscn"]

const ALL_VANILLA_ARMORS: PackedStringArray = ["res://Armors/CommonerClothes.gd", "res://Armors/LeatherArmor.gd", "res://Armors/MercenaryArmor.gd", "res://Armors/WarriorArmor.gd", "res://Armors/NecromancerArmor.gd", "res://Armors/improvised_armor.gd", "res://Armors/farmer_clothes.gd", "res://Armors/plague_armor.gd", "res://Armors/ronin_armor.gd"]
const AVAILABLE_ARMORS_FROM_START: PackedStringArray = ["res://Armors/CommonerClothes.gd", "res://Armors/LeatherArmor.gd", "res://Armors/MercenaryArmor.gd", "res://Armors/WarriorArmor.gd", "res://Armors/NecromancerArmor.gd", "res://Armors/improvised_armor.gd", "res://Armors/farmer_clothes.gd", "res://Armors/plague_armor.gd", "res://Armors/ronin_armor.gd"]

const ALL_VANILLA_CONSUMABLE_ITEMS: PackedStringArray = ["res://items/food.gd", "res://items/armor_shard.gd", "res://items/double_armor_shard.gd", "res://items/whetstone.gd", "res://items/godly_whetstone.gd"]

const ALL_VANILLA_WEAPON_MODIFIERS: PackedStringArray = ["res://items/Passive/WeaponModifiers/ruby.gd", "res://items/Passive/WeaponModifiers/sapphire.gd", "res://items/Passive/WeaponModifiers/topaz.gd", "res://items/Passive/WeaponModifiers/emerald.gd", "res://items/Passive/WeaponModifiers/arrows/bouncing_arrow_modifier.gd", "res://items/Passive/WeaponModifiers/arrows/explosive_arrow_modifier.gd", "res://items/Passive/WeaponModifiers/arrows/homing_arrow_modifier.gd", "res://items/Passive/WeaponModifiers/arrows/piercing_arrow_modifier.gd"]

const ALL_VANILLA_PERMANENT_ITEMS: PackedStringArray = ["res://items/Passive/Permanent/target.gd", "res://items/Passive/Permanent/iron_skin.gd", "res://items/Passive/Permanent/enhanced_boots.gd", "res://items/Passive/Permanent/meteor_stone.gd", "res://items/Passive/Permanent/SoulAmulet.gd", "res://items/Passive/Permanent/runes/AxeRune.gd", "res://items/Passive/Permanent/runes/HammerRune.gd", "res://items/Passive/Permanent/runes/MeleeRune.gd", "res://items/Passive/Permanent/runes/SpearRune.gd", "res://items/Passive/Permanent/runes/SwordRune.gd", "res://items/Passive/Permanent/acid_boots.gd", "res://items/Passive/Permanent/orb_of_the_berserker.gd", "res://items/Passive/Permanent/bigger_rations.gd", "res://items/Passive/Permanent/projectile_orb.gd", "res://items/Passive/Permanent/money_bag.gd", "res://items/Passive/Permanent/broken_sword.gd", "res://items/Passive/Permanent/heart_stone.gd", "res://items/Passive/Permanent/stone_heart.gd", "res://items/Passive/Permanent/aggression_spell.gd", "res://items/Passive/Permanent/heart_rock.gd"]
const AVAILABLE_PERMANENT_ITEMS_FROM_START: PackedStringArray = ["res://items/Passive/Permanent/target.gd", "res://items/Passive/Permanent/iron_skin.gd", "res://items/Passive/Permanent/enhanced_boots.gd", "res://items/Passive/Permanent/meteor_stone.gd", "res://items/Passive/Permanent/SoulAmulet.gd", "res://items/Passive/Permanent/runes/AxeRune.gd", "res://items/Passive/Permanent/runes/HammerRune.gd", "res://items/Passive/Permanent/runes/MeleeRune.gd", "res://items/Passive/Permanent/runes/SpearRune.gd", "res://items/Passive/Permanent/runes/SwordRune.gd", "res://items/Passive/Permanent/acid_boots.gd", "res://items/Passive/Permanent/orb_of_the_berserker.gd", "res://items/Passive/Permanent/bigger_rations.gd", "res://items/Passive/Permanent/projectile_orb.gd", "res://items/Passive/Permanent/money_bag.gd", "res://items/Passive/Permanent/broken_sword.gd", "res://items/Passive/Permanent/heart_stone.gd", "res://items/Passive/Permanent/stone_heart.gd", "res://items/Passive/Permanent/aggression_spell.gd"]

const ALL_VANILLA_TEMPORAL_ITEMS: PackedStringArray = ["res://items/Passive/Temporal/magic_shields/wooden_magic_shield.gd", "res://items/Passive/Temporal/magic_shields/reinforced_magic_shield.gd", "res://items/Passive/Temporal/MagicSword.gd", "res://items/Passive/Temporal/spike.gd", "res://items/Passive/Temporal/fairy.gd"]
const AVAILABLE_TEMPORAL_ITEMS_FROM_START: PackedStringArray = ["res://items/Passive/Temporal/magic_shields/wooden_magic_shield.gd", "res://items/Passive/Temporal/magic_shields/reinforced_magic_shield.gd", "res://items/Passive/Temporal/MagicSword.gd", "res://items/Passive/Temporal/spike.gd", "res://items/Passive/Temporal/fairy.gd"]

const ALL_VANILLA_PLAYER_UPGRADES: PackedStringArray = ["res://items/player_upgrades/additional_heart.gd", "res://items/player_upgrades/additional_movement_speed.gd", "res://items/player_upgrades/additional_weapon_carry_capacity.gd", "res://items/player_upgrades/additional_max_stamina.gd"]
const AVAILABLE_PLAYER_UPGRADES_FROM_START: PackedStringArray = ["res://items/player_upgrades/additional_heart.gd", "res://items/player_upgrades/additional_movement_speed.gd", "res://items/player_upgrades/additional_weapon_carry_capacity.gd", "res://items/player_upgrades/additional_max_stamina.gd"]

const ALL_VANILLA_BIOMES: PackedStringArray = ["basecamp", "forest", "sewer", "crates"]
#endregion

var dark_souls: int = 0

var ignored_rooms: PackedStringArray = []

var _extra_available_weapons: PackedStringArray = []
var _discovered_weapons: PackedStringArray = ["res://Weapons/Dagger.tscn"]

var equipped_armor: String = "res://Armors/underpants.gd"
var _extra_available_armors: PackedStringArray = []
var _discovered_armors: PackedStringArray = []

var _extra_available_permanent_items: PackedStringArray = []
## @deprecated
var _discovered_permanent_items: PackedStringArray = []
var _extra_available_temporal_items: PackedStringArray = []
## @deprecated
var _discovered_temporal_items: PackedStringArray = []

var player_upgrades: Array[PlayerUpgrade] = []

var _completed_dialogues: PackedStringArray = []

var items_shop_unlocked: bool = false
var player_upgrades_shop_unlocked: bool = false

var show_save_and_return_window: bool = true: set = set_show_save_and_return_window

func save() -> void:
	var file: FileAccess = FileAccess.open(SavedData.USER_FOLDER + SAVE_NAME, FileAccess.WRITE)
	if not file:
		printerr("Error opening " + SavedData.USER_FOLDER + SAVE_NAME + " for writing!! I can't save your data, bro")
		return
	file.store_string(JSON.stringify(to_dic(), "\t"))
	file.close()
	#print(JSON.new().stringify(data, "\t"))

static func _load() -> Data:
	var file: FileAccess = FileAccess.open(SavedData.USER_FOLDER + SAVE_NAME, FileAccess.READ)
	if file:
		print("Save data found. Loading it...")
		var json: JSON = JSON.new()
		json.parse(file.get_as_text())
		if json.data is Dictionary:
			return Data.from_dic(json.data as Dictionary)
		else:
			printerr("Could not load file data as json, using default values...")
	else:
		print("No save data found, using default value...")

	return Data.new()

func get_extra_max_hp() -> int:
	var extra_hp: int = 0

	for player_upgrade: PlayerUpgrade in player_upgrades:
		if player_upgrade is AdditionalHeart:
			extra_hp += 4 * player_upgrade.amount
			break

	return extra_hp

func can_pick_up_player_upgrade(item_name: String) -> int:
	for player_upgrade: PlayerUpgrade in player_upgrades:
		if player_upgrade.get_item_name() == item_name:
			return player_upgrade.amount < player_upgrade.get_max_amount()

	return true

func get_available_weapons() -> PackedStringArray:
	var arr: Array = _extra_available_weapons.duplicate()
	arr.append_array(AVAILABLE_WEAPONS_FROM_START)
	return PackedStringArray(arr)

func discover_weapon_if_not_already(weapon_path: String) -> void:
	if not _discovered_weapons.has(weapon_path):
		_discovered_weapons.push_back(weapon_path)
		save()

func get_discovered_weapons() -> PackedStringArray:
	return _discovered_weapons.duplicate()

func get_available_armors() -> PackedStringArray:
	var arr: Array = _extra_available_armors.duplicate()
	arr.append_array(AVAILABLE_ARMORS_FROM_START)
	return PackedStringArray(arr)

func discover_armor_if_not_already(armor_path: String) -> void:
	if not _discovered_armors.has(armor_path):
		_discovered_armors.push_back(armor_path)
		save()

func get_discovered_armors() -> PackedStringArray:
	return _discovered_armors.duplicate()

func get_available_permanent_items() -> PackedStringArray:
	var arr: Array = _extra_available_permanent_items.duplicate()
	arr.append_array(AVAILABLE_PERMANENT_ITEMS_FROM_START)
	return PackedStringArray(arr)

## @deprecated
func discover_permanent_item_if_not_already(item_path: String) -> void:
	if not _discovered_permanent_items.has(item_path):
		_discovered_permanent_items.push_back(item_path)
		save()

## @deprecated
func get_discovered_permanent_items() -> PackedStringArray:
	return _discovered_permanent_items.duplicate()

func get_available_temporal_items() -> PackedStringArray:
	var arr: Array = _extra_available_temporal_items.duplicate()
	arr.append_array(AVAILABLE_TEMPORAL_ITEMS_FROM_START)
	return PackedStringArray(arr)

## @deprecated
func discover_temporal_item_if_not_already(item_path: String) -> void:
	if not _discovered_temporal_items.has(item_path):
		_discovered_temporal_items.push_back(item_path)
		save()

## @deprecated
func get_discovered_temporal_items() -> PackedStringArray:
	return _discovered_temporal_items.duplicate()

func is_item_discovered(item: Item) -> bool:
	return SavedData.statistics.get_item_statistics(item.get_id()) != null
	#if item is PermanentPassiveItem:
	#	return _discovered_permanent_items.has((item.get_script() as GDScript).get_path())
	#elif item is TemporalPassiveItem:
	#	return _discovered_temporal_items.has((item.get_script() as GDScript).get_path())
	#else:
	#	assert(false, "Invalid item type")
	#	return false

func get_available_player_upgrades() -> PackedStringArray:
	#var arr: Array = _discovered_temporal_items.duplicate()
	#arr.append_array(DISCOVERED_TEMPORAL_ITEMS_FROM_START)
	return AVAILABLE_PLAYER_UPGRADES_FROM_START

func add_extra_available_weapon(weapon_path: String) -> void:
	if not _extra_available_weapons.has(weapon_path):
		_extra_available_weapons.push_back(weapon_path)
		save()

func add_extra_available_armor(armor_path: String) -> void:
	if not _extra_available_armors.has(armor_path):
		_extra_available_armors.push_back(armor_path)
		save()

func add_extra_available_permanent_item(item_path: String) -> void:
	if not _extra_available_permanent_items.has(item_path):
		_extra_available_permanent_items.push_back(item_path)
		save()

func add_extra_available_temporal_item(item_path: String) -> void:
	if not _extra_available_temporal_items.has(item_path):
		_extra_available_temporal_items.push_back(item_path)
		save()

func add_completed_dialogue(dialogue: String) -> void:
	_completed_dialogues.push_back(dialogue)
	save()

func has_completed_dialogue(dialogue: String) -> bool:
	for dia: String in _completed_dialogues:
		if dia == dialogue:
			return true

	return false

func set_show_save_and_return_window(new_value: bool) -> void:
	show_save_and_return_window = new_value
	save()

static func from_dic(dic: Dictionary) -> Data:
	var data: Data = Data.new()

	for key: String in dic.keys():
		if data.get(key) != null:
			if key == "player_upgrades":
				for player_upgrade_dic: Dictionary in dic.player_upgrades:
					data.player_upgrades.push_back(PlayerUpgrade.from_dic(player_upgrade_dic))
			elif dic[key] is Array:
				data.set(key, PackedStringArray(dic[key]))
			else:
				data.set(key, dic[key])
		else:
			printerr("Data: Invalid property: " + key)

	return data

func to_dic() -> Dictionary:
	var dic: Dictionary = {}

	for property_dic: Dictionary in get_property_list():
		assert(property_dic.name is String)
		var property_name: StringName = property_dic.name
		if property_name in ["RefCounted", "script", "Built-in script", "data.gd"]:
			continue
		match property_name:
			"player_upgrades":
				var a: Array[Dictionary] = []

				for player_upgrade: PlayerUpgrade in player_upgrades:
					a.push_back(player_upgrade.to_dic())

				dic[property_name] = a
			_:
				dic[property_name] = get(property_name)

	return dic
