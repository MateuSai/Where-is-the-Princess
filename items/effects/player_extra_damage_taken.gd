class_name PlayerExtraDamageTaken extends ItemEffect

var amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
	self.amount = amount

func enable(player: Player) -> void:
	player.life_component.extra_damage_taken += amount

func disable(player: Player) -> void:
	player.life_component.extra_damage_taken -= amount
