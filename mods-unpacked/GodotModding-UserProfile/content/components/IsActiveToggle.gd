class_name IsActiveToggle extends ButtonWithSound


signal is_active_toggled(mod_id: String, is_active: bool)

var mod_id: String
var is_active: bool: set = _set_is_active


func _set_is_active(new_is_active: bool) -> void:
	is_active = new_is_active
	self.button_pressed = new_is_active


func _on_IsActiveToggle_pressed() -> void:
	is_active = !is_active
	emit_signal("is_active_toggled", mod_id, is_active)
