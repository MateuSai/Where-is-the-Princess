class_name Skelebromancer extends Enemy

const MAX_NUM_SPAWNED_SKELEBROS_ALIVE: int = 3

var pile_of_bones: Array[PileOfBones]

var num_spawned_skelebros_alive: int = 0

@onready var eyes_sprite: Sprite2D = $EyesSprite
@onready var spawn_skelebro_timer: Timer = $SpawnSkelebroTimer


func _ready() -> void:
	super()

	pile_of_bones.assign(get_tree().get_nodes_in_group("pile_of_bones"))
	assert(not pile_of_bones.is_empty())
	for bones: PileOfBones in pile_of_bones:
		bones.life_component.died.connect(func() -> void:
			pile_of_bones.erase(bones)
			if pile_of_bones.is_empty():
				spawn_skelebro_timer.stop()
				life_component.take_damage(1000, Vector2.ZERO, 0, null, "player")
		)

	spawn_skelebro_timer.timeout.connect(func() -> void:
		if num_spawned_skelebros_alive >= MAX_NUM_SPAWNED_SKELEBROS_ALIVE:
			return

		pile_of_bones[randi() % pile_of_bones.size()].spawn_skelebro().life_component.died.connect(func() -> void:
			num_spawned_skelebros_alive -= 1
		)
		num_spawned_skelebros_alive += 1
	)


func _on_change_dir() -> void:
	super()

	eyes_sprite.flip_h = !eyes_sprite.flip_h
