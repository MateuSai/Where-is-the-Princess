class_name Mod

var resource_path: String
var enabled: bool = true

@warning_ignore("shadowed_variable")
func _init(resource_path: String) -> void:
	self.resource_path = resource_path


func get_name() -> String:
	return resource_path.get_file()


func to_dictionary() -> Dictionary:
	return {
		resource_path = resource_path,
		enabled = enabled,
	}


static func from_dictionary(dic: Dictionary) -> Mod:
	var mod: Mod = Mod.new(dic.resource_path)
	mod.enabled = dic.enabled
	return mod
