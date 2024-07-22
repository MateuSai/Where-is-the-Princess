@tool

class_name EnemyMarker extends Marker2D

var enemy_in_editor: Enemy = null

@export var enemy_name: String = "": set = _set_enemy_id

func _set_enemy_id(new_id: String) -> void:
	enemy_name = new_id

	if Engine.is_editor_hint():
		if enemy_in_editor:
			enemy_in_editor.queue_free()

		var new_enemy_dic: Dictionary = Enemy.get_path_and_info(enemy_name)
		if new_enemy_dic.is_empty():
			new_enemy_dic = Enemy.get_path_and_info(enemy_name.to_pascal_case())
			if new_enemy_dic.is_empty():
				printerr("Invalid enemy")
				enemy_in_editor = null
				return

		enemy_in_editor = load(new_enemy_dic.path).instantiate()
		add_child(enemy_in_editor)
