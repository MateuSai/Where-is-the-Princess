extends TextureProgressBar

var souls_tween: Tween

@onready var weapons: Weapons = $"../../../Weapons"


func _ready() -> void:
	weapons.weapon_switched.connect(_on_weapon_switched)


func _on_weapon_switched(prev_index: int, new_index: int) -> void:
	var previous_weapon: Weapon = weapons.get_child(prev_index)
#	if previous_weapon.used_active_ability.is_connected(_empty_bar):
#		previous_weapon.used_active_ability.disconnect(_empty_bar)
	if previous_weapon.stats.souls_changed.is_connected(_on_souls_changed):
		previous_weapon.stats.souls_changed.disconnect(_on_souls_changed)

	var new_weapon: Weapon = weapons.get_child(new_index)
	if new_weapon.has_active_ability():
		assert(new_weapon.active_ability_icon)
		texture_progress = new_weapon.active_ability_icon
#		new_weapon.used_active_ability.connect(_empty_bar)
		new_weapon.stats.souls_changed.connect(_on_souls_changed)
		_on_souls_changed(new_weapon.stats.souls, new_weapon.souls_to_activate_ability)
		show()
	else:
		hide()


#func _empty_bar() -> void:
#	print("hi")
#	souls_tween = create_tween()
#	souls_tween.tween_property(self, "value", 0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_souls_changed(souls: int, souls_to_activate_ability: int) -> void:
	#print("hoho")
	souls_tween = create_tween()
	souls_tween.tween_property(self, "value", (souls/float(souls_to_activate_ability)) * 100, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if souls == souls_to_activate_ability:
		var shine_effect: Sprite2D = load("res://ui/WeaponAbilityShineEffect.tscn").instantiate()
		shine_effect.position = Vector2.ONE * 4
		add_child(shine_effect)
