extends TextureProgressBar

@onready var weapons: Weapons = $"../../../Weapons"


func _ready() -> void:
	weapons.weapon_switched.connect(_on_weapon_switched)


func _on_weapon_switched(prev_index: int, new_index: int) -> void:
	var previous_weapon: Weapon = weapons.get_child(prev_index)
	if previous_weapon.used_active_ability.is_connected(_recharge_ability_animation):
		previous_weapon.used_active_ability.disconnect(_recharge_ability_animation)

	var new_weapon: Weapon = weapons.get_child(new_index)
	if new_weapon.has_active_ability():
		new_weapon.used_active_ability.connect(_recharge_ability_animation)
		show()
	else:
		hide()


func _recharge_ability_animation(time: float) -> void:
	value = 100
	var tween: Tween = create_tween()
	tween.tween_property(self, "value", 0, time)
