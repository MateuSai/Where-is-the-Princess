extends Popup


@onready var tab_container: TabContainer = $TabContainer


func _ready() -> void:
	# Esta wea es para que se generen las traducciones
	tab_container.get_node("General").name = tr("General")
