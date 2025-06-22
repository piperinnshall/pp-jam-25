extends Node

@onready var spike_wall_scene: PackedScene = preload("res://src/scenes/utils/SpikeWall.tscn")
@onready var hook_point_scene: PackedScene = preload("res://src/scenes/utils/HookPoint.tscn")

func _ready():
	var spike_wall_instance = spike_wall_scene.instantiate()
	spike_wall_instance.z_index = 1001

	get_tree().get_root().call_deferred("add_child", spike_wall_instance)
	spike_wall_instance.call_deferred("setup")
	
	$Timer.timeout.connect(_on_Timer_timeout)

func _on_Timer_timeout():
	return
