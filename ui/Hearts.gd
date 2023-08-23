class_name Hearts extends HBoxContainer


const HEART_TEXTURE: Texture = preload("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/heart_animation.tres")


func update_hearts(new_value: int) -> void:
	var dif = new_value - get_child_count()
	if dif > 0:
		for i in dif:
			var texture_rect: TextureRect = TextureRect.new()
			texture_rect.texture = HEART_TEXTURE
			add_child(texture_rect)
	elif dif < 0:
		for i in abs(dif):
			get_child(get_child_count()-1).free()
