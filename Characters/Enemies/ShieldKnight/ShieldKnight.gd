class_name ShieldKnight extends Enemy

const MIN_DESIRED_DISTANCE_TO_ENEMY_TO_PROTECT: int = 24
const MAX_DESIRED_DISTANCE_TO_ENEMY_TO_PROTECT: int = 32
const SHIELD_MOV_SPEED: float = 0.04

var prev_shield_rot: float = 0

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
@onready var shield_sprite: Sprite2D = shield.get_node("Sprite2D")


func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	search_enemy_to_protect()


func move_shield_to_player() -> void:
	prev_shield_rot = shield.rotation
	shield.rotation = lerp_angle(wrapf(shield.rotation, 0, TAU), wrapf((player.position - global_position).angle() - PI/2, 0, TAU), SHIELD_MOV_SPEED)
	if (shield.rotation > 3*PI/2 and prev_shield_rot < 3*PI/2) or (shield.rotation < PI/2 and prev_shield_rot > PI/2):
		move_child(shield, get_child_count()-1)
	elif (shield.rotation > PI/2 and prev_shield_rot < PI/2) or (shield.rotation < 3*PI/2 and prev_shield_rot > 3*PI/2):
		move_child(shield, 0)
	shield_sprite.global_rotation = 0
	shield_sprite.frame = clamp(floor(((TAU - shield.rotation) / (TAU)) * shield_sprite.hframes), 0, shield_sprite.hframes-1)
	#print(shield.rotation)


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
