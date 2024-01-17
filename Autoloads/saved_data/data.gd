class_name Data

#region Data available from start
const DISCOVERED_WEAPONS_FROM_START: PackedStringArray = ["res://Weapons/Melee/Katana/Katana.tscn", "res://Weapons/Melee/spear/Spear.tscn", "res://Weapons/Melee/DragonKiller/DragonKiller.tscn", "res://Weapons/Melee/KombatHammer/KombatHammer.tscn", "res://Weapons/Melee/OrcSword/OrcSword.tscn", "res://Weapons/Melee/Scimitar/Scimitar.tscn", "res://Weapons/Melee/SharpAxe/SharpAxe.tscn", "res://Weapons/Melee/SmallAxe/SmallAxe.tscn", "res://Weapons/Melee/WarAxe/WarAxe.tscn", "res://Weapons/Melee/WarHammer/WarHammer.tscn", "res://Weapons/Melee/WarriorSword/WarriorSword.tscn", "res://Weapons/Ranged/Bows/WoodenBow/wooden_bow.tscn"]
const DISCOVERED_ARMORS_FROM_START: PackedStringArray = ["res://Armors/CommonerClothes.gd", "res://Armors/LeatherArmor.gd", "res://Armors/MercenaryArmor.gd", "res://Armors/WarriorArmor.gd", "res://Armors/NecromancerArmor.gd", "res://Armors/improvised_armor.gd", "res://Armors/farmer_clothes.gd"]
const DISCOVERED_PERMANENT_ITEMS_FROM_START: PackedStringArray = ["res://items/Passive/Permanent/StrongThrow.gd", "res://items/Passive/Permanent/ToughSkin.gd", "res://items/Passive/Permanent/EnhancedBoots.gd", "res://items/Passive/Permanent/meteor_stone.gd", "res://items/Passive/Permanent/SoulAmulet.gd", "res://items/Passive/Permanent/runes/AxeRune.gd", "res://items/Passive/Permanent/runes/HammerRune.gd", "res://items/Passive/Permanent/runes/MeleeRune.gd", "res://items/Passive/Permanent/runes/SpearRune.gd", "res://items/Passive/Permanent/runes/SwordRune.gd"]
const DISCOVERED_TEMPORAL_ITEMS_FROM_START: PackedStringArray = ["res://items/Passive/Temporal/magic_shields/wooden_magic_shield.gd", "res://items/Passive/Temporal/magic_shields/reinforced_magic_shield.gd", "res://items/Passive/Temporal/MagicSword.gd"]
const DISCOVERED_PLAYER_UPGRADES_FROM_START: PackedStringArray = ["res://items/player_upgrades/additional_heart.gd", "res://items/player_upgrades/additional_movement_speed.gd", "res://items/player_upgrades/additional_weapon_carry_capacity.gd"]
#endregion

var dark_souls: int = 0

var kills: Dictionary = {}

var ignored_rooms: Array[String] = []

var _discovered_weapons: Array[String] = []
#"undiscovered_weapons": PackedStringArray(["res://Weapons/Melee/OrcSword/OrcSword.tscn", "res://Weapons/Melee/DragonKiller/DragonKiller.tscn", "res://Weapons/Melee/WarAxe/WarAxe.tscn"]),

var equipped_armor: String = "res://Armors/NoArmor.gd"
var _discovered_armors: Array[String] = []

var _discovered_permanent_items: Array[String] = []
#	"undiscovered_permanent_items": PackedStringArray(["res://items/Passive/Permanent/EnhancedBoots.gd"]),
var _discovered_temporal_items: Array[String] = []
#	"undiscovered_temporal_items": PackedStringArray(["res://items/Passive/Temporal/MagicSword.gd"]),

var player_upgrades: Array[PlayerUpgrade] = []

var _completed_dialogues: Array = []

var shop_unlocked: bool = false

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


func get_discovered_weapons() -> PackedStringArray:
	var arr: Array = _discovered_weapons.duplicate()
	arr.append_array(DISCOVERED_WEAPONS_FROM_START)
	return PackedStringArray(arr)


func get_discovered_armors() -> PackedStringArray:
	var arr: Array = _discovered_armors.duplicate()
	arr.append_array(DISCOVERED_ARMORS_FROM_START)
	return PackedStringArray(arr)


func get_discovered_permanent_items() -> PackedStringArray:
	var arr: Array = _discovered_permanent_items.duplicate()
	arr.append_array(DISCOVERED_PERMANENT_ITEMS_FROM_START)
	return PackedStringArray(arr)


func get_discovered_temporal_items() -> PackedStringArray:
	var arr: Array = _discovered_temporal_items.duplicate()
	arr.append_array(DISCOVERED_TEMPORAL_ITEMS_FROM_START)
	return PackedStringArray(arr)


func get_discovered_player_upgrades() -> PackedStringArray:
	#var arr: Array = _discovered_temporal_items.duplicate()
	#arr.append_array(DISCOVERED_TEMPORAL_ITEMS_FROM_START)
	return DISCOVERED_PLAYER_UPGRADES_FROM_START


func discover_weapon(weapon_path: String) -> void:
	if not _discovered_weapons.has(weapon_path):
		_discovered_weapons.push_back(weapon_path)


func discover_armor(armor_path: String) -> void:
	if not _discovered_armors.has(armor_path):
		_discovered_armors.push_back(armor_path)


func discover_permanent_item(item_path: String) -> void:
	if not _discovered_permanent_items.has(item_path):
		_discovered_permanent_items.push_back(item_path)


func discover_temporal_item(item_path: String) -> void:
	if not _discovered_temporal_items.has(item_path):
		_discovered_temporal_items.push_back(item_path)


func add_completed_dialogue(dialogue: String) -> void:
	_completed_dialogues.push_back(dialogue)


func has_completed_dialogue(dialogue: String) -> bool:
	for dia: String in _completed_dialogues:
		if dia == dialogue:
			return true

	return false


static func from_dic(dic: Dictionary) -> Data:
	var data: Data = Data.new()

	for key: String in dic.keys():
		if data.get(key) != null:
			match key:
				"player_upgrades":
					for player_upgrade_dic: Dictionary in dic.player_upgrades:
						data.player_upgrades.push_back(PlayerUpgrade.from_dic(player_upgrade_dic))
				_:
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
