class_name ArrowPillar extends StaticBody2D


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
