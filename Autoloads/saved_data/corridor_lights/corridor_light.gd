class_name CorridorLight

var light_scene: PackedScene
var top_margin_on_horizontal_corridor: float
var lateral_margin_on_vertical_corridor: float

func _init(light_scene: PackedScene, top_margin_on_horizontal_corridor: float, lateral_margin_on_vertical_corridor: float) -> void:
    self.light_scene = light_scene
    self.top_margin_on_horizontal_corridor = top_margin_on_horizontal_corridor
    self.lateral_margin_on_vertical_corridor = lateral_margin_on_vertical_corridor
