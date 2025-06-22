extends Node

@onready var spike_wall_scene: PackedScene = preload("res://src/scenes/utils/SpikeWall.tscn")
@onready var spike_trap_scene: PackedScene = preload("res://src/scenes/utils/SpikeTrap.tscn")
@onready var platform_scene: PackedScene = preload("res://src/scenes/utils/Platform.tscn")
@onready var branch_scene: PackedScene = preload("res://src/scenes/utils/branch.tscn")


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
	get_tree().get_root().call_deferred("add_child", wall)
	wall.call_deferred("setup")
	
func _spawn_spike():
	var spike = spike_trap_scene.instantiate()
	spike.z_index = 1000
	get_tree().get_root().call_deferred("add_child", spike)
	spike.call_deferred("setup_custom_spike")
	
func _spawn_platform(first_spawn: bool):
	var platform = platform_scene.instantiate()
	platform.z_index = 1000
	get_tree().get_root().call_deferred("add_child", platform)
	platform.call_deferred("setup", first_spawn)
	
func _spawn_branch():
	var branch = branch_scene.instantiate()
	branch.z_index = 1000
	get_tree().get_root().call_deferred("add_child", branch)
	branch.call_deferred("setup_custom_branch")
	branch.add_to_group("Branch")

func _on_PlatformTimer_timeout():
	_spawn_platform(false)

func _on_BranchTimer_timeout():
	_spawn_branch()
	_spawn_spike()
