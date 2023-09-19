class_name ShamanTribal extends Enemy


func get_closer_tribal_mask() -> TribalMask:
	var closer_tribal_mask: TribalMask = null
	var distance_to_closer_tribal_mask: float = INF

	for tribal_mask in get_tree().get_nodes_in_group("tribal_masks"):
		var dis: float = (tribal_mask.global_position - global_position).length()
		if dis < distance_to_closer_tribal_mask:
			closer_tribal_mask = tribal_mask
			distance_to_closer_tribal_mask = dis

	return closer_tribal_mask
