extends Node

@onready var spike_wall_scene: PackedScene = preload("res://src/scenes/utils/SpikeWall.tscn")
@onready var spike_trap_scene: PackedScene = preload("res://src/scenes/utils/SpikeTrap.tscn")
@onready var platform_scene: PackedScene = preload("res://src/scenes/utils/Platform.tscn")
@onready var branch_scene: PackedScene = preload("res://src/scenes/utils/branch.tscn")

var spawned_walls: Array = []
var spawned_spikes: Array = []
var spawned_platforms: Array = []
var spawned_branches: Array = []

func _ready():
	_spawn_spike_wall()
	_spawn_platform(true)
	_spawn_platform(false)

	$PlatformTimer.timeout.connect(_on_PlatformTimer_timeout)
	$PlatformTimer.start()

	$BranchTimer.timeout.connect(_on_BranchTimer_timeout)
	$BranchTimer.start()

func _spawn_spike_wall():
	var wall = spike_wall_scene.instantiate()
	wall.z_index = 1000
	get_tree().get_root().add_child(wall)
	wall.call_deferred("setup")
	spawned_walls.append(wall)

func _spawn_spike():
	var spike = spike_trap_scene.instantiate()
	spike.z_index = 1000
	get_tree().get_root().add_child(spike)
	spike.call_deferred("setup_custom_spike")
	spawned_spikes.append(spike)

func _spawn_platform(first_spawn: bool):
	var platform = platform_scene.instantiate()
	platform.z_index = 1000
	get_tree().get_root().add_child(platform)
	platform.call_deferred("setup", first_spawn)
	spawned_platforms.append(platform)

func _spawn_branch():
	var branch = branch_scene.instantiate()
	branch.z_index = 1000
	get_tree().get_root().add_child(branch)
	branch.call_deferred("setup_custom_branch")
	branch.add_to_group("Branch")
	spawned_branches.append(branch)

func _on_PlatformTimer_timeout():
	_spawn_platform(false)

func _on_BranchTimer_timeout():
	_spawn_branch()
	_spawn_spike()

func clear_spawned_instances():
	for node in spawned_walls + spawned_spikes + spawned_platforms + spawned_branches:
		if is_instance_valid(node):
			node.queue_free()
	spawned_walls.clear()
	spawned_spikes.clear()
	spawned_platforms.clear()
	spawned_branches.clear()
