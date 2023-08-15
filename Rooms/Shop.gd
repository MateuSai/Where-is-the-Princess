class_name Shop extends Node2D

const SHOP_ITEM_SCENE: PackedScene = preload("res://Rooms/ShopItem.tscn")

@onready var positions: Node2D = $Positions


func _ready() -> void:
	for marker in positions.get_children():
		var shop_item: ShopItem = SHOP_ITEM_SCENE.instantiate()
		shop_item.position = marker.global_position
		shop_item.initialize(load(SavedData.data[marker.item_type][randi() % SavedData.data[marker.item_type].size()]).new())
		add_child(shop_item)
