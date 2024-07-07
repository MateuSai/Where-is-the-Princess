class_name ArmorPointsHBox extends HBoxContainer

var previous_ap: int = 0


func update_armor_points(new_ap: int) -> void:
	if new_ap == previous_ap:
		return

	var dif: int = new_ap - previous_ap
	if dif > 0:
		var i: int = dif
		var current_armor_point_ui: ArmorPointUI = get_child(int(previous_ap/2.0)) if get_child_count() >= int(previous_ap/2.0) + 1 else null
		while i > 0:
			if current_armor_point_ui == null:
				var new_armor_point_ui: ArmorPointUI = ArmorPointUI.new()
				add_child(new_armor_point_ui)
				new_armor_point_ui.ap = 0
				current_armor_point_ui = new_armor_point_ui
			i -= 2 - current_armor_point_ui.ap
			current_armor_point_ui.ap = 2 if i >= 0 else 2 + i
			current_armor_point_ui = get_child(current_armor_point_ui.get_index() + 1) if get_child_count()-1 > current_armor_point_ui.get_index() else null
	elif dif < 0:
		var i: int = abs(dif)
		var current_armor_point_ui: ArmorPointUI = get_child(int((ceil(previous_ap/2.0) - 1.0) as float))
		while i > 0:
			assert(current_armor_point_ui)
			i -= current_armor_point_ui.ap
			current_armor_point_ui.ap = 0 if i >= 0 else 0 - i
			current_armor_point_ui = get_child(current_armor_point_ui.get_index() - 1)

	previous_ap = new_ap
