class_name RemoveCoins extends ItemEffect

var amount: int

@warning_ignore("shadowed_variable")
func _init(amount: int) -> void:
    self.amount = amount

func enable(player: Player) -> void:
    player.remove_coins(amount)