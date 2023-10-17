class_name Arrow extends Projectile

const WORLD_IMPACT_SOUNDS: Array[AudioStreamWAV] = [preload("res://Audio/Sounds/impact/521242__cyoung510__arrow_hits_target_1.wav"), preload("res://Audio/Sounds/impact/521242__cyoung510__arrow_hits_target_2.wav"), preload("res://Audio/Sounds/impact/521242__cyoung510__arrow_hits_target_3.wav")]


func _ready() -> void:
	super()

	flesh_sounds = MeleeWeapon.IMPACT_FLESH_SOUNDS


func _collide(node: Node2D, _dam: int = damage) -> void:
	collided_with_something.emit(node)

	if node.get("life_component") != null:
		node.life_component.take_damage(damage, knockback_direction, knockback_force)
	_attach_projectile(node)


func _attach_projectile(body: Node2D) -> void:
	var sprite_clone: Sprite2D = $Sprite2D.duplicate()

	if body is CharacterBody2D:
		body.add_child(sprite_clone)
	else:
		var sound: AutoFreeSound = AutoFreeSound.new()
		get_tree().current_scene.add_child(sound)
		sound.start(WORLD_IMPACT_SOUNDS[randi() % WORLD_IMPACT_SOUNDS.size()], position, -5)
		get_tree().current_scene.add_child(sprite_clone)

	sprite_clone.rotation += rotation
	sprite_clone.global_position = position

	destroy()


func destroy() -> void:
	super()
