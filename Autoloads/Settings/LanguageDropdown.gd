extends OptionButtonWithSound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

	var unique_locales: Array[String] = []
	var loaded_locales: PackedStringArray = TranslationServer.get_loaded_locales()
	for locale: String in loaded_locales:
		if not unique_locales.has(locale):
			unique_locales.push_back(locale)

	for locale: String in unique_locales:
		add_item(locale)

	select(TranslationServer.get_loaded_locales().find(TranslationServer.get_locale()))

	item_selected.connect(func(index: int) -> void:
		TranslationServer.set_locale(get_item_text(index))
	)
