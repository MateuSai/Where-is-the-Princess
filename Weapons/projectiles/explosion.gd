class_name Explosion extends Hitbox

const SOUNDS: Array[AudioStream] = [ preload ("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Explosion/Explosion3.wav"), preload ("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Explosion/Explosion5.wav"), preload ("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Explosion/Explosion9.wav")]

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	var sound: AutoFreeSound = AutoFreeSound.new()
	get_tree().current_scene.add_child(sound)
	sound.start(SOUNDS[randi() % SOUNDS.size()], global_position)

func _collide(node: Node2D, dam: int=damage) -> void:
	knockback_direction = (node.global_position - global_position).normalized()

	super(node, dam)

func _spawn_shrapnel() -> void:
	set_physics_process(false)

	#animation_player.pause()

	var num: int = randi() % 3 + 3
	var initial_rot: float = randf_range(0, 2 * PI / (num - 1))
	var shrapnels: Array[Sprite2D] = []
	for i: int in num:
		var shrapnel: Sprite2D = (load("res://Weapons/projectiles/bombs/Shrapnel.tscn") as PackedScene).instantiate()
		shrapnel.rotation = initial_rot + (2 * PI / (num - 1)) * i + randf_range( - 0.2, 0.2)
		add_child(shrapnel)
		move_child(shrapnel, 0)
		shrapnels.push_back(shrapnel)

	await get_tree().process_frame
	#animation_player.play()
	for shrapnel: Sprite2D in shrapnels:
		(shrapnel.get_node("AnimationPlayer") as AnimationPlayer).play("explode")
