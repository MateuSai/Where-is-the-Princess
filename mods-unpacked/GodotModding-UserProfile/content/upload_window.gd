class_name UploadWindow extends Window

var mod_id: String

@onready var state_label: RichTextLabel = get_node("StateLabel")

func _ready() -> void:
	Steam.item_created.connect(_on_item_created)

@warning_ignore("shadowed_variable")
func upload(mod_id: String) -> void:
	state_label.text = "[color=yellow]" + tr("UPLOADING...") + "[/color]"

	self.mod_id = mod_id
	#Steam.getItemPrice()
	Steam.item_updated.connect(_on_item_updated, CONNECT_ONE_SHOT)
	Steam.createItem(Globals.app_id, Steam.WORKSHOP_FILE_TYPE_COMMUNITY)

func _on_item_created(result: int, file_id: int, _accept_tos: bool) -> void:
	if result != Steam.RESULT_OK:
		state_label.text = "[color=yellow]" + tr("ERROR_CREATING_WORKSHOP_ITEM") + ": " + str(result) + "[/color]"
		return

	var handler_id: int = Steam.startItemUpdate(Globals.app_id, file_id)

	var mod_data: ModData = ModLoaderStore.mod_data[mod_id]
	var mod_dir_path: String = _ModLoaderPath.get_path_to_mods().path_join(mod_id)

	Steam.setItemTitle(handler_id, mod_data.manifest.name)
	Steam.setItemDescription(handler_id, mod_data.manifest.description)
	Steam.setItemContent(handler_id, mod_dir_path)
	Steam.setItemTags(handler_id, mod_data.manifest.tags)
	Steam.setItemVisibility(handler_id, Steam.REMOTE_STORAGE_PUBLISHED_VISIBILITY_PUBLIC)
	Steam.submitItemUpdate(handler_id, "Update notes")

func _on_item_updated(result: int, _accept_tos: bool) -> void:
	if result != Steam.RESULT_OK:
		state_label.text = "[color=red]" + tr("FAILED_TO_UPLOAD") + ": " + str(result) + "[/color]"
	else:
		state_label.text = "[color=green]" + tr("UPLOADED_CORRECTLY") + "[/color]"
