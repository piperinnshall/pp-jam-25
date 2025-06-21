extends Node

@onready var hook_point_scene: PackedScene = preload("res://src/scenes/utils/HookPoint.tscn")

func _ready():
	$Timer.timeout.connect(_on_Timer_timeout)

func _on_Timer_timeout():
	return
