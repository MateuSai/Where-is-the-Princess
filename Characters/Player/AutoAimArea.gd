class_name AutoAimArea extends CharacterDetector

@onready var player: Player = owner
@onready var aim_component: AimComponent = owner.get_node("AimComponent")

func _ready() -> void:
	super()

	Settings.auto_aim_changed.connect(_on_auto_aim_changed)
	Settings.aim_help_changed.connect(_on_aim_help_changed)
	if Settings.auto_aim:
		_enable()
	else:
		_on_aim_help_changed(Settings.aim_help)


func get_direction() -> Vector2:
	player.target = closer_enemy
	return aim_component.get_dir((player.weapons.current_weapon as RangedWeapon).spawn_projectile_pos.global_position if player.weapons.current_weapon is RangedWeapon else Vector2.ZERO).dir if is_instance_valid(closer_enemy) else Vector2.RIGHT


func get_direction_using_dir(dir: Vector2, max_angle: float) -> Vector2:
	var closer_to_dir: Character = null
	var angle: float

	for enemy: Character in characters_inside:
		var angle_to_enemy: float = abs(dir.angle_to((enemy.global_position - player.position)))
		if (closer_to_dir == null or angle_to_enemy < angle) and angle_to_enemy < max_angle:
			closer_to_dir = enemy
			angle = angle_to_enemy

	player.target = closer_to_dir
	return aim_component.get_dir((player.weapons.current_weapon as RangedWeapon).spawn_projectile_pos.global_position if player.weapons.current_weapon is RangedWeapon else Vector2.ZERO).dir if is_instance_valid(closer_to_dir) else Vector2.RIGHT


func _on_auto_aim_changed(new_value: bool) -> void:
	if new_value:
		_enable()
	else:
		_on_aim_help_changed(Settings.aim_help)


func _on_aim_help_changed(new_value: float) -> void:
	if new_value > 0.0:
		if set_closer_enemy_timer.is_stopped():
			_enable()
	else:
		_disable()
