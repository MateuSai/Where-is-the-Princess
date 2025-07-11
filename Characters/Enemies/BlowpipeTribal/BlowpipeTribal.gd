class_name BlowpipeTribal extends Enemy

const DART_SCENE: PackedScene = preload("res://Characters/Enemies/BlowpipeTribal/Dart.tscn")

@export var projectile_speed: int = 150

var can_attack: bool = false

@onready var attack_timer: Timer = get_node("AttackTimer")
@onready var blowpipe_pivot: Node2D = $BlowpipePivot
@onready var blowpipe_end: Marker2D = $BlowpipePivot/Sprite2D/End


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


func _throw_dart(dir: Vector2) -> void:
	var projectile: Area2D = DART_SCENE.instantiate()
	projectile.exclude.push_back(self)
	get_tree().current_scene.add_child(projectile)
	projectile.launch(blowpipe_end.global_position, dir, projectile_speed, true)



func _on_attack_timer_timeout() -> void:
	can_attack = true
