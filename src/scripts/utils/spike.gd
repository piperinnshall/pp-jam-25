extends StaticBody2D

@export var move_speed: float = 100

static var last_spike_x = 1500
var spike_distance = 1200
var x_variation = 300
const FIXED_Y = 386

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	return

func setup():
	var random_x_offset = randf_range(-x_variation, x_variation)
	var next_pos = Vector2(last_spike_x + spike_distance + random_x_offset, FIXED_Y)
	global_position = next_pos
	last_spike_x = global_position.x
