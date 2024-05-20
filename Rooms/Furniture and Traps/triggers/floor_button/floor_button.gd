class_name FloorButton extends Trigger

var num_enemies_inside: int = 0:
	set(new_amount):
		if new_amount == 0:
			sprite.frame = 0
		else:
			if num_enemies_inside == 0 and new_amount > 0:
				activate()
				sprite.frame = 1
		num_enemies_inside = new_amount

@onready var room: DungeonRoom = get_node("../..")
@onready var sprite: Sprite2D = $Sprite2D

func _init() -> void:
	body_entered.connect(func(_body: Node2D) -> void:
		num_enemies_inside += 1
	)
	body_exited.connect(func(_body: Node2D) -> void:
		num_enemies_inside -= 1
	)
