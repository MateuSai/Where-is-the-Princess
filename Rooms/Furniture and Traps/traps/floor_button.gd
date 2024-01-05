class_name FloorButton extends Enabler

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


func activate() -> void:
	for child: Node in get_tree().get_nodes_in_group("enabler_" + str(id)):
		assert(child.has_node("Remotetrap"))
		assert(child.get_node("RemoteTrap") is RemoteTrap)
		(child.get_node("RemoteTrap") as RemoteTrap).activate()
