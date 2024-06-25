class_name CursedPermanentPassiveItem extends PermanentPassiveItem

func get_cursed_version_path() -> String:
	return ""

#func get_item_name() -> String:
	#var normal_version_name: String = tr((get_script_path().get_basename().get_file().to_snake_case().trim_suffix("_cursed").to_upper()))

	#var item_name: String
	#if Globals.is_current_language_a_piece_of_shit_that_uses_gender_for_inanimate_objects():
	#	if Globals.is_word_feminine(normal_version_name):
	#		item_name = tr("CURSED_ITEM_NAME_FEMININE")
	#	else:
	#		item_name = tr("CURSED_ITEM_NAME_MASCULINE")
	#else:
	#	item_name = tr("CURSED_ITEM_NAME_FEMININE")

	#return item_name % normal_version_name