class_name Armor

var sprite_sheet: Texture

var is_able_to_use_ability: bool = true

var recharge_time: float
var effect_duration: float
signal ability_effect_ended()


@warning_ignore("shadowed_variable")
func initialize(sprite_sheet: Texture, recharge_time: float, effect_duration: float = -1) -> void:
	self.sprite_sheet = sprite_sheet
	self.recharge_time = recharge_time
	self.effect_duration = effect_duration


func use_ability(player: Player) -> void:
	is_able_to_use_ability = false

	if effect_duration > 0:
		await player.get_tree().create_timer(effect_duration).timeout
		emit_signal("ability_effect_ended")

	await player.get_tree().create_timer(recharge_time).timeout

	is_able_to_use_ability = true
