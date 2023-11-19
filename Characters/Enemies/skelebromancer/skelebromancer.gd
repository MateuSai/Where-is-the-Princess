class_name Skelebromancer extends Enemy

var pile_of_bones: Array[PileOfBones]

@onready var eyes_sprite: Sprite2D = $EyesSprite
@onready var spawn_skelebro_timer: Timer = $SpawnSkelebroTimer


func _ready() -> void:
	super()

	pile_of_bones.assign(get_tree().get_nodes_in_group("pile_of_bones"))
	assert(not pile_of_bones.is_empty())
	for bones in pile_of_bones:
		bones.life_component.died.connect(func():
			pile_of_bones.erase(bones)
			if pile_of_bones.is_empty():
				_on_damage_taken(1000, Vector2.ZERO, 0)
		)

	spawn_skelebro_timer.timeout.connect(func():
		pile_of_bones[randi() % pile_of_bones.size()].spawn_skelebro()
	)


func _on_change_dir() -> void:
	super()

	eyes_sprite.flip_h = !eyes_sprite.flip_h
