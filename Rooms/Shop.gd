class_name Shop extends Node2D

const SHOP_ITEM_SCENE: PackedScene = preload("res://Rooms/ShopItem.tscn")

@onready var positions: Node2D = $Positions
@onready var on_base_camp: bool = get_tree().current_scene.name == "BaseCamp"


func _ready() -> void:
	var item_paths: PackedStringArray = SavedData.get_discovered_temporal_item_paths().duplicate()
	var weapon_paths: PackedStringArray = SavedData.get_discovered_weapon_paths().duplicate()

	for marker in positions.get_children():
		match marker.item_type:
			ShopItemMarker.Type.TEMPORAL_ITEM:
				if item_paths.is_empty():
					_create_and_add_out_of_stock_shop_item(marker.position)
				else:
					var random_item_path: String = item_paths[randi() % item_paths.size()]
					_create_and_add_shop_item(marker.position).initialize(load(random_item_path).new())
					item_paths.remove_at(item_paths.find(random_item_path))
			ShopItemMarker.Type.WEAPON:
				if weapon_paths.is_empty():
					_create_and_add_out_of_stock_shop_item(marker.position)
				else:
					var random_weapon_path: String = weapon_paths[randi() % weapon_paths.size()]
					var weapon: Weapon = load(random_weapon_path).instantiate()
					var weapon_item: WeaponItem = WeaponItem.new()
					weapon_item.initialize(weapon)
					_create_and_add_shop_item(marker.position).initialize(weapon_item)
					weapon_paths.remove_at(weapon_paths.find(random_weapon_path))


func _create_and_add_shop_item(at_position: Vector2) -> ShopItem:
	var shop_item: ShopItem = SHOP_ITEM_SCENE.instantiate()
	shop_item.position = at_position
	add_child(shop_item)
	return shop_item


func _create_and_add_out_of_stock_shop_item(at_position: Vector2) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = load("res://Art/Dust.png")
	sprite.position = at_position
	add_child(sprite)
