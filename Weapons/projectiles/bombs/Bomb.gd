class_name Bomb extends Area2D

const SOUNDS: Array[AudioStream] = [ preload ("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Explosion/Explosion3.wav"), preload ("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Explosion/Explosion5.wav"), preload ("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Explosion/Explosion9.wav")]

var reflected: bool = false

var dir: Vector2
var speed: float
var dam: int = 2:
	set(new_dam):
		dam = new_dam
		if hitbox:
			hitbox.damage = dam
var destroy_on_collide: bool = false

@onready var bomb_path: BombPath = owner
@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Hitbox = $Hitbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	set_physics_process(false)


func _physics_process(delta: float) -> void:
	position += dir * speed * delta


@warning_ignore("shadowed_variable")
func hit(dir: Vector2, force: float) -> void:
	if reflected:
		return

	reflected = true

	hitbox.set_collision_mask_value(3, true) # To make it collide with enemies

	self.dir = dir
	self.speed = force

	var g_pos: Vector2 = global_position
	var tree: SceneTree = get_tree()
	var path_follow: PathFollow2D = get_parent()

	path_follow.call_deferred("remove_child", self)
	await get_tree().process_frame
	bomb_path.queue_free()
	tree.current_scene.add_child(self)
	position = g_pos

	set_physics_process(true)


func destroy() -> void:
	if is_instance_valid(bomb_path):
		bomb_path.queue_free()
	else:
		queue_free()


func _on_body_entered(_body: Node2D) -> void:
	set_physics_process(false)
	if destroy_on_collide:
		await get_tree().process_frame
		if animation_player.current_animation_position < 0.95:
			animation_player.seek(0.95, true)


func _spawn_shrapnel() -> void:
	set_physics_process(false)

	var sound: AutoFreeSound = AutoFreeSound.new()
	get_tree().current_scene.add_child(sound)
	sound.start(SOUNDS[randi() % SOUNDS.size()], global_position)

	#animation_player.pause()

	var num: int = randi() % 3 + 3
	var initial_rot: float = randf_range(0, 2*PI / (num - 1))
	var shrapnels: Array = []
	var shrapnel_scene: PackedScene = load("res://Weapons/projectiles/bombs/Shrapnel.tscn")
	for i: int in num:
		var shrapnel: Sprite2D = shrapnel_scene.instantiate()
		shrapnel.texture = sprite.texture
		shrapnel.rotation = initial_rot + (2*PI / (num - 1)) * i + randf_range(-0.2, 0.2)
		add_child(shrapnel)
		move_child(shrapnel, 0)
		shrapnels.push_back(shrapnel)

	if is_inside_tree():
		await get_tree().process_frame
		#animation_player.play()
		for shrapnel: Sprite2D in shrapnels:
			(shrapnel.get_node("AnimationPlayer") as AnimationPlayer).play("explode")
