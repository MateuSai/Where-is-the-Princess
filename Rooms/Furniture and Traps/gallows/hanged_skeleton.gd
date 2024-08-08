@tool
class_name HangedSkeleton extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var character_detector: Area2D = $CharacterDetector
@onready var life_component: LifeComponent = $LifeComponent

func _ready() -> void:
	sprite.frame_coords.y = randi() % sprite.vframes

	character_detector.body_entered.connect(_on_character_detector_body_entered)

	life_component.died.connect(func() -> void:
		animation_player.queue_free()
		$HurtBox.queue_free()
		character_detector.queue_free()
		sprite.texture = load("res://Art/16x16 Pixel Art Roguelike (Village) Pack/hanged_skeletons_rope.png")
		sprite.hframes = 1
		sprite.vframes = 1
		sprite.frame_coords = Vector2.ZERO
	, CONNECT_ONE_SHOT)

func _on_character_detector_body_entered(body: Node) -> void:
	if body is Character:
		animation_player.play("swing")
		var sound: AutoFreeSound = AutoFreeSound.new()
		get_tree().current_scene.add_child(sound)
		sound.start(LifeComponent.BONES_HIT_SOUNDS[randi() % LifeComponent.BONES_HIT_SOUNDS.size()], global_position)
