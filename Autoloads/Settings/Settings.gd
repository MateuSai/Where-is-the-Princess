extends Popup

const SETTINGS_PATH: String = "user://settings.cfg"

var settings: ConfigFile = null

@onready var tab_container: TabContainer = $TabContainer


func _init() -> void:
	_load_settings()


func _ready() -> void:
	hide()

	# Esta wea es para que se generen las traducciones
	tab_container.get_node("General").name = tr("General")
	popup_hide.connect(_save_settings)


func _save_settings() -> void:
	settings.set_value("General", "language", TranslationServer.get_locale())
	settings.set_value("General", "window_mode", DisplayServer.window_get_mode())

	settings.save(SETTINGS_PATH)


func _load_settings() -> void:
	settings = ConfigFile.new()
	settings.load(SETTINGS_PATH)

	TranslationServer.set_locale(settings.get_value("General", "language", "en"))
	DisplayServer.window_set_mode(settings.get_value("General", "window_mode", DisplayServer.WINDOW_MODE_WINDOWED))
