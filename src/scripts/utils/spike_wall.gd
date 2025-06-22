extends Node2D

@onready var spike_scene: PackedScene = preload("res://src/scenes/utils/Spike.tscn")

@export var move_speed: float = 300
@export var spike_count: int = 100
@export var spacing: int = 27

func _process(delta: float) -> void:
	global_position.x += move_speed * delta

func setup():
	var viewport_size = get_viewport_rect().size
	var spawn_position = Vector2(-600, viewport_size.y * 0.5)
	global_position = spawn_position
	scale = Vector2(1, 1)
	_spawn_spike_wall()
	set_process(true)

func _spawn_spike_wall():
	var half = spike_count / 2.0 - 0.5
	for i in range(spike_count):
		var spike = spike_scene.instantiate()
		add_child(spike)
		spike.position = Vector2(0, (i - half) * spacing)
