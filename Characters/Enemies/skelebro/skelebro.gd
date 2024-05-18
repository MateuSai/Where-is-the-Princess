class_name Skelebro extends Enemy


#@onready var enemy_weapons: EnemyWeapons = $EnemyWeapons


func _process(_delta: float) -> void:
	if is_instance_valid(enemy_weapons):
		enemy_weapons.move((target.global_position - global_position).normalized())
		if state_machine.state == SkelebroFSM.ATTACK and not enemy_weapons.is_busy():
			enemy_weapons.attack()
