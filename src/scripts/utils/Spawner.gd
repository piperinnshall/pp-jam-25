extends Node

@onready var spike_wall_scene: PackedScene = preload("res://src/scenes/utils/SpikeWall.tscn")
@onready var platform_scene: PackedScene = preload("res://src/scenes/utils/Platform.tscn")

func _ready():
	_spawn_spike_wall()
	_spawn_platform(true)
	
	$Timer.timeout.connect(_on_Timer_timeout)
	$Timer.start()

func _spawn_spike_wall():
	var wall = spike_wall_scene.instantiate()
	wall.z_index = 1000
	get_tree().get_root().call_deferred("add_child", wall)
	wall.call_deferred("setup")
	
func _spawn_platform(first_spawn: bool):
	var platform = platform_scene.instantiate()
	platform.z_index = 1000
	get_tree().get_root().call_deferred("add_child", platform)
	platform.call_deferred("setup", first_spawn)

func _on_Timer_timeout():
	_spawn_platform(false)
