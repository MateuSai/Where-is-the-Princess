class_name MainUi extends CanvasLayer

const INVENTORY_ITEM_SCENE: PackedScene = preload("res://InventoryItem.tscn")

#const MIN_HEALTH: int = 23

#var max_hp: int = 4

@onready var player_life_component: LifeComponent = get_node("../LifeComponent")

@onready var hearts: Hearts = $MarginContainer/ArmorConditionBar/Hearts
@onready var inventory: HBoxContainer = get_node("PanelContainer/Inventory")


func _ready() -> void:
	#max_hp = player_life_component.max_hp
	player_life_component.hp_changed.connect(_on_player_hp_changed)
	hearts.update_hearts(player_life_component.max_hp)
	#_update_health_bar(100)


#func _update_health_bar(new_value: int) -> void:
#	var tween: Tween = create_tween()
#	tween.tween_property(health_bar, "value", new_value, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _on_player_hp_changed(new_hp: int) -> void:
	hearts.update_hearts(new_hp)
#	var new_health: int = int((100 - MIN_HEALTH) * float(new_hp) / max_hp) + MIN_HEALTH
#	_update_health_bar(new_health)


func _on_weapon_switched(prev_index: int, new_index: int) -> void:
	inventory.get_child(prev_index).deselect()
	inventory.get_child(new_index).select()


func _on_weapon_picked_up(weapon: Weapon) -> void:
	var new_inventory_item: Control = INVENTORY_ITEM_SCENE.instantiate()
	inventory.add_child(new_inventory_item)
	new_inventory_item.initialize(weapon.get_texture(), weapon.stats.condition)


func _on_weapon_droped(index: int) -> void:
	inventory.get_child(index).queue_free()


func _on_weapon_condition_changed(weapon: Weapon, new_value: float) -> void:
	inventory.get_child(weapon.get_index()).update_condition(new_value)


func _on_weapon_status_inflicter_added(weapon: Weapon, status: StatusComponent.Status) -> void:
	inventory.get_child(weapon.get_index()).add_status_icon(status)
