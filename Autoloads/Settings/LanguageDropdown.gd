extends OptionButtonWithSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

	var unique_locales: Array[String] = Globals.get_unique_locales()

	for locale: String in unique_locales:
		add_item(locale)

	select(TranslationServer.get_loaded_locales().find(TranslationServer.get_locale()))

	item_selected.connect(func(index: int) -> void:
		TranslationServer.set_locale(get_item_text(index))
	)
