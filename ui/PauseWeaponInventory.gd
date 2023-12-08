extends HBoxContainer

const INVENTORY_ITEM_SCENE: PackedScene = preload("res://InventoryItem.tscn")


func _ready() -> void:
	draw.connect(_on_draw)


func _on_draw() -> void:
	for i: int in range(get_child_count()-1, -1, -1):
		get_child(i).free()

	for weapon: Weapon in Globals.player.weapons.get_children():
		var new_inventory_item: InventoryItem = INVENTORY_ITEM_SCENE.instantiate()
		add_child(new_inventory_item)
		new_inventory_item.initialize(weapon)
		new_inventory_item.deselect()

	(get_child(Globals.player.weapons.current_weapon.get_index()) as InventoryItem).select()
