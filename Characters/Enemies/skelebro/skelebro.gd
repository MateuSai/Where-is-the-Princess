class_name Skelebro extends Enemy


@onready var enemy_weapons: EnemyWeapons = $EnemyWeapons


func _process(delta: float) -> void:
	enemy_weapons.move((target.global_position - global_position).normalized())
	if not enemy_weapons.is_busy():
		enemy_weapons.attack()
