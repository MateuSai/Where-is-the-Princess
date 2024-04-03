class_name PlayerMaxSpeed extends ItemEffect

var amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
	self.amount = amount

func enable(player: Player) -> void:
	player.data.max_speed += amount

func disable(player: Player) -> void:
	player.data.max_speed -= amount
