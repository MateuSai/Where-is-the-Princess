class_name InventoryItem extends MarginContainer

var weapon: Weapon

@onready var texture_rect: TextureRect = $Background/VBoxContainer/TextureRect
@onready var condition_bar: TextureProgressBar = $Background/VBoxContainer/TextureProgressBar
@onready var status_container: HBoxContainer = %StatusContainer
@onready var arrow_icon: TextureRect = %ArrowIcon
@onready var bad_state_overlay_texture: TextureRect = %BadStateOverlayTexture


@warning_ignore("shadowed_variable")
func initialize(weapon: Weapon) -> void:
	self.weapon = weapon
	texture_rect.texture = weapon.get_texture()
	condition_bar.value = weapon.stats.condition
	if weapon.name == "Dagger":
		condition_bar.value = 100
		condition_bar.tint_progress = Color.SILVER
	else:
		update_condition(weapon.stats.condition)

	if weapon is BowOrCrossbowWeapon:
		arrow_icon.show()
		(weapon as BowOrCrossbowWeapon).arrow_type_changed.connect(func(new_type: ArrowOrBolt.Type) -> void:
			arrow_icon.texture = ArrowOrBolt.MODIFIER_TEXTURES[new_type]
		)
		arrow_icon.texture = ArrowOrBolt.MODIFIER_TEXTURES[(weapon as BowOrCrossbowWeapon).arrow_type]
	else:
		arrow_icon.hide()

	if weapon.stats.bad_state:
		bad_state_overlay_texture.show()
	else:
		bad_state_overlay_texture.hide()


func _ready() -> void:
	if get_parent() is PauseWeaponInventory: # Pause menu weapons
		mouse_entered.connect(func() -> void:
			var splitted_text: PackedStringArray = weapon.get_info().split("\n\n")
			get_tree().current_scene.get_node("UI/InfoPanel").show_title_description_at(global_position + Vector2.RIGHT * size.x + Vector2.DOWN * size.y / 2, splitted_text[0], splitted_text[1])
		)
		mouse_exited.connect(func() -> void:
			get_tree().current_scene.get_node("UI/InfoPanel").stop_showing()
		)


func select() -> void:
	modulate = Color.WHITE


func deselect() -> void:
	modulate = Color("#767676")


func update_condition(new_condition: float) -> void:
	condition_bar.value = new_condition
	if new_condition > 50:
		condition_bar.tint_progress = Color.YELLOW.lerp(Color.GREEN, (new_condition - 50) / 50)
	else:
		condition_bar.tint_progress = Color.RED.lerp(Color.YELLOW, new_condition / 50)


func add_status_icon(status: StatusComponent.Status) -> void:
#	match status:
#		StatusComponent.Status.FIRE:
	var icon: TextureRect = TextureRect.new()
	icon.texture = load(["res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Ruby_icon.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Sapphire_icon.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Topaz_icon.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/Emmerald_icon.png"][status])
	status_container.add_child(icon)


#func _get_tooltip(_at_position: Vector2) -> String:
	#if get_tree().paused:
		#return weapon.get_info()
	#else:
		#return ""
#
#
#func _make_custom_tooltip(for_text: String) -> Object:
	#var custom_tooltip: CustomTooltip = load("res://ui/custom_tooltip.tscn").instantiate()
#
	#var splitted_text: PackedStringArray = for_text.split("\n\n")
	#custom_tooltip.initialize(splitted_text[0], splitted_text[1])
#
	#return custom_tooltip
