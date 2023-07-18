class_name Whetstone extends Item


func _init() -> void:
	_initialize(load("res://Art/Status Conditions/condition_status_top_fire_full_16x16.png"))


func can_pick_up(player: Player) -> bool:
	return player.weapons.current_weapon.get_index() > 0 and player.weapons.current_weapon.stats.condition < 100


func pick_up(player: Player) -> void:
	player.weapons.current_weapon.stats.set_condition(100)
