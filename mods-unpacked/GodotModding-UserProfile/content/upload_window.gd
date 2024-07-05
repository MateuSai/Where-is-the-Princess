class_name UploadWindow extends Window

static var mod_id: String

@warning_ignore("shadowed_variable")
func upload(mod_id: String) -> void:
	self.mod_id = mod_id
	Steam.createItem(Globals.app_id, Steam.WORKSHOP_FILE_TYPE_COMMUNITY)
