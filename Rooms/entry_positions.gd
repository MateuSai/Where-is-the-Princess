class_name EntryPositions extends Node2D
## Defines the points where the room will be connected with a corridor

@export var open_after_combat: bool = true

@onready var marker1: Marker2D = $Marker2D
@onready var marker2: Marker2D = $Marker2D2

var connections: int = 0
