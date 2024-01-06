class_name ArrowPillar extends StaticBody2D

const ARROW_SCENE: PackedScene = preload("res://Weapons/projectiles/arrow.tscn")

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
	for dir: Vector2 in [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]:
		var arrow: Arrow = ARROW_SCENE.instantiate()
		arrow.exclude = [$HurtBox, self]
		get_tree().current_scene.add_child(arrow)
		arrow.launch(global_position + Vector2.UP * 6, dir, 200, true)
