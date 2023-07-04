class_name ShieldKnight extends Enemy

const MIN_DESIRED_DISTANCE_TO_ENEMY_TO_PROTECT: int = 24
const MAX_DESIRED_DISTANCE_TO_ENEMY_TO_PROTECT: int = 32
const SHIELD_MOV_SPEED: float = 0.04

var enemy_to_protect: Enemy = null:
	set(new_enemy):
		enemy_to_protect = new_enemy
		if enemy_to_protect:
			enemy_to_protect.life_component.hp_changed.connect(func(new_hp: int):
				if new_hp <= 0:
					enemy_to_protect = null
					search_enemy_to_protect()
			)

@onready var shield: StaticBody2D = $Shield


func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	search_enemy_to_protect()


func move_shield_to_player() -> void:
	shield.rotation = lerp_angle(shield.rotation, (player.position - global_position).angle(), SHIELD_MOV_SPEED)


func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player) and is_instance_valid(enemy_to_protect):
		navigation_agent.target_position = enemy_to_protect.global_position + (player.position - enemy_to_protect.global_position).normalized() * MIN_DESIRED_DISTANCE_TO_ENEMY_TO_PROTECT
	else:
		mov_direction = Vector2.ZERO


func search_enemy_to_protect() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is ShieldKnight:
			self.enemy_to_protect = enemy
			return
