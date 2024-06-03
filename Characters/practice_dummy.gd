class_name PracticeDummy extends Character

@export var drop_souls: bool = false

@onready var room: DungeonRoom = get_parent()

func _ready() -> void:
	super()

	state_machine.queue_free()
	state_machine = null
	life_component.invincible_after_being_hitted_time = 0.1

func _on_damage_taken(dam: int, dir: Vector2, force: int) -> void:
	super(dam, dir, force)

	life_component.hp += dam # So the dummy never dies

	animation_player.stop()
	animation_player.play("damage", 0)

	if drop_souls:
		for i: int in int(ceil(dam / 2.0)):
			var soul: SoulItem = Enemy.SOUL_SCENE.instantiate()
			room.cleared.connect(soul.go_to_player)
			soul.position = global_position
			get_tree().current_scene.call_deferred("add_child", soul)
