class_name MainUi extends CanvasLayer

const INVENTORY_ITEM_SCENE: PackedScene = preload ("res://InventoryItem.tscn")

#const MIN_HEALTH: int = 23

#var max_hp: int = 4

var current_armor: Armor

@onready var player_life_component: LifeComponent = get_node("../LifeComponent")

#@onready var hearts: Hearts = %Hearts
@onready var armor_points: ArmorPointsHBox = %ArmorPoints
@onready var inventory: HBoxContainer = get_node("Inventory")
@onready var armor_flash_effect: TextureRect = get_node("%ArmorFlashEffect")
@onready var armor_flash_effect_animation_player: AnimationPlayer = armor_flash_effect.get_node("AnimationPlayer")

#@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	#color_rect.hide()

	#max_hp = player_life_component.max_hp
	player_life_component.hp_changed.connect(_on_player_hp_changed)
	#hearts.update_hearts(player_life_component.max_hp, player_life_component.max_hp)
	armor_points.update_armor_points((get_parent() as Player).armor.condition)
	(get_parent() as Player).armor_changed.connect(_on_armor_changed)
	#_update_health_bar(100)

#func _update_health_bar(new_value: int) -> void:
#	var tween: Tween = create_tween()
#	tween.tween_property(health_bar, "value", new_value, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _on_player_hp_changed(new_hp: int) -> void:
	pass
	#hearts.update_hearts(player_life_component.max_hp, new_hp)
#	var new_health: int = int((100 - MIN_HEALTH) * float(new_hp) / max_hp) + MIN_HEALTH
#	_update_health_bar(new_health)

func _on_armor_changed(new_armor: Armor) -> void:
	assert(new_armor)

	if current_armor:
		if current_armor.condition_changed.is_connected(_on_armor_condition_changed):
			current_armor.condition_changed.disconnect(_on_armor_condition_changed)

	current_armor = new_armor


	new_armor.condition_changed.connect(_on_armor_condition_changed)

	_on_armor_condition_changed(new_armor.condition)

func _on_armor_condition_changed(new_ap: int) -> void:
	armor_points.update_armor_points(new_ap)

func _on_weapon_switched(prev_index: int, new_index: int) -> void:
	inventory.get_child(prev_index).deselect()
	inventory.get_child(new_index).select()

func _on_weapon_picked_up(weapon: Weapon) -> void:
	var new_inventory_item: Control = INVENTORY_ITEM_SCENE.instantiate()
	inventory.add_child(new_inventory_item)
	new_inventory_item.initialize(weapon)

func _on_weapon_droped(index: int) -> void:
	inventory.get_child(index).queue_free()

func _on_weapon_condition_changed(weapon: Weapon, new_value: float) -> void:
	inventory.get_child(weapon.get_index()).update_condition(new_value)

func _on_weapon_status_inflicter_added(weapon: Weapon, status: StatusComponent.Status) -> void:
	inventory.get_child(weapon.get_index()).add_status_icon(status)

func start_armor_ability_flash_effect() -> void:
	armor_flash_effect_animation_player.play("flash")

func stop_armor_ability_flash_effect() -> void:
	armor_flash_effect_animation_player.stop()
	armor_flash_effect.modulate.a = 0.0
