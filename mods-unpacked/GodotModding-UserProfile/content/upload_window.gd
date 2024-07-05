class_name UploadWindow extends Window

func upload(mod_id: String) -> void:
	Steam.createItem(Globals.app_id, Steam.WORKSHOP_FILE_TYPE_COMMUNITY)
