class_name BlowpipeTribal extends Enemy

const DART_SCENE: PackedScene = preload("res://Characters/Enemies/BlowpipeTribal/Dart.tscn")

@export var projectile_speed: int = 150

var can_attack: bool = true

@onready var attack_timer: Timer = get_node("AttackTimer")
@onready var aim_raycast: RayCast2D = get_node("AimRayCast")
@onready var blowpipe_pivot: Node2D = $BlowpipePivot


func _ready() -> void:
	super()

	attack_timer.timeout.connect(_on_attack_timer_timeout)


func _process(_delta: float) -> void:
	#super(delta)

	var vector_to_player: Vector2 = (player.position - global_position)
	blowpipe_pivot.rotation = vector_to_player.angle()
	if blowpipe_pivot.get_index() == 0 and vector_to_player.y > 0:
		move_child(blowpipe_pivot, get_child_count()-1)
	elif blowpipe_pivot.get_index() == get_child_count()-1 and vector_to_player.y < 0:
		move_child(blowpipe_pivot, 0)


func _throw_dart() -> void:
	var projectile: Area2D = DART_SCENE.instantiate()
	projectile.exclude.push_back(self)
	projectile.launch(global_position, (player.position - global_position).normalized(), projectile_speed, true)
	get_tree().current_scene.add_child(projectile)



func _on_attack_timer_timeout() -> void:
	can_attack = true
