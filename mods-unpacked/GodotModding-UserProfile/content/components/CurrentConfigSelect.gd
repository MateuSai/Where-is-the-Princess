class_name CurrentConfigSelect extends OptionButtonWithSound


signal current_config_selected(mod_id: String, config_name: String)

var mod_id: String
var config_names: Dictionary = {}


func add_mod_configs(mod_configs: Dictionary) -> void:
	var index: int = 0
	for config_name: String in mod_configs.keys():
		config_names[config_name] = index
		add_item(config_name)
		index = index + 1


func select_item(item_text: String) -> void:
	var id: int = config_names[item_text]
	select(id)


func _on_CurrentConfigSelect_item_selected(index: int) -> void:
	current_config_selected.emit(mod_id, get_item_text(index))
