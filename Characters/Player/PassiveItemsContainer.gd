extends HFlowContainer


func _on_player_temporal_passive_item_picked_up(item: TemporalPassiveItem) -> void:
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.texture = item.icon
	texture_rect.modulate.a = 0.5
	add_child(texture_rect)


func _on_player_temporal_passive_item_unequiped(index: int) -> void:
	get_child(index).free()
