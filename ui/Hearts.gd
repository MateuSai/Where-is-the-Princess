class_name Hearts extends HBoxContainer

var previous_hp: int = 0


func update_hearts(_max_hp: int, new_hp: int) -> void:
	if new_hp == previous_hp:
		return

	var dif: int = new_hp - previous_hp
	if dif > 0:
		var i: int = dif
		var current_heart: HeartUI = get_child(int(previous_hp/4.0)) if get_child_count() >= int(previous_hp/4.0) + 1 else null
		while i > 0:
			if current_heart == null:
				var new_heart: HeartUI = HeartUI.new()
				add_child(new_heart)
				new_heart.hp = 0
				current_heart = new_heart
			i -= 4 - current_heart.hp
			current_heart.hp = 4 if i >= 0 else 4 + i
			current_heart = get_child(current_heart.get_index() + 1) if get_child_count()-1 > current_heart.get_index() else null
	elif dif < 0:
		var i: int = abs(dif)
		var current_heart: HeartUI = get_child(int((ceil(previous_hp/4.0) - 1.0) as float))
		while i > 0:
			assert(current_heart)
			i -= current_heart.hp
			current_heart.hp = 0 if i >= 0 else 0 - i
			current_heart = get_child(current_heart.get_index() - 1)

	previous_hp = new_hp
