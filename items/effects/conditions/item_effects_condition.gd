class_name ItemEffectsCondition extends ItemEffect

var effects: Array[ItemEffect]
var enable_times_limit: int

var in_effect: bool = false

var times_enabled: int = 0

var player: Player

signal effects_enabled()
signal effect_disabled()

@warning_ignore("shadowed_variable")
func _init(effects: Array[ItemEffect], enable_times_limit: int=- 1) -> void:
	self.effects = effects
	self.enable_times_limit = enable_times_limit

@warning_ignore("shadowed_variable")
func enable(player: Player) -> void:
	self.player = player

func disable(_player: Player) -> void:
	if in_effect:
		_disable_effects()

func _enable_effects() -> void:
	if enable_times_limit != - 1 and times_enabled >= enable_times_limit:
		return

	in_effect = true

	times_enabled += 1

	for effect: ItemEffect in effects:
		effect.enable(player)

	effects_enabled.emit()

func _disable_effects() -> void:
	if in_effect:
		for effect: ItemEffect in effects:
			for i: int in times_enabled:
				effect.disable(player)

	in_effect = false
	times_enabled = 0

	effect_disabled.emit()

func get_description() -> String:
	var des: String = ""

	#breakpoint

	for i: int in effects.size():
		var effect: ItemEffect = effects[i]
		if effect.get_description().is_empty():
			continue

		if _tab_child_effects_description():
			var child_effects_description: PackedStringArray = effect.get_description().split("\n")
			for j: int in child_effects_description.size():
				des += "  %s" % child_effects_description[j]
				if j < (child_effects_description.size() - 1):
					des += "\n"
		else:
			des += effect.get_description()

		if effect != effects[effects.size() - 1] and not (i == effects.size() - 2 and effects[effects.size() - 1].get_description().is_empty()):
			des += "\n"

	#des.trim_suffix("\n")

	#breakpoint

	return des

func _tab_child_effects_description() -> bool:
	return true