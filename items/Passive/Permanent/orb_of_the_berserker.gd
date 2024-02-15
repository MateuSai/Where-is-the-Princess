class_name OrbOfTheBerserker extends PermanentPassiveItem


var damage_increased: bool = false


func equip(player: Player) -> void:
	player.life_component.hp_changed.connect(_on_hp_changed)
	if player.life_component.hp < 4:
		player.damage_multiplier *= 2
		damage_increased = true


func unequip(player: Player) -> void:
	player.life_component.hp_changed.disconnect(_on_hp_changed)
	if damage_increased:
		player.damage_multiplier /= 2
		damage_increased = false


func get_icon() -> Texture2D:
	return load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/beherit.png")


func _on_hp_changed(new_hp: int) -> void:
	if new_hp < 4 and not damage_increased:
		Globals.player.damage_multiplier *= 2
		damage_increased = true
	elif new_hp >= 4 and damage_increased:
		Globals.player.damage_multiplier /= 2
		damage_increased = false
