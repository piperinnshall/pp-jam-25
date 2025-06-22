extends Node2D

static var SPAWN_POSITION: Vector2 = Vector2(-200, 0)

@export var move_speed: float = 100

func _ready():
	set_process(false)

func _process(delta: float) -> void:
	global_position += Vector2(move_speed * delta, 0)

func setup():
	global_position = SPAWN_POSITION
	scale =  Vector2(1, 1)
	
	set_process(true)
