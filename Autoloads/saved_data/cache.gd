class_name Cache

const CACHE_PATH: String = "user://cache/"
const KEY_IMAGES_PATH: String = "user://cache/key_images/"

static func get_key_image_path(key_id: String) -> String:
    return KEY_IMAGES_PATH.path_join(key_id + ".png")

static func get_key_image(key_id: String) -> Texture2D:
    if not DirAccess.dir_exists_absolute(CACHE_PATH):
        DirAccess.make_dir_absolute(CACHE_PATH)
    if not DirAccess.dir_exists_absolute(KEY_IMAGES_PATH):
        DirAccess.make_dir_absolute(KEY_IMAGES_PATH)

    var path: String = KEY_IMAGES_PATH.path_join(key_id + ".png")

    var file: FileAccess = FileAccess.open(path, FileAccess.READ)

    if file == null:
        var atlas_texture: AtlasTexture = AtlasTexture.new()
        atlas_texture.atlas = load("res://Art/kenney_input-prompts-pixel-16/Tilemap/tilemap_packed.png")
        atlas_texture.region = KeyIcon.get_key_region(key_id)
        atlas_texture.get_image().save_png(path)

    return ImageTexture.create_from_image(Image.load_from_file(path))