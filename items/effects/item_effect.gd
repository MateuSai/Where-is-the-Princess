class_name ItemEffect

const GREEN: String = "green"
const YELLOW: String = "yellow"
const RED: String = "red"
const PURPLE: String = "purple"

func enable(_player: Player) -> void:
	push_warning("Overwrite this")
	assert(false)

func disable(_player: Player) -> void:
	push_warning("Overwrite this")
	assert(false)

func get_description() -> String:
	Log.warn("The get_description function should be overwritten")
	#assert(false)
	return ""

func _get_color_tag(color: String) -> String:
	return "[color=" + color + "]%s[/color]"

func _number_to_string(num) -> String:
	var s: String = str(num)

	if num >= 0:
		s = "+" + s

	return s