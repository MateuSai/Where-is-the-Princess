class_name ArrowPillar extends StaticBody2D

const ARROW_SCENE: PackedScene = preload ("res://Weapons/projectiles/arrow.tscn")

const LEFT: int = 1
const UP: int = 2
const RIGHT: int = 4
const DOWN: int = 8

@export_flags("left", "up", "right", "down") var shoot_directions: int = LEFT + UP + RIGHT + DOWN

@onready var life_component: LifeComponent = $LifeComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	life_component.died.connect(func() -> void:
		$HurtBox.queue_free()
		for group: String in get_groups():
			if group.begins_with("enabler_"):
				remove_from_group(group)
		animation_player.play("destroy")
	)

func activate() -> void:
	var dir_flags: Array = [LEFT, UP, RIGHT, DOWN]
	var directions: Array[Vector2] = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
	for i: int in dir_flags.size():
		if not shoot_directions&dir_flags[i]:
			continue
		var arrow: Arrow = ARROW_SCENE.instantiate()
		arrow.damage_dealer_id = "arrow_pillar"
		arrow.exclude = [$HurtBox, self]
		get_tree().current_scene.call_deferred("add_child", arrow)
		arrow.call_deferred("launch", global_position + Vector2.UP * 6, directions[i], 200, true)
