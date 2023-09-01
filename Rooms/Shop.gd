class_name Shop extends Node2D

const SHOP_ITEM_SCENE: PackedScene = preload("res://Rooms/ShopItem.tscn")

@onready var positions: Node2D = $Positions
@onready var on_base_camp: bool = get_tree().current_scene.name == "BaseCamp"


func _ready() -> void:
	for marker in positions.get_children():
		var shop_item: ShopItem = SHOP_ITEM_SCENE.instantiate()
		shop_item.position = marker.global_position
		add_child(shop_item)
		match marker.item_type:
			ShopItemMarker.Type.TEMPORAL_ITEM:
				var item_paths: PackedStringArray = SavedData.get_undiscovered_temporal_item_paths() if on_base_camp else SavedData.get_discovered_temporal_item_paths()
				shop_item.initialize(load(item_paths[randi() % item_paths.size()]).new())
			ShopItemMarker.Type.WEAPON:
				var weapon_paths: PackedStringArray = SavedData.get_undiscovered_weapon_paths() if on_base_camp else SavedData.get_discovered_weapon_paths()
				var weapon_path: String = weapon_paths[randi() % weapon_paths.size()]
				var weapon: Weapon = load(weapon_path).instantiate()
				var weapon_item: WeaponItem = WeaponItem.new()
				weapon_item.initialize(weapon)
				shop_item.initialize(weapon_item)
