class_name ArmorShardBreakProbability extends ItemEffect

var amount: int


func _init(amount: int) -> void:
	self.amount = amount


func enable(player: Player) -> void:
	player.armor_shard_break_probability += amount


func disable(player: Player) -> void:
	player.armor_shard_break_probability -= amount
