class_name EncyclopediaButton extends ButtonWithSound

var _icon_texture_rect: TextureRect

const ICON_MARGIN: int = 8

func _init() -> void:
    _icon_texture_rect = TextureRect.new()
    add_child(_icon_texture_rect)
    _icon_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    _icon_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED

func set_icon_texture(new_texture: Texture2D) -> void:
    _icon_texture_rect.texture = new_texture
    custom_minimum_size = new_texture.get_size() + Vector2.ONE * ICON_MARGIN

func disable() -> void:
    disabled = true
    _icon_texture_rect.modulate = Color.BLACK.lightened(0.1)